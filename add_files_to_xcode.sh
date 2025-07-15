#!/bin/bash

# Script to add missing files to Xcode project
# Run this script from the Pluckr project directory

echo "🔧 Adding missing files to Xcode project..."

# Check if we're in the right directory
if [ ! -f "Pluckr.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Please run this script from the Pluckr project directory"
    exit 1
fi

echo "✅ Found Pluckr.xcodeproj"

# List the files that need to be added
echo ""
echo "📋 Files that need to be added to Xcode project:"
echo "   - Components/LoadingView.swift"
echo "   - Components/ClientCardView.swift"
echo ""

echo "📝 Instructions:"
echo "1. Open Pluckr.xcodeproj in Xcode"
echo "2. Right-click on the 'Components' group in the project navigator"
echo "3. Select 'Add Files to "Pluckr"'"
echo "4. Navigate to and select:"
echo "   - Components/LoadingView.swift"
echo "   - Components/ClientCardView.swift"
echo "5. Make sure 'Add to target: Pluckr' is checked"
echo "6. Click 'Add'"
echo ""

echo "🔄 After adding the files, clean and rebuild the project:"
echo "   Product → Clean Build Folder (Cmd+Shift+K)"
echo "   Product → Build (Cmd+B)"
echo ""

echo "✅ Script completed!" 