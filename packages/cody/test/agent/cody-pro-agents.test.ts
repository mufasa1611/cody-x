import { test, expect } from "bun:test"
import path from "path"
import { ConfigAgent } from "../../src/config/agent"

const root = path.resolve(import.meta.dir, "../../../..")

test("Cody Pro project agents load from .cody/agent", async () => {
  const agents = await ConfigAgent.load(path.join(root, ".cody"))

  expect(agents.operator?.mode).toBe("primary")
  expect(agents.operator?.permission?.edit).toBe("deny")
  expect(agents.operator?.permission?.bash).toBe("ask")
  expect(agents.operator?.permission?.task).toBe("allow")

  for (const name of [
    "infra-audit",
    "windows-admin",
    "ssh-operator",
    "docker-operator",
    "systemd-operator",
    "proxmox-operator",
    "backup-operator",
    "web-research",
  ]) {
    expect(agents[name]?.mode).toBe("subagent")
  }

  expect(agents["web-research"]?.permission?.bash).toBe("deny")
  expect(agents["web-research"]?.permission?.edit).toBe("deny")
  expect(agents["web-research"]?.permission?.webfetch).toBe("allow")
  expect(agents["web-research"]?.permission?.websearch).toBe("allow")

  expect(Object.keys(agents).some((name) => name.includes("synology"))).toBe(false)
})
