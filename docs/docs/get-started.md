---
sidebar_position: 3
title: Get Started
---

# Get Started

## 1. Fork the repository

Click **Fork** on [GitHub](https://github.com/kebabmario/CabbageSign) to create your own copy of CabbageSign under your account.

## 2. Clone & open in Xcode

```bash
git clone https://github.com/YOUR_USERNAME/CabbageSign
```

Open `CabbageSign.xcodeproj` in Xcode 15 or later.

## 3. Customise the theme

Edit `Theme/ThemeManager.swift` to change the accent colour, app name, and global styles to match your brand.

## 4. Implement real signing logic

The `Services/` folder is where your actual sideloading backend goes. Wire up your signing server, package source, or on-device signing method here.

## 5. Build & ship

Use the included GitHub Actions workflow to produce a signed `.ipa`, or configure Xcode Cloud / Fastlane for your own pipeline.
