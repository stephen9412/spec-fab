#!/bin/sh

root_warning() {
    # Check if running as root (uid 0)
    if [ "$(id -u)" -eq 0 ]; then
        echo "⚠️  Warning: Detected that you are running this script as root (sudo)."
        echo ""
        echo "   This project is recommended to run in User Space."
        echo "   Unless you know exactly what you're doing:"
        echo "👉 Please press Ctrl + C to abort, remove 'sudo' and try again."
        echo ""
        
        # Interactive confirmation
        printf "Are you sure you want to continue as root? [y/N] "
        read -r response
        
        # Convert to lowercase and check
        case "$response" in
            [yY][eE][sS]|[yY]) 
                echo "🚀 Continuing as root..."
                ;;
            *)
                echo "Aborted."
                exit 1
                ;;
        esac
    fi
}

install_fish() {
    echo "🔍 Looking for a suitable package manager..."

    # 1. macOS (brew, port, nix)
    if [ "$(uname -s)" = "Darwin" ]; then
        echo "🍎 Detected macOS..."
        
        if command -v brew >/dev/null 2>&1; then
            echo "🍺 Detected Homebrew, installing fish..."
            brew install fish
            return 0
        elif command -v port >/dev/null 2>&1; then
            echo "🍷 Detected MacPorts, installing fish..."
            sudo port install fish
            return 0
        elif command -v nix-env >/dev/null 2>&1; then
            echo "❄️  Detected Nix, installing fish via nix profile..."
            nix profile add nixpkgs#fish
            return 0
        else
            echo "❌ macOS detected but no package manager found."
            echo "💡 We recommend installing Homebrew (a must-have tool for Mac). Please copy and run the following command:"
            echo ""
            echo '    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
            echo ""
            echo "📋 Note: During installation, you will be asked for your **sudo password** (your login password)."
            echo "    Nothing will appear on screen while typing. Just type it and press Enter."
            echo "    After installation, please re-run this script."
            return 1
        fi
    fi

    # 2. Arch / CachyOS (pacman)
    if command -v pacman &> /dev/null; then
        echo "🏹 Detected pacman, installing fish..."
        sudo pacman -S --noconfirm fish
        return 0
    fi

    # 3. Ubuntu / Debian (apt)
    if command -v apt-get &> /dev/null; then
        echo "🌀 Detected apt, installing fish..."
        sudo apt-get update && sudo apt-get install -y fish
        return 0
    fi

    # 4. Fedora / RHEL (dnf)
    if command -v dnf &> /dev/null; then
        echo "🎩 Detected dnf, installing fish..."
        sudo dnf install -y fish
        return 0
    fi

    # 5. Alpine (apk)
    if command -v apk &> /dev/null; then
        echo "🏔️  Detected apk, installing fish..."
        sudo apk add fish
        return 0
    fi

    # 6. NixOS (nix)
    if command -v nix &> /dev/null; then
        echo "❄️  Detected nix, installing fish..."
        nix profile add nixpkgs#fish
        return 0
    fi

    echo "❌ No supported package manager found. Please install fish manually."
    return 1
}

init_fish() {
    # 1. Ensure Fish exists
    if ! command -v fish >/dev/null 2>&1; then
        install_fish
    else
        echo "✅ Fish shell is already installed."
    fi

    # 2. Create directory structure
    FISH_CONFIG_DIR="$HOME/.config/fish"
    mkdir -p "$FISH_CONFIG_DIR/conf.d"
    mkdir -p "$FISH_CONFIG_DIR/functions"
    mkdir -p "$FISH_CONFIG_DIR/completions"

    # 3. Ensure config.fish exists
    CONFIG_FILE="$FISH_CONFIG_DIR/config.fish"
    if [ ! -f "$CONFIG_FILE" ]; then
        touch "$CONFIG_FILE"
        echo "📝 Created missing config.fish at $CONFIG_FILE"
    else
        echo "✅ config.fish already exists."
    fi
}

download_tar() {
    # $1: Download URL
    # $2: Target Path
    _url="$1"
    _target="$2"

    echo "🌐 Downloading file from $_url..."

    if command -v curl >/dev/null 2>&1; then
        # -s: Silent mode
        # -L: Follow redirects (required for GitHub Releases)
        # -f: Important! If server returns 404, curl will return error code instead of empty file
        if curl -sLf "$_url" -o "$_target"; then
            return 0
        fi
    elif command -v wget >/dev/null 2>&1; then
        # -q: Quiet mode
        # -O: Specify output path
        if wget -qO "$_target" "$_url"; then
            return 0
        fi
    else
        echo "❌ Fatal error: Neither curl nor wget found in system, cannot proceed with download."
        return 1
    fi

    echo "❌ Download failed!"
    echo "   Target URL: $_url"
    echo "   Please check your network connection, or verify that the file exists."
    return 1
}

install_project_fabric() {
    # 1. Create private directory
    # Per your specific requirements, install everything into hidden folder
    PROJECT_BIN_DIR="$HOME/.specfab/bin"
    mkdir -p "$PROJECT_BIN_DIR"

    # 2. Detect environment and normalize (to match GitHub Asset names)
    RAW_OS=$(uname -s)
    RAW_ARCH=$(uname -m)
    
    case "$RAW_OS" in
        Darwin) OS="Darwin" ;;
        Linux)  
            OS="Linux"
            if uname -r | grep -qiE "microsoft|wsl"; then
                echo "🪟 Oh! WSL environment detected..."
                echo "   Looks like you've escaped the clutches of Windows. Welcome to the free world of Linux! 🐧"
                echo ""
            fi
            ;;
        *)      
            echo "❌ This installation script only supports Darwin (macOS), Linux and WSL systems."
            return 1 
            ;;
    esac

    # Handle architecture strings
    case "$RAW_ARCH" in
        x86_64)         ARCH="x86_64" ;;
        arm64|aarch64)  ARCH="arm64" ;;
        i386|i686)      ARCH="i386" ;;
        *)              echo "❌ Architecture $RAW_ARCH not supported by Fabric assets."; return 1 ;;
    esac

    # 3. Build download URL
    # Using latest/download always fetches the latest version
    FILE_NAME="fabric_${OS}_${ARCH}.tar.gz"
    DOWNLOAD_URL="https://github.com/danielmiessler/fabric/releases/latest/download/${FILE_NAME}"
    TEMP_FILE="/tmp/${FILE_NAME}"

    echo "📥 Downloading Fabric for ${OS} ${ARCH}..."

    # 4. Download Fabric
    download_tar "$DOWNLOAD_URL" "$TEMP_FILE" || return 1

    # 5. Extract and cleanup
    echo "📦 Extracting to $PROJECT_BIN_DIR..."
    # -C specifies extraction path, usually contains only one executable named fabric
    tar -xzf "$TEMP_FILE" -C "$PROJECT_BIN_DIR" fabric 2>/dev/null || \
    tar -xzf "$TEMP_FILE" -C "$PROJECT_BIN_DIR" # Fallback: extract all
    rm "$TEMP_FILE"

    # 6. Ensure permissions
    chmod +x "$PROJECT_BIN_DIR/fabric"

    echo "✅ Fabric is now isolated at: $PROJECT_BIN_DIR/fabric"
}

setup_fabric_interaction() {
    FABRIC_BIN="$HOME/.specfab/bin/fabric"
    FABRIC_CONFIG_DIR="$HOME/.config/fabric"
    ENV_FILE="$FABRIC_CONFIG_DIR/.env"

    echo "🔍 Checking Fabric configuration status..."

    if [ -f "$ENV_FILE" ]; then
        echo "✅ Existing Fabric configuration detected ($ENV_FILE)."
        echo "   Skipping initialization setup."
        return 0
    fi

    # --- 1. Motivational Speech ---
    echo ""
    echo "🏁 ========================================================"
    echo "🏁  Just One More Step: Give SpecFab Its Soul"
    echo "🏁 ========================================================"
    echo ""
    echo "   The skeleton of SpecFab is installed. Now it needs a \"brain\" to think."
    echo "   We will guide you through setting up the AI service to activate it."
    echo ""
    echo "🔑 Please have one of your API Keys ready (any one will do):"
    echo "   - OpenRouter Key (🔥 Highly recommended! One key for all free/paid models)"
    echo "   - OpenAI Key (ChatGPT)"
    echo "   - Anthropic Key (Claude)"
    echo "   - Other (Gemini, Groq, Mistral, Local LLMs, etc.)"

    # --- 1.5 Warning: Size Matters (New Section) ---
    echo ""
    echo "⚠️  CRITICAL ADVICE: DON'T USE \"TOY\" MODELS"
    echo "   SpecFab performs complex reasoning tasks. Using small/local models"
    echo "   (like 2B, 7B, or 8B parameters) will likely result in failure."
    echo ""
    echo "   🚫 Please DO NOT open GitHub Issues if you are using a < 70B model."
    echo "      (If it breaks, it's not the code; the model is just not smart enough.)"
    echo ""
    echo "   ✅ Strong Recommendation: Use Gemini 3 Pro, Claude 4.5 Sonnet, or GPT-5."

    # --- 2. Cheat Sheet for Newbies (English Ver.) ---
    echo ""
    echo "🔰 ========================================================"
    echo "🔰  Quick Start / Cheat Sheet (Experts can skip this)"
    echo "🔰 ========================================================"
    echo "   You are about to see a HUGE list of options."
    echo "   If you feel overwhelmed, simply follow this guide:"
    echo ""
    echo "   1️⃣  [Select AI Provider] (When you see 'Available AI Providers'):"
    echo "       - Use OpenRouter (Recommended)  -> Type 24"
    echo "       - Use OpenAI                    -> Type 23"
    echo "       - Use Anthropic (Claude)        -> Type 3"
    echo "       - Use Gemini                    -> Type 10"
    echo ""
    echo "   2️⃣  [Select Model] (If you chose OpenRouter, looking at 'Available models'):"
    echo "       - 💰 I want the BEST / Paid     -> Type 84 (Google Gemini 3 Pro)"
    echo "       - 🆓 I want FREE / Just testing -> Type 8  (AllenAI Molmo 2 Free)"
    echo ""
    echo "   (Note: Numbers may shift slightly with updates. Please double-check your screen!)"
    echo "============================================================"
    echo ""

    # --- 3. Launch ---
    printf "👉 Ready for takeoff? Press [Enter] to start setup (or Ctrl+C to do it later)... "
    read -r _dummy

    echo "🚀 Launching Fabric setup wizard..."
    "$FABRIC_BIN" --setup

    # 4. Verify results
    echo ""
    echo "🔍 Verifying setup results..."
    
    if [ -f "$ENV_FILE" ]; then
        echo "✅ Configuration file created! Awesome!"
    else
        echo "⚠️  Warning: We didn't see $ENV_FILE being created."
        echo "   You may have skipped the setup, or it failed."
        echo "   No worries, you can always type 'fabric --setup' in Fish to try again."
    fi
}

setup_user_path() {
    BIN_DIR="$HOME/.specfab/bin"
    
    # Detect user's current shell configuration file
    SHELL_RC=""
    case "$SHELL" in
        */zsh) SHELL_RC="$HOME/.zshrc" ;;
        */bash) SHELL_RC="$HOME/.bashrc" ;;
        */fish) return 0 ;;
        *) ;; # Other shells are left alone, show manual instructions
    esac

    echo ""
    echo "🔌 Path Configuration (Crucial Step)"
    
    # Check if PATH already contains our bin
    case ":$PATH:" in
        *":$BIN_DIR:"*)
            echo "✅ Great! $BIN_DIR is already in your PATH."
            ;;
        *)
            echo "⚠️  Your system doesn't know where SpecFab is yet."
            
            if [ -n "$SHELL_RC" ] && [ -f "$SHELL_RC" ]; then
                echo "   I can verify and append this to your $SHELL_RC:"
                echo "   👉 export PATH=\"\$HOME/.specfab/bin:\$PATH\""
                echo ""
                printf "   Do you want me to do this automatically? [y/N] "
                read -r response
                case "$response" in
                    [yY]|[yY][eE][sS]) 
                        echo "" >> "$SHELL_RC"
                        echo "# Added by SpecFab Installer" >> "$SHELL_RC"
                        echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$SHELL_RC"
                        echo "✅ Added to $SHELL_RC. Please restart your terminal."
                        ;;
                    *)
                        echo "👌 OK. Please add it manually to use 'spec_new' and 'fabric'."
                        ;;
                esac
            else
                echo "   Please add the following line to your shell configuration:"
                echo "   export PATH=\"$BIN_DIR:\$PATH\""
            fi
            ;;
    esac
}

main() {
    echo "🔮 Starting SpecFab Installation..."
    root_warning

    RAW_OS=$(uname -s)
    case "$RAW_OS" in
        FreeBSD)
            echo ""
            echo "😈 Wow! A distinguished FreeBSD user!"
            echo "   You've chosen a unique and hardcore path. You must have high standards for system stability and elegance,"
            echo "   or this machine serves some sacred and inviolable special mission..."
            echo ""
            echo "🐟 Although I've done my best to install Fish Shell for you, but..."
            echo "😱 Unfortunately, the upstream Fabric project does not currently provide FreeBSD binaries."
            echo "   (This is definitely not your fault - the world just hasn't caught up with you yet!)"
            echo ""
            echo "👉 If you'd like to change this, please open an Issue at the following repositories (show the power of the BSD community!):"
            echo "   1. https://github.com/stephen9412/spec-fab"
            echo "   2. https://github.com/danielmiessler/Fabric"
            echo ""
            return 1 
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo "🪟 Detected Windows emulation environment (Git Bash/MinGW/Cygwin)..."
            echo ""
            echo "🧐 While technically Fish can be installed here (pacman -S fish),"
            echo ""
            echo "👉 For your sanity, we strongly recommend enabling WSL2 (Windows Subsystem for Linux)."
            echo "   There you'll have a real Linux Kernel, not these clunky emulators."
            echo ""
            echo "🚫 Script aborted (refusing to run in emulation environment)."
            return 1
            ;;
    esac

    # 0. check git
    if ! command -v git >/dev/null 2>&1; then
        echo "❌ git not found in system. This is too basic. Please install git first."
        return 1
    fi

    # 1. init fish
    init_fish
    hash -r 2>/dev/null

    # 2. clone git repo
    SPEC_FAB_DIR="$HOME/.specfab"
    if [ -d "$SPEC_FAB_DIR/.git" ]; then
        echo "Updating SpecFab..."
        cd "$SPEC_FAB_DIR" && git pull
    else
        git clone https://github.com/stephen9412/spec-fab.git "$SPEC_FAB_DIR"
    fi

    # 3. install fabric
    install_project_fabric

    # 4. Create Fish startup hook (injection mode)
    SPEC_FAB_BOOTSTRAP="$HOME/.config/fish/conf.d/spec_fab.fish"
    echo "🔗 Linking SpecFab to Fish via $SPEC_FAB_BOOTSTRAP..."

    cat << 'EOF' > "$SPEC_FAB_BOOTSTRAP"
# SpecFab Auto-generated Bootstrap
set -l spec_fab_root "$HOME/.specfab"

# 1. Auto-load private bin to PATH (allows fabric to be called directly)
if test -d "$spec_fab_root/bin"
    if not contains "$spec_fab_root/bin" $PATH
        set -p PATH "$spec_fab_root/bin"
    end
end

# 2. Inject custom Functions path (highest priority)
if test -d "$spec_fab_root/fish/functions"
    set -p fish_function_path "$spec_fab_root/fish/functions"
end

# 3. Initialize default Universal configuration
if not set -q SPEC_FAB_AUTO_EDIT
    set -U SPEC_FAB_AUTO_EDIT 'ask'
end
EOF

     # 5. setup fabric interaction
    setup_fabric_interaction

    # 6. setup user path
    setup_user_path

    echo ""
    echo "👏👏👏 STANDING OVATION! 👏👏👏"
    echo "SpecFab is officially alive and ready for action."
    echo ""
    echo "If you're not sure how to kick off your first mission, check out the guide here:"
    echo "👉 https://github.com/stephen9412/spec-fab/blob/main/README.md"
    echo ""
    echo "Final Steps:"
    echo "   1. Restart your terminal (or type 'fish') to activate the environment."
    echo "   2. Type 'fabric -h' to verify the AI brain is twitching."
    echo "   3. Type 'spec_doctor' for a full system health check."
    echo ""
    echo "Go forth and start building something great!"
}

# Start program
main "$@"
