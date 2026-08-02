# AppEnumGuard 1.0.0

Initial tested release.

## Included assets

- `AppEnumGuard_1.0.0_roothide_iphoneos-arm64e.deb`
- `AppEnumGuardTester_1.0.0_sandboxed.ipa`

## SHA-256

```text
c83f3071660a59249182c6f289cd2d9e2e0766559be6ca1d71589671758fbe65  AppEnumGuard_1.0.0_roothide_iphoneos-arm64e.deb
a5f6143c1ca85a07d4f7722b6e38e29041623076d593a9f294160acf1daccf42  AppEnumGuardTester_1.0.0_sandboxed.ipa
```

## Verification

On a vulnerable iOS 17 rootHide device with WhatsApp installed:

- Without AppEnumGuard: target `9`, missing `7` — tester reports FAIL.
- With AppEnumGuard: target `7`, missing `7` — tester reports PASS.

The tweak is a user-space mitigation for the published SpringBoardServices
side channel. It is not a substitute for Apple's complete iOS 18.5 fix.
