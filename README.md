# EchoNote - Voice Notes Reimagined

A modern voice note application with AI transcription, built with SwiftUI and SwiftData.

## Features

### Free Version
- Basic voice recording
- Limited storage
- Basic playback

### Premium Features
- Unlimited voice recordings
- AI-powered transcription
- Cloud sync across devices
- Advanced audio editing
- Multiple language support
- Priority support

## RevenueCat Integration

This app uses RevenueCat for subscription management. To set up RevenueCat:

### 1. Install RevenueCat SDK

Add RevenueCat to your Xcode project:

1. In Xcode, go to **File** → **Add Package Dependencies**
2. Enter the URL: `https://github.com/RevenueCat/purchases-ios`
3. Select the latest version and click **Add Package**

### 2. Configure RevenueCat

1. Sign up at [RevenueCat.com](https://www.revenuecat.com)
2. Create a new app in RevenueCat dashboard
3. Get your API key from the dashboard
4. Replace `YOUR_REVENUECAT_API_KEY` in `RevenueCatManager.swift` with your actual API key

### 3. App Store Connect Setup

1. Create subscription products in App Store Connect:
   - Weekly: `weekly_premium`
   - Annual: `annual_premium` (with free trial)
   - Lifetime: `lifetime_premium`

2. Configure RevenueCat products to match your App Store Connect products

### 4. Entitlements

Create an entitlement called `premium` in RevenueCat dashboard and assign it to your subscription products.

## Project Structure

```
EchoNote/
├── EchoNoteApp.swift          # App entry point
├── ContentView.swift          # Main view with navigation
├── Models/
│   └── VoiceNote.swift        # SwiftData model
├── Managers/
│   ├── AudioPlayerManager.swift
│   ├── SpeechRecognitionManager.swift
│   ├── SubscriptionManager.swift
│   └── RevenueCatManager.swift # NEW: RevenueCat integration
└── Views/
    ├── RecordingView.swift
    ├── DetailView.swift
    ├── SettingsView.swift
    ├── OnBoardingView.swift
    ├── LanguageSelectionView.swift
    ├── LaunchScreenView.swift
    ├── PremiumView.swift      # OLD: Timeline-style paywall
    └── ModernPaywallView.swift # NEW: Feature comparison paywall
```

## Subscription Plans

- **Weekly**: $4.99/week
- **Annual**: $24.98/year (with 3-day free trial)
- **Lifetime**: $99.99 (one-time purchase)

## Development

### Prerequisites
- Xcode 16.1+
- iOS 17.0+
- RevenueCat account

### Setup
1. Clone the repository
2. Add RevenueCat package dependency
3. Configure your RevenueCat API key
4. Set up App Store Connect products
5. Build and run

## Design System

The app uses a custom color palette defined in `AppColors`:

- **Primary**: Modern blue (#3366E6)
- **Secondary**: Soft pink (#F26699)
- **Accent**: Mint green (#4DCC99)
- **Background**: Warm light gray (#FAF7F2)
- **Text Primary**: Dark blue-gray (#1A1A26)
- **Text Secondary**: Medium gray (#666680)

## License

This project is proprietary software. All rights reserved. 