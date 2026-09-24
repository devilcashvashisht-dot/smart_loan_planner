# Smart Loan & EMI Planner - Production Deployment Guide

Welcome to your production-grade, 100% copyright-free financial utility app. This guide will walk you through compiling your release `.aab` file and publishing it on the Google Play Store.

---

## Architecture & Monetization Overview
- **Category**: Finance & Productivity Tools (Highest AdMob eCPMs)
- **Zero Server Overhead**: 100% offline calculations (Zero database/hosting costs)
- **Monetization Engine**:
  - Banner Ads (at bottom of calculator screens)
  - Paced Interstitials (after every 3 calculations)
  - Rewarded Ads (unlocks full PDF amortization export)
  - Ad-Free In-App Purchase ($2.99)

---

## Option A: Build the Production AAB in the Cloud (Recommended — 0 Software Installation Needed)

Since you don't need to install 20GB of Android Studio and Java SDKs on your laptop, we configured an automated GitHub Actions cloud build script in `.github/workflows/build_aab.yml`.

### Step 1: Create a Free GitHub Repository
1. Go to [github.com](https://github.com/) and create a new **Private** or **Public** repository named `smart_loan_planner`.
2. Open your terminal in this directory and run:
   ```bash
   cd /Users/king/Downloads/ANTIGRAVITY/smart_loan_planner
   git init
   git add .
   git commit -m "Initial release of Smart Loan Planner"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/smart_loan_planner.git
   git push -u origin main
   ```

### Step 2: Download Your Release .aab File
1. Go to your repository on GitHub and click the **Actions** tab at the top.
2. You will see the **Build Release Android App Bundle (AAB)** workflow running automatically.
3. In ~3 minutes, it will show a green checkmark.
4. Click on the completed run, scroll to the bottom under **Artifacts**, and click **`smart-loan-planner-release-aab`** to download your production bundle!

---

## Option B: Run Locally on Your Computer (If you install Flutter)
If you decide to install Flutter on your Mac:
```bash
flutter pub get
flutter test
flutter run
flutter build appbundle --release
```

---

## Connecting Your Real AdMob Account (When Ready)
By default, the app runs with **Google's Official Test Ad Unit IDs** so you can test it safely without violating Google's invalid traffic policies.

When you create your Google AdMob account:
1. Open `lib/services/ad_service.dart`.
2. Replace:
   - `_prodBannerId` with your AdMob Banner Unit ID.
   - `_prodInterstitialId` with your AdMob Interstitial Unit ID.
   - `_prodRewardedId` with your AdMob Rewarded Unit ID.
3. Open `android/app/src/main/AndroidManifest.xml` and replace the `APPLICATION_ID` meta-data value with your AdMob App ID (`ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`).

---

## Publishing to Google Play Console

1. **Log in to Play Console**: Go to [play.google.com/console](https://play.google.com/console).
2. **Create App**:
   - App Name: `Smart Loan & EMI Planner`
   - Default Language: English (United States)
   - App or Game: App
   - Free or Paid: Free
3. **Fill App Content**:
   - Privacy Policy: Use the hosted URL from `store_assets/privacy_policy.html` (or host it free via GitHub Pages).
   - Ads: Select "Yes, my app contains ads".
   - Target Audience: 18 and older (or General audience).
   - Financial Features: Select "Financial calculation / planning only (does not issue loans)".
4. **Store Listing**:
   - Copy the title, short description, and full description directly from `store_assets/store_listing.md`.
5. **Upload Bundle**:
   - Go to **Testing > Closed testing** (or Production).
   - Upload the `app-release.aab` file downloaded from GitHub Actions.
