#!/bin/bash

echo "🚀 Starting Pluckr Data Migration..."
echo "This script will migrate existing data to organization structure"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

echo "📋 Current Firestore collections:"
firebase firestore:collections

echo ""
echo "🔧 To migrate data manually:"
echo "1. Create an organization in the app"
echo "2. The migration will happen automatically"
echo ""
echo "📊 Expected structure after migration:"
echo "organizations/"
echo "  └── {org-id}/"
echo "      ├── clients/"
echo "      ├── chartTagsLibrary/"
echo "      ├── clientTagsLibrary/"
echo "      └── encryptionKeys/"
echo ""
echo "✅ Migration is ready to run when you create an organization!" 