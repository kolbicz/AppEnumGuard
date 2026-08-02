# AppEnumGuard 1.0.0

Initial tested release.

## CVE

CVE-2025-31207 is a FrontBoard information-disclosure issue that lets a
sandboxed app infer which applications are installed from differing private
SpringBoardServices launch return codes. Apple fixed the underlying OS issue in
iOS/iPadOS 18.5.

## Compatibility

- iOS 17.0–17.3.1
- Relaxin jailbreak
- rootHide bootstrap and package architecture
- Install the `iphoneos-arm64e` rootHide package; do not use a rootless build

## Included assets

- `AppEnumGuard_1.0.0_roothide_iphoneos-arm64e.deb`
- `AppEnumGuardTester_1.0.0_sandboxed.ipa`

## SHA-256

```text
e7818c86fd717015554057a4305619bf1be947c7fdfa758ebb0716ee273320de  AppEnumGuard_1.0.0_roothide_iphoneos-arm64e.deb
a5f6143c1ca85a07d4f7722b6e38e29041623076d593a9f294160acf1daccf42  AppEnumGuardTester_1.0.0_sandboxed.ipa
```

## Verification

On a vulnerable Relaxin/rootHide iOS 17 device with WhatsApp installed:

- Without AppEnumGuard: target `9`, missing `7` — tester reports FAIL.
- With AppEnumGuard: target `7`, missing `7` — tester reports PASS.

The tweak is a user-space mitigation for the published SpringBoardServices
side channel. It is not a substitute for Apple's complete iOS 18.5 fix.
