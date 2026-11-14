# Yadah

Daily gratitude prayer reminder app by Christian App Empire LLC.

## Open in Xcode

```bash
open ios/Yadah.xcworkspace
```

Or open `ios/Yadah.xcodeproj`. The Google Mobile Ads SDK is linked via Swift Package Manager.

## Local device testing

1. Connect your iPhone and select it as the run destination.
2. Signing uses team `Z96AAJY9NG` and bundle id `com.christianappempire.yadah`.
3. Scheme **Yadah** uses Debug + `Yadah.storekit` for Remove Ads Pro testing.
4. Keep `AdsConfig.useTestAds = true` for all test builds.

## Privacy Policy (GitHub Pages)

Source: [`docs/privacy-policy.html`](docs/privacy-policy.html)

Published URL (after enabling Pages from the `docs/` folder on `main`):

https://christianappsfamily.github.io/yadah/privacy-policy.html

## Thank You Wall backend

The wall is local-only today. A shared wall needs a hosted table (e.g. Supabase `wall_entries` with `id`, `initials`, `city`, `created_at`), insert-on-thanks with rate limits, and a latest-N fetch. Update the privacy policy before shipping any server-backed wall.
