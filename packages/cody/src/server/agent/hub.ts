import { Context, Deferred, Duration, Effect, Layer, Schedule, Scope } from "effect"
import * as Log from "@cody/core/util/log"
import type { AgentMessage, HubMessage } from "./types"

const log = Log.create({ service: "agent-hub" })

const CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" // no I,O,0,1 to avoid confusion
const CODE_LENGTH = 6
const CODE_TTL_DURATION = Duration.minutes(5)
const COMMAND_TIMEOUT_DURATION = Duration.seconds(30)

interface PendingCommand {
  deferred: Deferred.Deferred<unknown, Error>
}

// Write function type for sending data to an agent
type AgentWriter = (data: string | Uint8Array) => Effect.Effect<void>

interface PairedAgent {
  code: string
  write: AgentWriter
  connectedAt: number
  remotePlatform?: string
  remoteHostname?: string
}

interface PairingCode {
  code: string
  createdAt: number
  expiresAt: number
  used: boolean
}

export interface Interface {
  readonly createPairingCode: Effect.Effect<string>
  readonly connectAgent: (code: string, write: AgentWriter) => Effect.Effect<boolean, Error>
  readonly disconnectAgent: (code: string) => Effect.Effect<void>
  readonly dispatch: (message: AgentMessage, senderCode?: string) => Effect.Effect<void>
  readonly getStatus: Effect.Effect<{ connected: boolean; code?: string; pairedAt?: number }>
  readonly listDir: (path: string) => Effect.Effect<unknown, Error>
  readonly readFile: (path: string) => Effect.Effect<unknown, Error>
  readonly writeFile: (path: string, content: string) => Effect.Effect<unknown, Error>
  readonly exec: (command: string) => Effect.Effect<unknown, Error>
}

export class Service extends Context.Service<Service, Interface>()("@cody/AgentHub") {}

// In-memory state
const pairingCodes = new Map<string, PairingCode>()
const agents = new Map<string, PairedAgent>()
let nextCommandId = 1
const pendingCommands = new Map<number, PendingCommand>()

function generateCode(): string {
  let code = ""
  for (let i = 0; i < CODE_LENGTH; i++) {
    code += CODE_CHARS[Math.floor(Math.random() * CODE_CHARS.length)]
  }
  return code
}

function cleanupExpiredCodes(): void {
  const now = Date.now()
  for (const [code, info] of pairingCodes) {
    if (now > info.expiresAt || info.used) {
      pairingCodes.delete(code)
    }
  }
}

export const layer = Layer.effect(
  Service,
  Effect.gen(function* () {
    // Periodically clean up expired codes
    yield* Effect.forkScoped(
      Effect.repeat(
        Effect.sync(() => cleanupExpiredCodes()),
        Schedule.fixed(Duration.minutes(1)),
      ),
    )

    const createPairingCode = Effect.fn("AgentHub.createPairingCode")(function* () {
      // Clean up existing codes first
      cleanupExpiredCodes()

      let code: string
      do {
        code = generateCode()
      } while (pairingCodes.has(code))

      const now = Date.now()
      pairingCodes.set(code, {
        code,
        createdAt: now,
        expiresAt: now + Duration.toMillis(CODE_TTL_DURATION),
        used: false,
      })

      log.info("created pairing code", { code, expiresAt: now + Duration.toMillis(CODE_TTL_DURATION) })
      return code
    })

    const connectAgent = Effect.fn("AgentHub.connectAgent")(function* (
      code: string,
      write: AgentWriter,
    ) {
      const pairing = pairingCodes.get(code)
      if (!pairing || pairing.used || Date.now() > pairing.expiresAt) {
        log.warn("invalid pairing code", { code })
        return false
      }

      // Mark code as used
      pairing.used = true

      // Register agent
      const agent: PairedAgent = {
        code,
        write,
        connectedAt: Date.now(),
      }
      agents.set(code, agent)

      log.info("agent connected", { code })
      return true
    })

    const disconnectAgent = Effect.fn("AgentHub.disconnectAgent")(function* (code: string) {
      const agent = agents.get(code)
      if (agent) {
        agents.delete(code)
        // Reject all pending commands for this agent
        for (const [id, pending] of pendingCommands) {
          pendingCommands.delete(id)
          yield* Deferred.fail(pending.deferred, new Error("Agent disconnected"))
        }
        log.info("agent disconnected", { code })
      }
    })

    const dispatch = Effect.fn("AgentHub.dispatch")(function* (message: AgentMessage, senderCode?: string) {
      switch (message.type) {
        case "result":
        case "error": {
          const pending = pendingCommands.get(message.id)
          if (pending) {
            pendingCommands.delete(message.id)
            if (message.type === "error") {
              yield* Deferred.fail(pending.deferred, new Error(message.error))
            } else {
              yield* Deferred.succeed(pending.deferred, message.data)
            }
          }
          break
        }
case "pong": {
          if (senderCode) {
            const agent = agents.get(senderCode)
            if (agent) agent.lastPong = Date.now()
          }
          break
        }
        case "disconnect":
          break
      }
    })

    const sendCommand = (command: string, args: unknown): Effect.Effect<unknown, Error> =>
      Effect.gen(function* () {
        const agentsList = Array.from(agents.values())
        if (agentsList.length === 0) {
          return yield* Effect.fail(new Error("No agent connected"))
        }

        const agent = agentsList[0]
        const id = nextCommandId++
        const deferred = yield* Deferred.make<unknown, Error>()

        pendingCommands.set(id, { deferred })

        const message: HubMessage = { type: "command", id, command, args }
        const encoded = JSON.stringify(message)
        log.info("sending command to agent", { id, command, encodedLen: encoded.length })

        // Write with timeout to avoid hanging
        yield* agent.write(encoded).pipe(
          Effect.timeout(Duration.seconds(5)),
          Effect.catch((err) => {
            pendingCommands.delete(id)
            log.error("write to agent failed or timed out", { id, command, error: String(err) })
            return Effect.fail(
              err instanceof Error ? err : new Error(`Write failed: ${String(err)}`),
            )
          }),
        )

        log.info("sent command to agent", { id, command })

        // Wait for response with timeout
        const result = yield* Deferred.await(deferred).pipe(
          Effect.timeout(COMMAND_TIMEOUT_DURATION),
          Effect.catch(() => {
            pendingCommands.delete(id)
            return Effect.fail(new Error(`Command timed out after ${Duration.toMillis(COMMAND_TIMEOUT_DURATION)}ms`))
          }),
        )

        return result
      })

    const getStatus = Effect.fn("AgentHub.getStatus")(function* () {
      const agentsList = Array.from(agents.values())
      if (agentsList.length === 0) {
        return { connected: false } as const
      }
      const agent = agentsList[0]
      return {
        connected: true,
        code: agent.code,
        pairedAt: agent.connectedAt,
      } as const
    })

    return Service.of({
      createPairingCode: createPairingCode(),
      connectAgent: (code, write) => connectAgent(code, write),
      disconnectAgent: (code) => disconnectAgent(code),
      dispatch: (message, code) => dispatch(message, code),
      getStatus: getStatus(),
      listDir: (path) => sendCommand("list-dir", { path }),
      readFile: (path) => sendCommand("read-file", { path }),
      writeFile: (path, content) => sendCommand("write-file", { path, content }),
      exec: (command) => sendCommand("exec", { command }),
    })
  }),
)
