# Firebase Index Creation Instructions

## Required Composite Indexes

The following Firebase composite indexes need to be created to fix the query errors:

### 1. Charts Collection - Organization Structure
**Collection:** `organizations/{orgId}/clients/{clientId}/charts`
**Fields:**
- `createdBy` (Ascending)
- `createdAt` (Descending)

### 2. Charts Collection - Root Structure  
**Collection:** `clients/{clientId}/charts`
**Fields:**
- `createdBy` (Ascending)
- `createdAt` (Descending)

## How to Create Indexes

### Option 1: Using Firebase Console (Recommended)
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `aecharting`
3. Navigate to Firestore Database
4. Click on the "Indexes" tab
5. Click "Create Index"
6. For each index above:
   - Select the collection path
   - Add the fields with the specified order
   - Click "Create"

### Option 2: Using the Direct Links
Click these links to create the indexes directly:

**Organization Structure Index:**
```
https://console.firebase.google.com/v1/r/project/aecharting/firestore/indexes?create_composite=Cklwcm9qZWN0cy9hZWNoYXJ0aW5nL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9jaGFydHMvaW5kZXhlcy9fEAEaDQoJY3JlYXRlZEJ5EAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg
```

**Root Structure Index:**
```
https://console.firebase.google.com/v1/r/project/aecharting/firestore/indexes?create_composite=Cklwcm9qZWN0cy9hZWNoYXJ0aW5nL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9jaGFydHMvaW5kZXhlcy9fEAEaDQoJY3JlYXRlZEJ5EAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg
```

## Index Creation Time
- Indexes typically take 1-5 minutes to build
- You'll see a "Building" status initially
- Once complete, the status will change to "Enabled"
- The app errors should resolve once indexes are built

## Verification
After creating the indexes, restart the app and check that the Firebase errors are no longer appearing in the console. 