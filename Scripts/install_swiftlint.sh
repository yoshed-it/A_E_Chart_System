#!/bin/bash

# SwiftLint Installation Script for Pluckr
# This script installs SwiftLint and sets up the project for linting

set -e

echo "🔧 Installing SwiftLint for Pluckr..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed. Please install Homebrew first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Install SwiftLint
echo "📦 Installing SwiftLint..."
brew install swiftlint

# Verify installation
if command -v swiftlint &> /dev/null; then
    echo "✅ SwiftLint installed successfully!"
    echo "📋 Version: $(swiftlint version)"
else
    echo "❌ SwiftLint installation failed"
    exit 1
fi

# Create Scripts directory if it doesn't exist
mkdir -p Scripts

# Create a lint script
cat > Scripts/lint.sh << 'EOF'
#!/bin/bash

# SwiftLint Script for Pluckr
# Run this script to lint the project

set -e

echo "🔍 Running SwiftLint..."

# Run SwiftLint
swiftlint lint

echo "✅ Linting complete!"
EOF

# Make the script executable
chmod +x Scripts/lint.sh

# Create an autocorrect script
cat > Scripts/autocorrect.sh << 'EOF'
#!/bin/bash

# SwiftLint Autocorrect Script for Pluckr
# Run this script to automatically fix linting issues

set -e

echo "🔧 Running SwiftLint autocorrect..."

# Run SwiftLint autocorrect
swiftlint autocorrect

echo "✅ Autocorrect complete!"
EOF

# Make the script executable
chmod +x Scripts/autocorrect.sh

echo "🎉 SwiftLint setup complete!"
echo ""
echo "📝 Usage:"
echo "  ./Scripts/lint.sh        - Run linting"
echo "  ./Scripts/autocorrect.sh - Auto-fix linting issues"
echo ""
echo "💡 You can also run SwiftLint directly:"
echo "  swiftlint lint"
echo "  swiftlint autocorrect" 