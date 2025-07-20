#!/bin/bash
# Cosmic Notes - Quick Install Script

set -e

echo "🚀 Installing Cosmic Notes..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check for apt
if ! command -v apt &> /dev/null; then
    echo -e "${RED}Error: This installer requires apt package manager${NC}"
    exit 1
fi

# Install dependencies
echo -e "${YELLOW}📦 Installing system dependencies...${NC}"
sudo apt update
sudo apt install -y build-essential pkg-config libgtk-4-dev libadwaita-1-dev curl git

# Install Rust if needed
if ! command -v cargo &> /dev/null; then
    echo -e "${YELLOW}🦀 Installing Rust...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
fi

# Clone and build
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo -e "${YELLOW}📥 Downloading Cosmic Notes...${NC}"
git clone https://github.com/Sadsfan/cosmic-notes.git
cd cosmic-notes

echo -e "${YELLOW}🔨 Building Cosmic Notes...${NC}"
cargo build --release

echo -e "${YELLOW}📦 Installing Cosmic Notes...${NC}"
mkdir -p ~/.local/bin ~/.local/share/applications
cp target/release/cosmic-notes-applet ~/.local/bin/
chmod +x ~/.local/bin/cosmic-notes-applet

# Create launcher wrapper
cat > ~/.local/bin/cosmic-notes-launcher << 'LAUNCHER_EOF'
#!/bin/bash
exec "$HOME/.local/bin/cosmic-notes-applet" "$@"
LAUNCHER_EOF
chmod +x ~/.local/bin/cosmic-notes-launcher

# Create desktop entry
cat > ~/.local/share/applications/cosmic-notes.desktop << 'DESKTOP_EOF'
[Desktop Entry]
Type=Application
Name=Cosmic Notes
Comment=Quick notes app for Cosmic desktop
Icon=accessories-text-editor
Exec=/home/$USER/.local/bin/cosmic-notes-launcher
Categories=Utility;Office;
Keywords=notes;memo;text;quick;cosmic;
StartupNotify=true
Terminal=false
StartupWMClass=cosmic-notes-applet
DESKTOP_EOF

update-desktop-database ~/.local/share/applications/ 2>/dev/null || true

# Cleanup
cd && rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}✅ Cosmic Notes installed successfully!${NC}"
echo ""
echo -e "${BLUE}You can now:${NC}"
echo -e "  • Find it in your applications menu${NC}"
echo -e "  • Run it from terminal: ${YELLOW}cosmic-notes-applet${NC}"
echo ""
echo -e "${GREEN}🎉 Enjoy taking notes with Cosmic Notes!${NC}"
echo ""
echo -e "${BLUE}💾 Your notes are saved to: ~/.config/cosmic-notes/notes.json${NC}"
