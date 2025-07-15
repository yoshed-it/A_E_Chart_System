#!/bin/bash

# SwiftLint Build Phase Script for Pluckr
# Add this script to your Xcode build phases to run SwiftLint during builds

# Exit if SwiftLint is not installed
if ! command -v swiftlint &> /dev/null; then
    echo "⚠️  SwiftLint is not installed. Skipping linting."
    echo "   Run: brew install swiftlint"
    exit 0
fi

# Get the project directory
PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"

# Run SwiftLint
echo "🔍 Running SwiftLint..."
swiftlint lint --config "$PROJECT_DIR/.swiftlint.yml"

# Check if linting passed
if [ $? -eq 0 ]; then
    echo "✅ SwiftLint passed!"
else
    echo "❌ SwiftLint found issues. Please fix them before building."
    exit 1
fi 