#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/your-org/cody.git"
DEFAULT_ROOT="${HOME:-~}/.local/share/cody_pro"
BRANCH="${CODY_BRANCH:-main}"
INSTALLER_URL="https://raw.githubusercontent.com/mufasa1611/cody_pro/$BRANCH/install.sh"

# ---- Self-update check ----
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
if [ "${CODY_INSTALLER_SELF_UPDATE:-1}" != "0" ] && [ -z "${CODY_INSTALLER_SELF_UPDATED:-}" ] && [ -f "$SCRIPT_PATH" ]; then
  TMP_INSTALLER="$(mktemp)"
  if curl -fsSL "$INSTALLER_URL" -o "$TMP_INSTALLER" 2>/dev/null; then
    if ! cmp -s "$SCRIPT_PATH" "$TMP_INSTALLER"; then
      echo "[info] New installer found. Running latest installer from GitHub..."
      export CODY_INSTALLER_SELF_UPDATED=1
      exec bash "$TMP_INSTALLER" "$@"
    fi
    echo "[ok] Installer is up to date."
  else
    echo "[warn] Could not download latest installer. Continuing with current."
  fi
  rm -f "$TMP_INSTALLER"
fi

# ---- Help ----
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  echo "Cody Pro Installer for Linux/macOS"
  echo ""
  echo "Usage: curl -fsSL https://raw.githubusercontent.com/mufasa1611/cody_pro/$BRANCH/install.sh | bash"
  echo ""
  echo "Environment variables:"
  echo "  CODY_INSTALL_ROOT   Install to a custom path instead of $DEFAULT_ROOT"
  echo "  CODY_BRANCH         Install from a branch, default: $BRANCH"
  echo "  CODY_INSTALLER_SELF_UPDATE Set to 0 to skip installer self-update"
  echo "  (interactive model scan offered at end of install)"
  exit 0
fi

# ---- OS detection ----
OS="$(uname -s)"
ARCH="$(uname -m)"
echo "Cody Pro installer for $OS ($ARCH)"

case "$OS" in
  Linux) ;;
  Darwin) ;;
  *)
    echo "[error] Unsupported OS: $OS. This installer supports Linux and macOS."
    echo "  For Windows, use install.ps1 instead."
    exit 1
    ;;
esac

# ---- Dependency installation ----
INSTALL_CMD=""
UPDATE_CMD=""
case "$OS" in
  Linux)
    if command -v pkg &>/dev/null; then
      INSTALL_CMD="pkg install -y"
      UPDATE_CMD="pkg update -y"
    elif command -v apt-get &>/dev/null; then
      INSTALL_CMD="apt-get install -y"
      UPDATE_CMD="apt-get update -y"
    elif command -v dnf &>/dev/null; then
      INSTALL_CMD="dnf install -y"
      UPDATE_CMD="dnf check-update || true"
    elif command -v pacman &>/dev/null; then
      INSTALL_CMD="pacman -S --noconfirm"
      UPDATE_CMD="pacman -Syu --noconfirm"
    elif command -v zypper &>/dev/null; then
      INSTALL_CMD="zypper install -y"
      UPDATE_CMD="zypper refresh"
    fi
    ;;
  Darwin)
    if command -v brew &>/dev/null; then
      INSTALL_CMD="brew install"
    fi
    ;;
esac

install_dep() {
  local name="$1" pkg="$2"
  if command -v "$name" &>/dev/null; then
    echo "[ok] $name found."
    return 0
  fi
  if [ -n "$INSTALL_CMD" ]; then
    echo "[info] Installing $name..."
    if [ -n "$UPDATE_CMD" ]; then
      $UPDATE_CMD 2>/dev/null || true
    fi
    if [ "$OS" = "Darwin" ]; then
      $INSTALL_CMD "$pkg"
    else
      if [ "$(id -u)" -ne 0 ]; then
        sudo $INSTALL_CMD "$pkg"
      else
        $INSTALL_CMD "$pkg"
      fi
    fi
    if ! command -v "$name" &>/dev/null; then
      echo "[error] Failed to install $name."
      echo "  Install it manually and rerun this installer."
      exit 1
    fi
    echo "[ok] $name installed."
  else
    echo "[error] $name is required."
    echo "  Install $name manually and rerun this installer."
    exit 1
  fi
}

install_dep "git" "git"

if ! command -v curl &>/dev/null; then
  install_dep "curl" "curl"
fi

# ---- Determine install root ----
ROOT="${CODY_INSTALL_ROOT:-}"
if [ -z "$ROOT" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -f "$SCRIPT_DIR/package.json" ] && grep -q '"name".*"cody-pro"' "$SCRIPT_DIR/package.json" 2>/dev/null; then
    ROOT="$SCRIPT_DIR"
  else
    ROOT="$DEFAULT_ROOT"
  fi
fi

echo "Install target: $ROOT"

# ---- Clone or update ----
check_is_repo() {
  [ -f "$1/package.json" ] && grep -q '"name".*"cody-pro"' "$1/package.json" 2>/dev/null
}

if ! check_is_repo "$ROOT"; then
  echo "Cody Pro checkout not found. Cloning from GitHub..."
  PARENT="$(dirname "$ROOT")"
  mkdir -p "$PARENT"
  if [ -d "$ROOT" ] && [ "$(ls -A "$ROOT" 2>/dev/null)" ]; then
    echo "[error] $ROOT exists but is not a Cody Pro checkout."
    echo "  Move it away or set CODY_INSTALL_ROOT, then rerun."
    exit 1
  fi
  git clone --branch "$BRANCH" "$REPO_URL" "$ROOT" || git clone "$REPO_URL" "$ROOT"
  echo "[ok] Cloned to $ROOT"
fi

git config --global --add safe.directory "$ROOT" 2>/dev/null || true

if [ -d "$ROOT/.git" ]; then
  CURRENT_BRANCH="$(git -C "$ROOT" branch --show-current 2>/dev/null || true)"
  if [ -n "$CURRENT_BRANCH" ] && [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
    echo "Switching Cody Pro checkout from $CURRENT_BRANCH to $BRANCH..."
    if git -C "$ROOT" fetch origin "$BRANCH"; then
      git -C "$ROOT" switch "$BRANCH" || {
        echo "[error] Could not switch to $BRANCH."
        echo "  Back up or commit local changes in $ROOT, then rerun the installer."
        exit 1
      }
    else
      echo "[error] Could not fetch branch $BRANCH."
      exit 1
    fi
  fi
  echo "Updating Cody Pro checkout..."
  git -C "$ROOT" pull --ff-only 2>/dev/null || echo "[warn] git pull failed; continuing with current checkout."
fi

cd "$ROOT"

# ---- Install Bun ----
install_bun() {
  echo "[info] Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
  if [ -f "$HOME/.bun/bin/bun" ]; then
    export PATH="$HOME/.bun/bin:$PATH"
    echo "[ok] Bun installed."
  else
    echo "[error] Bun installation did not produce a usable bun command."
    exit 1
  fi
}

BUN=""
if command -v bun &>/dev/null; then
  BUN="bun"
elif [ -f "$HOME/.bun/bin/bun" ]; then
  BUN="$HOME/.bun/bin/bun"
  export PATH="$HOME/.bun/bin:$PATH"
fi

if [ -z "$BUN" ]; then
  install_bun
fi

echo "[ok] Bun: $("$BUN" --version 2>/dev/null || echo "$BUN")"

# ---- bun install ----
echo "Installing Cody Pro dependencies..."
set +e
"$BUN" install
BUN_EXIT=$?
set -e
if [ $BUN_EXIT -ne 0 ]; then
  echo ""
  echo "[warn] Bun install failed (exit code $BUN_EXIT). Retrying with --no-optional..."
  set +e
  "$BUN" install --no-optional
  BUN_RETRY_EXIT=$?
  set -e
  if [ $BUN_RETRY_EXIT -ne 0 ]; then
    echo ""
    echo "[error] Bun install failed again (exit code $BUN_RETRY_EXIT)."
    echo "  This project has many dependencies (~2700 packages) and may need more memory."
    echo "  Try one of these:"
    echo "    1. Increase your swap space, then rerun"
    echo "    2. Run:  $BUN install --frozen-lockfile"
    echo "  Then rerun this installer."
    exit 1
  fi
  echo "[ok] Dependencies installed with --no-optional."
fi

# ---- Build Web UI ----
echo "Building Web UI..."
set +e
"$BUN" run --cwd "$ROOT/packages/app" build
BUILD_EXIT=$?
set -e
if [ $BUILD_EXIT -ne 0 ]; then
  echo "[warn] Web UI build failed; server will proxy to app.opencode.ai."
fi

# ---- Create proxy config ----
if [ ! -f "$ROOT/.env.proxy" ]; then
  echo "Creating .env.proxy with proxy settings..."
  cat > "$ROOT/.env.proxy" << 'ENVEOF'
CODY_PROXY_ENABLED=1
HTTPS_PROXY=http://192.168.68.68:8888
HTTP_PROXY=http://192.168.68.68:8888
NO_PROXY=localhost,127.0.0.1,::1
ENVEOF
  echo "[ok] .env.proxy created."
else
  if ! grep -q "^NO_PROXY=" "$ROOT/.env.proxy" 2>/dev/null; then
    echo "" >> "$ROOT/.env.proxy"
    echo "NO_PROXY=localhost,127.0.0.1,::1" >> "$ROOT/.env.proxy"
    echo "[ok] Added NO_PROXY to existing .env.proxy."
  fi
fi

# ---- Create config directory structure ----
# Ensure .cody/generated exists so first launch doesn't error
mkdir -p "$ROOT/.cody/generated"
DEFAULT_CONFIG="$ROOT/.cody/generated/opencode.json"
if [ ! -f "$DEFAULT_CONFIG" ]; then
  cat > "$DEFAULT_CONFIG" << 'JSONEOF'
{
  "$schema": "https://cody.dev/config.json",
  "model": "cody/big-pickle",
  "provider": {
    "cody": {
      "models": {
        "big-pickle": {
          "name": "Big Pickle",
          "reasoning": true,
          "tool_call": true,
          "temperature": true,
          "cost": { "input": 0, "output": 0 },
          "limit": { "context": 200000, "output": 128000 }
        }
      }
    }
  }
}
JSONEOF
  echo "[ok] Default model configured: cody/big-pickle"
fi

# ---- Install global cody_pro command ----
GLOBAL_BIN_DIR="${XDG_DATA_HOME:-$HOME/.local}/bin"
mkdir -p "$GLOBAL_BIN_DIR"

CODY_SHIM="$GLOBAL_BIN_DIR/cody_pro"
if [ ! -f "$CODY_SHIM" ]; then
  cat > "$CODY_SHIM" << SHIMEOF
#!/usr/bin/env bash
export CODY_ROOT="$ROOT"
if [ -f "\$CODY_ROOT/.env.proxy" ]; then
  while IFS= read -r line || [ -n "\$line" ]; do
    case "\$line" in
      [^#]*=*) export "\$line" ;;
    esac
  done < "\$CODY_ROOT/.env.proxy"
elif [ -f "\$CODY_ROOT/.env" ]; then
  while IFS= read -r line || [ -n "\$line" ]; do
    case "\$line" in
      [^#]*=*) export "\$line" ;;
    esac
  done < "\$CODY_ROOT/.env"
fi
exec "\$CODY_ROOT/cody-pro.sh" "\$@"
SHIMEOF
  chmod +x "$CODY_SHIM"
  echo "[ok] Created global command: $CODY_SHIM"
fi

# Add to PATH suggestion if not already present
case ":$PATH:" in
  *":$GLOBAL_BIN_DIR:"*) ;;
  *)
    echo ""
    echo "  Note: $GLOBAL_BIN_DIR is not on your PATH."
    echo "  Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
    echo "    export PATH=\"\$PATH:$GLOBAL_BIN_DIR\""
    ;;
esac

# Make cody-pro.sh executable
chmod +x "$ROOT/cody-pro.sh"
chmod +x "$ROOT/script/launcher.sh"

# Also add a symlink in /usr/local/bin if we have sudo, as convenience
if [ "$(id -u)" -eq 0 ]; then
  ln -sf "$CODY_SHIM" "/usr/local/bin/cody_pro" 2>/dev/null || true
elif command -v sudo &>/dev/null; then
  sudo ln -sf "$CODY_SHIM" "/usr/local/bin/cody_pro" 2>/dev/null || true
fi

echo ""
echo "=========================================="
echo "  Cody Pro (proxy-enabled) is installed!"
echo "=========================================="
echo ""
echo "  Start it with:"
echo "    cody_pro"
echo ""
echo "  To update proxy settings, edit:"
echo "    $ROOT/.env.proxy"
echo ""
echo "  First time setup:"
echo "    1. Open a new terminal (or source your profile)"
echo "    2. Run:  cody_pro"
echo "    3. Use arrow keys to select CLI (TUI) or Web UI"
echo ""

# --- Interactive local model scan (final step) ---
echo ""
echo "---"
echo "Do you have Ollama or local GGUF models to scan?"
echo "  (scans your drives to auto-configure local AI models)"
read -rp "  [Y/n] " ANSWER
if [ -z "$ANSWER" ] || echo "$ANSWER" | grep -qi '^y'; then
  echo ""
  echo "Scanning for local models..."
  
  # Count mount points/drives
  if command -v df &>/dev/null; then
    DRIVE_COUNT=$(df -h 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
    DRIVE_LIST=$(df -h 2>/dev/null | tail -n +2 | awk '{print $1}' | head -5 | tr '\n' ', ' | sed 's/,$//')
    echo "  Found $DRIVE_COUNT mount point(s): $DRIVE_LIST"
  fi
  echo ""
  
  # Run discovery with single-line progress
  export CODY_MODEL_DISCOVERY_QUIET=1
  export CODY_MODEL_SCAN_MAX_SECONDS=30
  
  # Start discovery in background
  if [ -f "$ROOT/script/discover-local-models.sh" ]; then
    bash "$ROOT/script/discover-local-models.sh" --root "$ROOT" --max-seconds 30 &
    DISCOVERY_PID=$!
  elif command -v ollama &>/dev/null; then
    # Fallback: simple ollama scan
    ollama list 2>/dev/null > "$ROOT/.cody/generated/ollama-models.txt" &
    DISCOVERY_PID=$!
  else
    DISCOVERY_PID=0
  fi
  
  # Single-line progress
  DOTS=0
  while kill -0 $DISCOVERY_PID 2>/dev/null; do
    DOTS=$(( (DOTS + 1) % 4 ))
    BAR=$(printf '%*s' $DOTS '' | tr ' ' '.')
    BAR="$BAR$(printf '%*s' $((3 - DOTS)) '' | tr ' ' ' ')"
    printf "\r  Scanning[%s] running" "$BAR"
    sleep 0.5
  done
  wait $DISCOVERY_PID 2>/dev/null
  
  # Show results
  REPORT="$ROOT/.cody/generated/cody-local-models.report.json"
  OLLAMA_FILE="$ROOT/.cody/generated/ollama-models.txt"
  if [ -f "$REPORT" ]; then
    OLLAMA_COUNT=$(grep -o '"ollamaModelCount":[0-9]*' "$REPORT" 2>/dev/null | cut -d: -f2 || echo "0")
    GGUF_COUNT=$(grep -o '"ggufModelCount":[0-9]*' "$REPORT" 2>/dev/null | cut -d: -f2 || echo "0")
    TOTAL=$((OLLAMA_COUNT + GGUF_COUNT))
    if [ "$TOTAL" -gt 0 ]; then
      printf "\r[ok] Found $TOTAL local models ($OLLAMA_COUNT Ollama, $GGUF_COUNT GGUF)\n"
      echo "  Models will be available in Cody Pro provider list."
    else
      printf "\r[info] No local models found.\n"
      echo "  Install Ollama or download GGUF files to use local models."
    fi
  elif [ -f "$OLLAMA_FILE" ] && [ -s "$OLLAMA_FILE" ]; then
    OLLAMA_COUNT=$(wc -l < "$OLLAMA_FILE" | tr -d ' ')
    printf "\r[ok] Found $OLLAMA_COUNT Ollama model(s)\n"
    echo "  Models will be available in Cody Pro provider list."
  else
    printf "\r[info] No local models found.\n"
    echo "  Install Ollama or download GGUF files to use local models."
  fi
else
  echo "[info] Local model scan skipped. Run later with:"
  echo "  bash $ROOT/script/discover-local-models.sh"
fi
