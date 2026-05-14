import { Effect } from "effect"
import { Server } from "../../server/server"
import { effectCmd } from "../effect-cmd"
import { withNetworkOptions, resolveNetworkOptions } from "../network"
import { Flag } from "@cody/core/flag/flag"

export const ServeCommand = effectCmd({
  command: "serve",
  builder: (yargs) => withNetworkOptions(yargs),
  describe: process.env.CODY_PRO === "0" ? "starts a headless opencode server" : "starts a headless Cody Pro server",
  // Server loads instances per-request via x-opencode-directory header — no
  // need for an ambient project InstanceContext at startup.
  instance: false,
  handler: Effect.fn("Cli.serve")(function* (args) {
    if (!Flag.CODY_SERVER_PASSWORD) {
      console.log("Warning: CODY_SERVER_PASSWORD is not set; server is unsecured.")
    }
    const opts = yield* resolveNetworkOptions(args)
    const server = yield* Effect.promise(() => Server.listen(opts))
    console.log(
      `${process.env.CODY_PRO === "0" ? "cody" : "Cody Pro"} server listening on http://${server.hostname}:${server.port}`,
    )

    yield* Effect.never
  }),
})
