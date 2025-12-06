#!/bin/bash
# setup_podcast_index.sh
# Add Podcast Index integration to uPod

echo "🎙️ Setting up Podcast Index Integration for uPod"
echo "=================================================="
echo ""

# Check if we're in the right directory
if [ ! -f "manifest.json.in" ]; then
    echo "❌ Error: manifest.json.in not found"
    echo "Please run this script from the root of the upod repository"
    exit 1
fi

echo "📁 Working directory: $(pwd)"
echo ""

# Create directory structure
echo "📂 Step 1: Creating directory structure..."
mkdir -p backend/modules/PodcastIndex
mkdir -p app/ui/settings
mkdir -p app/ui/discovery
echo "  ✓ Directories created"
echo ""

# Create backend files
echo "📝 Step 2: Creating backend C++ files..."
echo "  This creates PodcastIndexAPI.h, PodcastIndexAPI.cpp, and 
CMakeLists.txt"
echo ""

# The rest of the backend setup script content...
# (I'll provide a download link instead since it's very long)
