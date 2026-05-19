import { Effect } from "effect"
import { HttpApiBuilder } from "effect/unstable/httpapi"
import { InstanceHttpApi } from "../api"
import * as AgentHub from "@/server/agent/hub"

export const agentHandlers = HttpApiBuilder.group(InstanceHttpApi, "agent", (handlers) =>
  Effect.gen(function* () {
    const hub = yield* AgentHub.Service

    const createPair = Effect.fn("AgentHttpApi.createPair")(function* () {
      const code = yield* hub.createPairingCode
      return { code, expiresAt: Date.now() + 5 * 60 * 1000 }
    })

    const status = Effect.fn("AgentHttpApi.status")(function* () {
      return yield* hub.getStatus
    })

    // These HttpApi endpoints exist for route parity / OpenAPI docs.
    // Full agent functionality is handled by the Hono REST routes.
    const listDir = Effect.fn("AgentHttpApi.listDir")(function* () {
      return { files: [] } as { files: Array<{ name: string; path: string; type: "file" | "directory"; size?: number; modifiedAt?: number }> }
    })

    const readFile = Effect.fn("AgentHttpApi.readFile")(function* () {
      return { content: "" } as { content: string; encoding?: string }
    })

    const writeFile = Effect.fn("AgentHttpApi.writeFile")(function* () {
      return { success: false }
    })

    const exec = Effect.fn("AgentHttpApi.exec")(function* () {
      return { stdout: "", stderr: "Not implemented via HttpApi", exitCode: 1 }
    })

    const disconnect = Effect.fn("AgentHttpApi.disconnect")(function* () {
      const s = yield* hub.getStatus
      if (s.connected && s.code) {
        yield* hub.disconnectAgent(s.code)
      }
      return { disconnected: true }
    })

    return handlers
      .handle("createPair", createPair)
      .handle("status", status)
      .handle("listDir", listDir)
      .handle("readFile", readFile)
      .handle("writeFile", writeFile)
      .handle("exec", exec)
      .handle("disconnect", disconnect)
  }),
)
