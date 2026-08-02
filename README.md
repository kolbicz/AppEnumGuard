# AppEnumGuard

AppEnumGuard is a defensive rootHide tweak for the installed-application
enumeration side channel tracked as **CVE-2025-31207**. It is designed for the
**Relaxin jailbreak on iOS 17.0–17.3.1**, using Relaxin's rootHide architecture.
The repository also contains a normal sandboxed iOS test application that
demonstrates the vulnerable result and verifies the mitigation.

## CVE-2025-31207

CVE-2025-31207 is an information-disclosure vulnerability in Apple's FrontBoard
application-launching logic. A sandboxed application can submit arbitrary bundle
identifiers through a private SpringBoardServices launch function and distinguish
installed applications from missing applications using different return codes.
This can reveal private information about the applications a user has installed,
including banking, messaging, security, sideloading, and jailbreak-related apps.

Apple describes the issue as a logic problem that could let an application
enumerate installed apps. Apple corrected it with improved checks in iOS and
iPadOS 18.5. Consequently, iOS 17.0–17.3.1 remains affected at the OS level.

## Compatibility

| Component | Supported target |
|---|---|
| iOS | 17.0–17.3.1 |
| Jailbreak | Relaxin |
| Bootstrap/package architecture | rootHide / `iphoneos-arm64e` |
| Device architecture | arm64e; tweak binary contains an arm64e slice only |
| Package | Install the rootHide `.deb`, not a conventional rootless build |

Relaxin uses the rootHide bootstrap/package architecture, so AppEnumGuard is
built with rootHide Theos and contains rootHide `.jbroot` loader paths. The
package declares `firmware (>= 17.0)` and `firmware (<< 17.4)`, matching the
supported Relaxin range of 17.0–17.3.1.

The SpringBoard-side v1.1 tweak and sandboxed tester were verified together on
iOS 17.3.1 build 21D61 with injection disabled for the tester. The tester
detected the leak with the tweak removed and returned a green pass after the
tweak was installed.

## How it works

The published primitive calls the private SpringBoardServices function
`SBSLaunchApplicationWithIdentifierAndURLAndLaunchOptions`. On a vulnerable
system it returns different errors for an installed application and a missing
application:

- `9`: target exists, but launch is denied by policy
- `7`: target does not exist

AppEnumGuard 1.1 injects only into SpringBoard and hooks the common
`FBSystemService` trust-validation method. When an unauthorized launch request
would return `FBSOpenApplicationErrorDomain` security-policy error 3, the tweak
changes it to application-not-found error 4. The outer SpringBoardServices API
then returns `7` for both installed and missing targets.

The private method's argument count and Objective-C type encoding are validated
before the hook is installed. If Apple changes the ABI, AppEnumGuard fails open
instead of hooking an unknown SpringBoard method.

### Change from 1.0

Version 1.0 hooked SpringBoardServices inside every UIKit application. It worked,
but required injection into every app being protected; an app that disabled or
detected injection could bypass the mitigation. Version 1.1 moves enforcement to
SpringBoard, so a single central hook protects callers without injecting
AppEnumGuard into their processes.

## Release downloads

Each GitHub release contains both installable artifacts:

- `AppEnumGuard_1.1.1_roothide_iphoneos-arm64e.deb` — rootHide tweak
- `AppEnumGuardTester_1.1.0_sandboxed.ipa` — sandboxed verification app

## Install and verify

1. Install the rootHide `.deb` and respring.
2. Install the tester IPA using a normal developer/sideloading signature.
3. Leave AppEnumGuard injection disabled for **AppEnum Test**; v1.1 protects it
   from SpringBoard.
4. Install WhatsApp, or enter the bundle identifier of another known installed
   application.
5. Tap **Run comparison**.

Expected results with WhatsApp installed:

| State | Target | Missing | Tester result |
|---|---:|---:|---|
| Tweak absent | 9 | 7 | Red / FAIL |
| Tweak active | 7 | 7 | Green / PASS |

The device test reproduced both states with tester injection disabled:
uninstalling the tweak produced the red `9 / 7` result, while installing v1.1
produced the green `7 / 7` result.

## Build the tweak

Install [rootHide Theos](https://github.com/roothide/Developer), then run:

```sh
cd Tweak
THEOS=/path/to/theos-roothide \
  make clean package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=roothide
```

## Build the tester IPA

The tester is compiled with Xcode's iPhoneOS SDK and has no jailbreak or elevated
entitlements:

```sh
./scripts/build-tester-ipa.sh
```

The resulting IPA is placed in `dist/`. It is ad-hoc signed so an installer may
re-sign it with a normal development identity. Do not grant it
`platform-application` or `com.apple.private.security.no-sandbox`, since the test
is specifically intended to run from a normal application sandbox.

## Scope and limitations

- This is a user-space mitigation for the published SpringBoardServices
  primitive, not Apple's complete FrontBoard patch.
- Version 1.1 does not require injection into protected applications. Disabling
  injection globally or for SpringBoard itself will disable the mitigation.
- The server-side implementation is confirmed on iOS 17.3.1 build 21D61. The
  package targets 17.0–17.3.1 using the same runtime-validated selector.
- A `7 / 7` test is meaningful only when the target application is known to be
  installed.
- The tester intentionally calls an undocumented private API and is not suitable
  for App Store submission.

## References

- [Apple iOS 18.5 security content](https://support.apple.com/en-us/122404)
- [NVD: CVE-2025-31207](https://nvd.nist.gov/vuln/detail/CVE-2025-31207)
- [Original public SpringBoardServices proof of concept](https://gist.github.com/wh1te4ever/c7909dcb5b66c13a217b49ea3e320caf)
- [rootHide developer documentation](https://github.com/roothide/Developer)

## License

MIT
