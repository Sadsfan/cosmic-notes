#!/bin/bash
echo "🚀 Installing Cosmic Notes locally..."

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

echo "✅ Cosmic Notes installed locally!"
echo "Find it in your applications menu or run: cosmic-notes-applet"
