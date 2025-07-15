#!/bin/bash

echo "🔧 Pluckr Build Error Fix Script"
echo "=================================="
echo ""

# Check if files exist in correct locations
echo "📁 Checking file locations..."

if [ -f "Services/AuthService.swift" ]; then
    echo "✅ AuthService.swift found in Services/"
else
    echo "❌ AuthService.swift missing from Services/"
fi

if [ -f "Views/Auth/SignUpView.swift" ]; then
    echo "✅ SignUpView.swift found in Views/Auth/"
else
    echo "❌ SignUpView.swift missing from Views/Auth/"
fi

if [ -f "Repositories/ClientRepository.swift" ]; then
    echo "✅ ClientRepository.swift found in Repositories/"
else
    echo "❌ ClientRepository.swift missing from Repositories/"
fi

if [ -f "Utils/Logger.swift" ]; then
    echo "✅ Logger.swift found in Utils/"
else
    echo "❌ Logger.swift missing from Utils/"
fi

echo ""
echo "🔍 Checking for duplicate files..."

if [ -f "Views/Repositories/ClientRepository.swift" ]; then
    echo "❌ Duplicate ClientRepository.swift found in Views/Repositories/"
    echo "   This should be deleted!"
else
    echo "✅ No duplicate ClientRepository.swift found"
fi

echo ""
echo "📋 Instructions to fix build errors:"
echo "====================================="
echo ""
echo "1. Open Xcode"
echo "2. In Project Navigator, ensure these files are added to your target:"
echo "   - Services/AuthService.swift"
echo "   - Views/Auth/SignUpView.swift"
echo "   - Repositories/ClientRepository.swift"
echo "   - Utils/Logger.swift"
echo ""
echo "3. To add files to target:"
echo "   - Right-click the group (folder) in Xcode"
echo "   - Choose 'Add Files to \"Pluckr\"...'"
echo "   - Select the file"
echo "   - Make sure the target checkbox is checked"
echo ""
echo "4. Clean build folder: Shift+Cmd+K"
echo "5. Build again: Cmd+B"
echo ""
echo "💡 If files are already in Xcode but still showing errors:"
echo "   - Check that the target checkbox is checked in file inspector"
echo "   - Try removing and re-adding the files"
echo "   - Make sure there are no duplicate files" 