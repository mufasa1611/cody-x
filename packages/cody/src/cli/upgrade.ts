import { Bus } from "@/bus"
import { Config } from "@/config/config"
import { AppRuntime } from "@/effect/app-runtime"
import { Flag } from "@cody/core/flag/flag"
import { Installation } from "@/installation"
import { InstallationVersion } from "@cody/core/installation/version"
import { execSync } from "child_process"

async function codyProUpgrade() {
  try {
    const repoRoot = execSync("git rev-parse --show-toplevel", { encoding: "utf8", timeout: 5000 }).trim()
    if (!repoRoot) return
    const branch = process.env.CODY_BRANCH || "main"
    execSync("git fetch origin " + branch + " --quiet", { cwd: repoRoot, encoding: "utf8", timeout: 15000 })
    const behind = execSync("git rev-list --count HEAD..origin/" + branch, { cwd: repoRoot, encoding: "utf8", timeout: 5000 }).trim()
    if (behind === "0" || behind === "") return
    await Bus.publish(Installation.Event.UpdateAvailable, { version: "latest" })
  } catch {
    // Best-effort
  }
}

export async function upgrade() {
  const config = await AppRuntime.runPromise(Config.Service.use((cfg) => cfg.getGlobal()))
  if (config.autoupdate === false || Flag.CODY_DISABLE_AUTOUPDATE) return

  // For git-based installs, check git origin instead of npm
  if (true) {
    return codyProUpgrade()
  }

  const method = await Installation.method()
  const latest = await Installation.latest(method).catch(() => "")
  if (!latest) return

  if (Flag.CODY_ALWAYS_NOTIFY_UPDATE) {
    await Bus.publish(Installation.Event.UpdateAvailable, { version: latest })
    return
  }

  if (InstallationVersion === latest) return

  const kind = Installation.getReleaseType(InstallationVersion, latest)

  if (config.autoupdate === "notify" || kind !== "patch") {
    await Bus.publish(Installation.Event.UpdateAvailable, { version: latest })
    return
  }

  if (method === "unknown") return
  await Installation.upgrade(method, latest)
    .then(() => Bus.publish(Installation.Event.Updated, { version: latest }))
    .catch(() => "")
}

