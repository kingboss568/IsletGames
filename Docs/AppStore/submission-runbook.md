# Islet Games Submission Runbook

## Fixed Account Data

- Team: Yu Shiung Jiang
- Contact: Yu Shiung Jiang
- Phone: +886952413678
- Email: jushiung@gmail.com
- Bundle ID: com.jiang.isletgames

## Required Public URLs

- Privacy Policy: https://kingboss568.github.io/IsletGames/privacy-policy.html
- Support: https://kingboss568.github.io/IsletGames/support.html

These URLs must be verified after this folder is pushed to a GitHub Pages-enabled repo. Do not report submission readiness until both URLs are public and match the files in this repository.

## Fastlane Tracks

- `bundle exec fastlane ios deliver_metadata`
- `bundle exec fastlane ios deliver_screenshots`
- `bundle exec fastlane ios deliver_ipa`

`deliver` does not create IAP products. Create and verify StoreKit products in App Store Connect separately before final review submission.
