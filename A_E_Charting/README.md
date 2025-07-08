

# Pluckr – The World’s First Clinical Journal ✨📋

**Pluckr** is a secure, modern, and beautifully designed iOS/iPadOS app for clinical charting — purpose-built for electrolysis providers, with the flexibility to expand into broader aesthetic and medical use.

Inspired by warm, Ghibli-style calm and powered by iOS-native architecture, Pluckr reimagines patient charting as journal entries — organized, secure, and elegant.

---

## 🚀 Features

- 📁 Multi-organization support (invite-based onboarding for clinics)
- 👩‍⚕️ Individual provider accounts with secure authentication
- 🗂️ Client profiles with editable details and image support
- 🧾 Rich chart entries: notes, treatment settings, tags, flags
- 📸 Image uploads directly from camera
- 🧭 Smooth, native iPad layout and navigation
- ☁️ Firebase Firestore and Storage for real-time cloud sync

---

## 🧰 Tech Stack

- **SwiftUI**  
- **Firebase (Auth, Firestore, Storage)**  
- **Manual Firestore decoding (no FirebaseFirestoreSwift)**  
- **Custom styling (MossGreen theme, modern typefaces, journal-inspired UI)**

---

## 🔧 Local Setup & Running the App

To run Pluckr locally (especially after cloning it from GitHub):

### ✅ Prerequisites
- Xcode 15+
- CocoaPods **or** Swift Package Manager (if we transition)
- A personal Firebase project set up

---

### 🛠️ 1. Clone the Repo

```bash
git clone https://github.com/yourusername/pluckr.git
cd pluckr
```

---

### 📦 2. Install Dependencies (if using CocoaPods)

```bash
pod install
open Pluckr.xcworkspace
```

> If you’re using Swift Package Manager instead, just open `Pluckr.xcodeproj` and let it resolve automatically.

---

### 🔐 3. Firebase Setup

Because `GoogleService-Info.plist` is **intentionally gitignored** for security, you must do the following:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Download your `GoogleService-Info.plist` file
3. Drag and drop it into the Xcode project root (✔️ check “Copy if needed”)
4. Build and run the app

---

### 🧪 4. Optional: Skip Login for Dev

To skip the login screen during development:

In `PluckrApp.swift`, replace `LoginView()` with `ProviderHomeView()` inside the `WindowGroup`.

---

## 📂 Folder Structure

```
Pluckr/
├── Views/
├── ViewModels/
├── Models/
├── Services/
├── Resources/
├── Utilities/
```

---

## 🔒 License

This project is licensed under the **Pluckr Proprietary License**.  
You may not copy, modify, distribute, or reuse any part of this source code or app for commercial or personal projects without written permission.

> © 2025 Silas & Sebastian. All rights reserved.

---

## ❤️ Credits

Pluckr is designed and developed with care by [Yosh Nebe].  
UI direction, branding, and purpose inspired by real clinical needs and the art of Studio Ghibli.
