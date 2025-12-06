#!/bin/bash
# rename_to_upod.sh
# Rename PodPhoenix to uPod - Mac compatible version

echo "🔄 Renaming PodPhoenix to uPod..."
echo ""

# Check if we're in the right directory
if [ ! -f "manifest.json.in" ]; then
    echo "❌ Error: manifest.json.in not found"
    echo "Please run this script from the root of the upod repository"
    exit 1
fi

echo "📁 Working directory: $(pwd)"
echo ""

# Backup option
read -p "Create backup before renaming? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "💾 Creating backup..."
    tar -czf "../upod-backup-$(date +%Y%m%d-%H%M%S).tar.gz" .
    echo "✓ Backup created in parent directory"
fi

echo ""
echo "🔧 Step 1: Renaming files..."

# Rename apparmor file
if [ -f "Podphoenix.apparmor" ]; then
    mv Podphoenix.apparmor uPod.apparmor
    echo "  ✓ Renamed Podphoenix.apparmor → uPod.apparmor"
fi

# Create uPod.desktop if it doesn't exist
if [ ! -f "upod.desktop" ] && [ -f "podphoenix.desktop" ]; then
    mv podphoenix.desktop upod.desktop
    echo "  ✓ Renamed podphoenix.desktop → upod.desktop"
fi

echo ""
echo "🔧 Step 2: Updating file contents (this may take a moment)..."

# Use sed with Mac-compatible syntax (BSD sed requires different flags)
# Create a temporary suffix for backup files
BACKUP_SUFFIX=".bak_tmp"

# Find all relevant files and replace text
# Exclude .git directory and binary files
find . -type f \( \
    -name "*.json" -o \
    -name "*.json.in" -o \
    -name "*.yaml" -o \
    -name "*.yml" -o \
    -name "*.txt" -o \
    -name "*.cmake" -o \
    -name "*.qml" -o \
    -name "*.cpp" -o \
    -name "*.h" -o \
    -name "*.desktop" -o \
    -name "*.apparmor" -o \
    -name "CMakeLists.txt" -o \
    -name "*.md" \
\) -not -path "*/\.git/*" -not -path "*/build/*" | while read file; do
    # Mac sed requires -i with extension, even if empty
    sed -i "$BACKUP_SUFFIX" \
        -e 's/podphoenix/upod/g' \
        -e 's/Podphoenix/uPod/g' \
        -e 's/PodPhoenix/uPod/g' \
        -e 's/PODPHOENIX/UPOD/g' \
        -e 's/soy\.iko\.podphoenix/com.upod.app/g' \
        "$file"
done

echo "  ✓ Text replacements complete"

echo ""
echo "🔧 Step 3: Cleaning up backup files..."

# Remove temporary backup files
find . -name "*$BACKUP_SUFFIX" -type f -delete
echo "  ✓ Backup files removed"

echo ""
echo "🔧 Step 4: Updating specific configuration files..."

# Update manifest.json.in with proper formatting
if [ -f "manifest.json.in" ]; then
    cat > manifest.json.in << 'EOF'
{
    "name": "com.upod.app",
    "description": "Enhanced podcast player for Ubuntu Touch with 
discovery features",
    "architecture": "@CLICK_ARCH@",
    "title": "uPod",
    "hooks": {
        "upod": {
            "apparmor": "uPod.apparmor",
            "desktop": "upod.desktop"
        }
    },
    "version": "0.2.0",
    "maintainer": "Your Name <your.email@example.com>",
    "framework": "ubuntu-sdk-16.04"
}
EOF
    echo "  ✓ Updated manifest.json.in"
fi

# Update or create upod.desktop
if [ -f "upod.desktop" ] || [ -f "podphoenix.desktop" ]; then
    cat > upod.desktop << 'EOF'
[Desktop Entry]
Name=uPod
Comment=Enhanced podcast player with discovery
Exec=upod
Icon=logo.png
Terminal=false
Type=Application
X-Ubuntu-Touch=true
X-Ubuntu-Gettext-Domain=upod
EOF
    echo "  ✓ Updated upod.desktop"
fi

# Update clickable.yaml
if [ -f "clickable.yaml" ]; then
    # Already updated by sed, but ensure kill and launch are correct
    echo "  ✓ clickable.yaml already updated by text replacement"
fi

echo ""
echo "✅ Renaming complete!"
echo ""
echo "📊 Summary of changes:"
echo "  • All 'podphoenix' → 'upod'"
echo "  • All 'PodPhoenix' → 'uPod'"
echo "  • Package ID: soy.iko.podphoenix → com.upod.app"
echo "  • Version: bumped to 0.2.0"
echo ""
echo "📝 Next steps:"
echo "  1. Review changes:"
echo "     git status"
echo "     git diff"
echo ""
echo "  2. Update manifest.json.in with your name/email:"
echo "     nano manifest.json.in"
echo ""
echo "  3. Update README.md to reflect uPod branding:"
echo "     nano README.md"
echo ""
echo "  4. Commit changes:"
echo "     git add ."
echo "     git commit -m \"Rename PodPhoenix to uPod\""
echo ""
echo "  5. Push to GitHub:"
echo "     git push origin master"
echo ""
echo "🎉 Ready to add Podcast Index integration!"
