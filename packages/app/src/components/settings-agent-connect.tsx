import { Component, Show, createSignal, onCleanup, onMount } from "solid-js"
import { Button } from "@cody/ui/button"
import { Icon } from "@cody/ui/icon"
import { showToast } from "@cody/ui/toast"
import { useLanguage } from "@/context/language"

export const SettingsAgentConnect: Component = () => {
  const language = useLanguage()

  const [pairingCode, setPairingCode] = createSignal<string | null>(null)
  const [codeExpiresAt, setCodeExpiresAt] = createSignal<number | null>(null)
  const [connected, setConnected] = createSignal(false)
  const [pairedAt, setPairedAt] = createSignal<number | null>(null)
  const [generating, setGenerating] = createSignal(false)

  let intervalId: ReturnType<typeof setInterval> | undefined

  const checkStatus = async () => {
    try {
      const res = await fetch("/agent/status")
      if (res.ok) {
        const data = await res.json()
        setConnected(data.connected)
        setPairedAt(data.pairedAt ?? null)
      }
    } catch {
      // server not available
    }
  }

  onMount(() => {
    checkStatus()
    intervalId = setInterval(checkStatus, 3000)
  })

  onCleanup(() => {
    if (intervalId) clearInterval(intervalId)
  })

  const generateCode = async () => {
    setGenerating(true)
    try {
      const res = await fetch("/agent/pair", { method: "POST" })
      if (res.ok) {
        const data = await res.json()
        setPairingCode(data.code)
        setCodeExpiresAt(data.expiresAt)
      } else {
        showToast({ title: "Failed to generate pairing code", variant: "error" })
      }
    } catch {
      showToast({ title: "Failed to generate pairing code", variant: "error" })
    } finally {
      setGenerating(false)
    }
  }

  const disconnect = async () => {
    try {
      const res = await fetch("/agent/disconnect", { method: "POST" })
      if (res.ok) {
        setConnected(false)
        setPairedAt(null)
        showToast({ title: "Remote PC disconnected", variant: "success" })
      }
    } catch {
      showToast({ title: "Failed to disconnect", variant: "error" })
    }
  }

  const copyCode = async () => {
    const code = pairingCode()
    if (code) {
      await navigator.clipboard.writeText(code)
      showToast({ title: "Pairing code copied!", variant: "success" })
    }
  }

  const expiresIn = () => {
    const exp = codeExpiresAt()
    if (!exp) return ""
    const remaining = Math.max(0, Math.floor((exp - Date.now()) / 1000))
    const mins = Math.floor(remaining / 60)
    const secs = remaining % 60
    return mins + "m " + secs + "s"
  }

  return (
    <div class="flex flex-col gap-4 p-4">
      <div class="bg-surface-base px-4 rounded-lg">
        <h2 class="text-16-semibold text-text-primary pt-4 pb-1">{language.t("settings.agentConnect.title")}</h2>
        <p class="text-13-regular text-text-secondary pb-3">{language.t("settings.agentConnect.description")}</p>

        {/* Connection status */}
        <div class="flex items-center gap-2 py-3 border-t border-border-secondary">
          <div class={"w-2 h-2 rounded-full " + (connected() ? "bg-green-500" : "bg-gray-400")} />
          <span class="text-14-regular text-text-secondary">
            {connected()
              ? language.t("settings.agentConnect.connected")
              : language.t("settings.agentConnect.disconnected")}
          </span>
          <Show when={connected() && pairedAt() !== null}>
            <span class="text-12-regular text-text-weak">
              {"(" + language.t("settings.agentConnect.pairedAt") + ": " + new Date(pairedAt()!).toLocaleTimeString() + ")"}
            </span>
          </Show>
        </div>

        {/* Generate pairing code section */}
        <Show when={!connected()}>
          <div class="flex flex-col gap-3 py-3 border-t border-border-secondary">
            <Button variant="primary" onClick={generateCode} disabled={generating()}>
              {generating()
                ? language.t("settings.agentConnect.generating")
                : language.t("settings.agentConnect.generateCode")}
            </Button>

            <Show when={pairingCode() !== null}>
              <div class="flex items-center gap-2 bg-background-secondary rounded-lg py-2 px-3">
                <code class="text-16-mono font-bold tracking-widest text-text-primary flex-1 select-all">
                  {pairingCode()}
                </code>
                <Button variant="ghost" size="small" onClick={copyCode} aria-label={language.t("settings.agentConnect.copy")}>
                  <Icon name="checklist" />
                </Button>
              </div>
              <span class="text-12-regular text-text-weak">
                {language.t("settings.agentConnect.expiresIn") + " " + expiresIn()}
              </span>
            </Show>
          </div>
        </Show>

        {/* Disconnect section */}
        <Show when={connected()}>
          <div class="flex flex-col gap-3 py-3 border-t border-border-secondary">
            <Button variant="secondary" onClick={disconnect}>
              {language.t("settings.agentConnect.disconnect")}
            </Button>
            <p class="text-13-regular text-text-secondary">
              {language.t("settings.agentConnect.connectedHint")}
            </p>
          </div>
        </Show>
      </div>
    </div>
  )
}
