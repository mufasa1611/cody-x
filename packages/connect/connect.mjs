#!/usr/bin/env bun

// Cody Pro Remote Agent
// Usage: bunx cody-connect <PAIRING_CODE>
// Connects to cody.kingkung.men WebSocket hub and serves local filesystem

import fs from "fs"
import path from "path"
import { execSync } from "child_process"

const WS_URL = process.env.CODY_WS_URL || "wss://cody.kingkung.men/ws/agent"
const code = process.argv[2]

if (!code) {
  console.error("Usage: bunx cody-connect <PAIRING_CODE>")
  console.error("Get a pairing code from cody.kingkung.men > Settings > Connect My PC")
  process.exit(1)
}

// Auto-elevate on Windows if not already admin
if (process.platform === "win32") {
  try {
    execSync("net session", { encoding: "utf-8", timeout: 3000 })
  } catch {
    console.log("Elevating to administrator privileges for full remote control...")
    const args = process.argv.slice(1).map(a => `"${a}"`).join(" ")
    const cmd = `Start-Process -Verb RunAs -FilePath '${process.execPath}' -ArgumentList ${args} -Wait`
    execSync(`powershell -Command "${cmd}"`, { timeout: 15000 })
    process.exit(0)
  }
}

console.log("Cody Connect Agent (admin mode)")
startAgent(code)

// --- WebSocket Agent ---

let ws, reconnectTimer, running = true

async function startAgent(code) {
  if (!running) return

  console.log(`Connecting to ${WS_URL}...`)

  try {
    const WebSocket = globalThis.WebSocket || await import("ws").then(m => m.default || m).catch(() => null)

    if (WebSocket) {
      ws = new WebSocket(WS_URL)
    } else {
      ws = new globalThis.WebSocket(WS_URL)
    }

    ws.onopen = () => {
      console.log("Connected! Sending pairing code...")
      ws.send(JSON.stringify({ type: "pair", code }))
    }

    ws.onmessage = async (event) => {
      try {
        const msg = JSON.parse(event.data.toString())
        await handleMessage(msg)
      } catch (err) {
        console.error("Failed to parse message:", err.message)
      }
    }

    ws.onclose = (event) => {
      console.log(`Disconnected (code: ${event.code}), reconnecting in 5s...`)
      if (running) reconnectTimer = setTimeout(() => startAgent(code), 5000)
    }

    ws.onerror = (err) => {
      console.error("WebSocket error:", err.message || err)
    }

  } catch (err) {
    console.error("Connection failed:", err.message)
    if (running) reconnectTimer = setTimeout(() => startAgent(code), 5000)
  }
}

async function handleMessage(msg) {
  switch (msg.type) {
    case "paired":
      console.log("Paired successfully! Awaiting commands...")
      break
    case "pair-error":
      console.error("Pairing failed:", msg.error)
      ws.close()
      running = false
      process.exit(1)
      break
    case "command":
      try {
        const result = await executeCommand(msg.command, msg.args)
        ws.send(JSON.stringify({ type: "result", id: msg.id, data: result }))
      } catch (err) {
        ws.send(JSON.stringify({ type: "error", id: msg.id, error: err.message }))
      }
      break
    case "ping":
      ws.send(JSON.stringify({ type: "pong" }))
      break
    case "disconnect":
      console.log("Server requested disconnect")
      ws.close()
      running = false
      process.exit(0)
      break
  }
}

async function listDrives() {
  const drives = []
  for (let i = 65; i <= 90; i++) {
    const letter = String.fromCharCode(i)
    try {
      fs.accessSync(letter + ":\\", fs.constants.F_OK)
      drives.push({ name: letter + ":\\", path: letter + ":\\", type: "directory" })
    } catch {}
  }
  return drives
}

async function executeCommand(command, args) {
  switch (command) {
    case "list-dir": {
      const dirPath = args.path || "/"
      if (process.platform === "win32" && (dirPath === "/" || dirPath === "\\")) {
        return { files: await listDrives() }
      }
      const entries = []
      try {
        const dirEntries = await fs.promises.readdir(dirPath, { withFileTypes: true })
        for (const entry of dirEntries) {
          try {
            const fullPath = path.join(dirPath, entry.name)
            const stat = await fs.promises.stat(fullPath)
            entries.push({
              name: entry.name,
              path: fullPath,
              type: entry.isDirectory() ? "directory" : "file",
              size: stat.size,
              modifiedAt: stat.mtimeMs,
            })
          } catch {
            entries.push({
              name: entry.name,
              path: path.join(dirPath, entry.name),
              type: entry.isDirectory() ? "directory" : "file",
            })
          }
        }
      } catch (err) {
        throw new Error(`Cannot list directory: ${err.message}`)
      }
      return { files: entries }
    }
    case "read-file": {
      const filePath = args.path
      try {
        const content = await fs.promises.readFile(filePath, "utf-8")
        return { content, encoding: "utf8" }
      } catch {
        const buf = await fs.promises.readFile(filePath)
        return { content: buf.toString("base64"), encoding: "base64" }
      }
    }
    case "write-file": {
      const filePath = args.path
      const content = args.content
      const encoding = args.encoding || "utf8"
      await fs.promises.mkdir(path.dirname(filePath), { recursive: true })
      if (encoding === "base64") {
        await fs.promises.writeFile(filePath, Buffer.from(content, "base64"))
      } else {
        await fs.promises.writeFile(filePath, content, "utf-8")
      }
      return { success: true }
    }
    case "exec": {
      const commandStr = args.command
      try {
        const output = execSync(commandStr, {
          encoding: "utf-8",
          maxBuffer: 10 * 1024 * 1024,
          timeout: 30000,
        })
        return { stdout: output, stderr: "", exitCode: 0 }
      } catch (err) {
        return {
          stdout: err.stdout || "",
          stderr: err.stderr || err.message,
          exitCode: err.status || 1,
        }
      }
    }
    default:
      throw new Error(`Unknown command: ${command}`)
  }
}

process.on("SIGINT", () => {
  console.log("\nShutting down...")
  running = false
  clearTimeout(reconnectTimer)
  if (ws) ws.close()
  process.exit(0)
})

process.on("SIGTERM", () => {
  running = false
  clearTimeout(reconnectTimer)
  if (ws) ws.close()
  process.exit(0)
})
