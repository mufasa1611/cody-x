import { Hono } from "hono"
import { describeRoute, resolver, validator } from "hono-openapi"
import z from "zod"
import { Effect } from "effect"
import { errors } from "@/server/error"
import { lazy } from "@/util/lazy"
import { jsonRequest } from "@/server/routes/instance/trace"
import * as AgentHub from "./hub"
import type {
  CreatePairingResponse,
  AgentStatusResponse,
  AgentListDirResponse,
  AgentReadFileResponse,
  AgentWriteFileResponse,
  AgentExecResponse,
} from "./types"

export const AgentRoutes = lazy(() =>
  new Hono()
    // Create a pairing code
    .post(
      "/pair",
      describeRoute({
        summary: "Create pairing code",
        description: "Generate a new one-time pairing code for remote PC connection.",
        operationId: "agent.createPairingCode",
        responses: {
          200: {
            description: "Pairing code created",
            content: {
              "application/json": {
                schema: resolver(
                  z.object({
                    code: z.string(),
                    expiresAt: z.number(),
                  }),
                ),
              },
            },
          },
        },
      }),
      async (c) =>
        jsonRequest("AgentRoutes.createPairingCode", c, function* () {
          const hub = yield* AgentHub.Service
          const code = yield* hub.createPairingCode
          return { code, expiresAt: Date.now() + 5 * 60 * 1000 } as CreatePairingResponse
        }),
    )
    // Get agent connection status
    .get(
      "/status",
      describeRoute({
        summary: "Get agent connection status",
        description: "Check if a remote PC agent is currently connected.",
        operationId: "agent.status",
        responses: {
          200: {
            description: "Agent connection status",
            content: {
              "application/json": {
                schema: resolver(
                  z.object({
                    connected: z.boolean(),
                    pairedAt: z.number().optional(),
                  }),
                ),
              },
            },
          },
        },
      }),
      async (c) =>
        jsonRequest("AgentRoutes.status", c, function* () {
          const hub = yield* AgentHub.Service
          return yield* hub.getStatus
        }),
    )
    // List directories on the remote PC
    .get(
      "/fs/list",
      describeRoute({
        summary: "List remote directory",
        description: "List files and directories on the connected remote PC.",
        operationId: "agent.fs.list",
        responses: {
          200: {
            description: "Directory listing",
            content: {
              "application/json": {
                schema: resolver(z.object({ files: z.array(z.any()) })),
              },
            },
          },
          ...errors(400, 503),
        },
      }),
      validator(
        "query",
        z.object({
          path: z.string().default("/"),
        }),
      ),
      async (c) =>
        jsonRequest("AgentRoutes.fs.list", c, function* () {
          const hub = yield* AgentHub.Service
          const { path } = c.req.valid("query")
          const result = yield* hub.listDir(path)
          return { files: result as any[] } as AgentListDirResponse
        }),
    )
    // Read a file on the remote PC
    .get(
      "/fs/read",
      describeRoute({
        summary: "Read remote file",
        description: "Read a file on the connected remote PC.",
        operationId: "agent.fs.read",
        responses: {
          200: {
            description: "File content",
            content: {
              "application/json": {
                schema: resolver(z.object({ content: z.string(), encoding: z.string().optional() })),
              },
            },
          },
          ...errors(400, 503),
        },
      }),
      validator(
        "query",
        z.object({
          path: z.string(),
        }),
      ),
      async (c) =>
        jsonRequest("AgentRoutes.fs.read", c, function* () {
          const hub = yield* AgentHub.Service
          const { path } = c.req.valid("query")
          const result = yield* hub.readFile(path)
          return result as AgentReadFileResponse
        }),
    ),
)
