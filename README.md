# PropertyScan IQ

PropertyScan IQ is an AI-assisted iOS property inspection and reporting app built with SwiftUI, SwiftData, StoreKit 2 scaffolding, native photo capture/upload, mock AI scanning, and PDF report generation.

## Current State

- SwiftUI app using `NavigationStack` and MVVM-style view models
- SwiftData local persistence for properties, inspections, rooms, photos, detected issues, reports, and subscription state
- Mock AI mode enabled by default
- Remote AI service placeholder at `https://your-backend-url.com/property-scan`
- StoreKit 2 subscription manager with mock subscription state for development
- Native PDF export with report preview, share sheet, copy support, and Pro branding/logo support
- Safety disclaimers for non-certified visual AI findings

## Build

Open `PropertyScanIQ.xcodeproj` in Xcode on macOS and run the `PropertyScanIQ` scheme on an iOS 17+ simulator or device.

This workspace was syntax-checked with `swiftc -parse` on the generated Swift source set. A full iOS simulator build requires macOS/Xcode tooling.

## GitHub Xcode Upload

The repository includes two GitHub Actions workflows:

- `iOS Build Check`: builds the app for an iOS simulator on `macos-26`.
- `iOS App Store Upload`: manually archives and uploads the app to App Store Connect with Xcode.

Before running `iOS App Store Upload`, add these GitHub repository secrets:

- `APPLE_TEAM_ID`
- `ASC_KEY_ID`
- `ASC_ISSUER_ID`
- `ASC_PRIVATE_KEY`

The App Store Connect API key must have permission to manage apps and builds. Apple currently requires iOS and iPadOS apps uploaded to App Store Connect to be built with Xcode 26 or later using the iOS/iPadOS 26 SDK or later.

## Production Wiring

Before App Store submission:

- Replace the remote AI endpoint in `RemoteAIService`
- Keep API keys server-side only
- Configure StoreKit product IDs in App Store Connect
- Review and publish the privacy policy and terms
- Review App Store subscription, privacy, and AI disclosure language

## Policies

- [Privacy Policy](PRIVACY.md)
- [Terms of Use](TERMS.md)
