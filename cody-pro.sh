#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BUN=""
if command -v bun &>/dev/null; then
  BUN="bun"
elif [ -f "$HOME/.bun/bin/bun" ]; then
  BUN="$HOME/.bun/bin/bun"
fi

if [ -z "$BUN" ]; then
  echo "Bun was not found."
  echo "Run install.sh from this checkout, or install Bun from https://bun.sh and retry."
  exit 1
fi

# Load proxy from .env.proxy. Fall back to .env for older installs.
if [ -f "$ROOT/.env.proxy" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      [^#]*=*) export "$line" ;;
    esac
  done < "$ROOT/.env.proxy"
elif [ -f "$ROOT/.env" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      [^#]*=*) export "$line" ;;
    esac
  done < "$ROOT/.env"
fi

# Update check with confirmation. Set CODY_SKIP_UPDATE_CHECK=1 to disable.
if [ -d "$ROOT/.git" ] && [ "${CODY_SKIP_UPDATE_CHECK:-0}" != "1" ]; then
  git config --global --add safe.directory "$ROOT" 2>/dev/null || true
  echo "[cody-pro] Checking for updates..."
  branch="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo master)"
  git -C "$ROOT" fetch origin "$branch" --quiet 2>/dev/null || true
  behind="$(git -C "$ROOT" rev-list --count "HEAD..origin/$branch" 2>/dev/null || echo 0)"
  if [ "$behind" != "0" ]; then
    if [ -t 0 ]; then
      printf "[cody-pro] %s update(s) available on origin/%s. Pull now? [y/N] " "$behind" "$branch"
      read -r answer
    else
      answer="${CODY_AUTO_UPDATE:-no}"
    fi
    case "$answer" in
      y|Y|yes|YES)
        git -C "$ROOT" pull --ff-only
        ;;
      *)
        echo "[cody-pro] Update skipped."
        ;;
    esac
  fi
fi

# Auto-fix: strip BOM and repair empty keys in generated config
GENERATED_DIR="$ROOT/.cody/generated"
if [ -d "$GENERATED_DIR" ]; then
  for f in opencode.json opencode.jsonc; do
    cfg="$GENERATED_DIR/$f"
    if [ -f "$cfg" ]; then
      bom=$(xxd -p -l 3 "$cfg" 2>/dev/null || od -A n -t x1 -N 3 "$cfg" 2>/dev/null | tr -d ' \n')
      if [ "$bom" = "efbbbf" ]; then
        tail -c +4 "$cfg" > "${cfg}.tmp" && mv "${cfg}.tmp" "$cfg"
        echo "[cody-pro] Fixed BOM in $f"
      fi
    fi
  done
  legacy="$GENERATED_DIR/opencode.json"
  if [ -f "$legacy" ] && grep -q '""' "$legacy" 2>/dev/null; then
    echo '[cody-pro] Fixed empty key in opencode.json'
    printf '{\n  "$schema": "https://cody.dev/config.json",\n  "model": "cody/big-pickle"\n}\n' > "$legacy"
  fi
fi

export CODY_PRO=1
CODY_DISCOVER_MODELS=1
for arg in "$@"; do
  case "$arg" in
    --help|-h|help|--version|-v|version) CODY_DISCOVER_MODELS=0 ;;
  esac
done

if [ ! -f "$ROOT/.cody/generated/opencode.jsonc" ] || [ "${CODY_REFRESH_MODELS:-0}" = "1" ]; then
  if [ "$CODY_DISCOVER_MODELS" = "1" ]; then
    echo "[cody-pro] Scanning for local Ollama models..."
    if command -v ollama &>/dev/null; then
      ollama list 2>/dev/null | tail -n +2 | while read -r name rest; do
        [ -n "$name" ] && echo "[cody-pro]   found Ollama model: $name"
      done
    else
      echo "[cody-pro]   ollama not found on PATH; skipping model discovery"
    fi
    echo "[cody-pro] Model scanning complete."
  fi
fi

if [ -z "${CODY_CONFIG_DIR:-}" ]; then
  export CODY_CONFIG_DIR="$GENERATED_DIR"
fi

# If arguments provided, run CLI directly
if [ $# -gt 0 ]; then
  exec "$BUN" run --cwd "$ROOT/packages/cody" --conditions=browser src/index.ts "$@"
fi

# Arrow-key launcher menu
SCRIPT_DIR="$ROOT/script"
selected=0
if [ -f "$SCRIPT_DIR/launcher.sh" ]; then
  set +e
  bash "$SCRIPT_DIR/launcher.sh"
  selected=$?
  set -e
fi

case "$selected" in
  255) exit 0 ;;
  1)
    echo "[cody-pro] Building web UI..."
    "$BUN" run --cwd "$ROOT/packages/app" build
    echo "[cody-pro] Starting web UI..."
    pushd "$ROOT" >/dev/null
    "$BUN" run cody-pro web
    popd >/dev/null
    ;;
  *)
    exec "$BUN" run --cwd "$ROOT/packages/cody" --conditions=browser src/index.ts
    ;;
esac
