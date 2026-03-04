---
sidebar_position: 5
title: FAQ
---

# FAQ

## Does CabbageSign actually sideload apps?

No. CabbageSign **does not work** and will never work as a real sideloading tool. It is purely a UI template. Any buttons or actions in the interface are placeholders.

## Why does the app exist if it doesn't work?

Building a good-looking SwiftUI app from scratch takes time. CabbageSign gives developers a polished starting point — tabs, screens, theming — so they can focus on the hard parts (signing logic, package sources) instead of recreating UI boilerplate.

## Can I use this as the base for my own sideloading app?

Absolutely — that is the entire point. Fork the repository, add your own signing backend and package sources, customise the theme, and ship it. The project is open source.

## Do I need Xcode to build it?

Not necessarily. The included GitHub Actions workflow builds the project and produces an `.ipa` artifact entirely in CI. However, for active development, Xcode 15 or later is recommended.

## What iOS / iPadOS versions are supported?

The template targets modern SwiftUI APIs. Check the `CabbageSign.xcodeproj` deployment target for the exact minimum version. You can adjust this to suit your needs.

## Is there a licence?

Yes — see the `LICENSE` file in the repository root for the full terms.
