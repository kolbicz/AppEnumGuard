# AppEnumGuard 1.1.0

AppEnumGuard 1.1 replaces the per-app mitigation from 1.0 with a centralized,
SpringBoard-side fix for CVE-2025-31207.

## What changed

- Injects only into SpringBoard, not every UIKit application.
- Hooks the common `FBSystemService` trust-validation path.
- Rewrites unauthorized security-policy error 3 to application-not-found error
  4, making installed and missing bundle identifiers indistinguishable.
- Validates the private selector's runtime ABI before installing the hook.
- Removes the v1.0 requirement to enable injection for every protected app.
- An app can no longer bypass this mitigation merely by detecting or disabling
  tweak injection in its own process.

Version 1.0 successfully masked the leak but operated by hooking
SpringBoardServices inside each application. That design required injection into
all apps and was unsuitable for injection-sensitive banking and security apps.

## Compatibility

- iOS 17.0–17.3.1
- Relaxin jailbreak with rootHide bootstrap
- arm64e devices
- Confirmed on iOS 17.3.1 build 21D61

## Verification

The sandboxed tester was run with its own tweak injection disabled:

- Without AppEnumGuard: target `9`, missing `7` — red FAIL.
- With AppEnumGuard 1.1: target `7`, missing `7` — green PASS.

## Included assets

- `AppEnumGuard_1.1.0_roothide_iphoneos-arm64e.deb`
- `AppEnumGuardTester_1.1.0_sandboxed.ipa`

## SHA-256

```text
e1d8ea5c64d32a7399a6c249f501af0f3a8e99bb5c63be27a63e4141c7856488  AppEnumGuard_1.1.0_roothide_iphoneos-arm64e.deb
b19c8d0acc1191c903ab25e601f1f0e2cf69d1dc0f9a4f70b9736f5c019e3522  AppEnumGuardTester_1.1.0_sandboxed.ipa
```

AppEnumGuard is a user-space mitigation for the published SpringBoardServices
side channel, not a substitute for Apple's complete iOS 18.5 fix.
