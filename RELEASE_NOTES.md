# AppEnumGuard 1.1.1

Metadata maintenance release of the SpringBoard-side CVE-2025-31207 mitigation.

## Changes

- Changed the Debian package identifier to `cz.kolbi.appenumguard`.
- Changed the package author and maintainer to `Kolbicz`.
- Added `Conflicts`, `Replaces`, and `Provides` metadata for the old
  `com.christoph.appenumerationfix` identifier so package managers do not retain
  both versions.
- The tested SpringBoard-side mitigation code is unchanged from 1.1.0.

## Compatibility

- iOS 17.0–17.3.1
- Relaxin jailbreak with rootHide bootstrap
- arm64e devices
- Confirmed on iOS 17.3.1 build 21D61

## Included assets

- `AppEnumGuard_1.1.1_roothide_iphoneos-arm64e.deb`
- `AppEnumGuardTester_1.1.0_sandboxed.ipa`

## SHA-256

```text
577e778ac3e2d6cc8bb5b4aad3abecb7939d77fa4c31bbd43a127744f61b51e7  AppEnumGuard_1.1.1_roothide_iphoneos-arm64e.deb
b19c8d0acc1191c903ab25e601f1f0e2cf69d1dc0f9a4f70b9736f5c019e3522  AppEnumGuardTester_1.1.0_sandboxed.ipa
```
