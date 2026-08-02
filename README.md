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
| Device architecture | arm64e; tweak binary contains arm64 and arm64e slices |
| Package | Install the rootHide `.deb`, not a conventional rootless build |

Relaxin uses the rootHide bootstrap/package architecture, so AppEnumGuard is
built with rootHide Theos and contains rootHide `.jbroot` loader paths. The
package declares `firmware (>= 17.0)` and `firmware (<< 17.4)`, matching the
supported Relaxin range of 17.0–17.3.1.

The tweak and tester were verified together on a real Relaxin/rootHide device:
the tester detected the leak with the tweak removed and returned a green pass
after the tweak was installed.

## How it works

The published primitive calls the private SpringBoardServices function
`SBSLaunchApplicationWithIdentifierAndURLAndLaunchOptions`. On a vulnerable
system it returns different errors for an installed application and a missing
application:

- `9`: target exists, but launch is denied by policy
- `7`: target does not exist

The tweak is injected into UIKit application processes. For an ordinary
container-installed application, it returns `7` without submitting the private
launch request. Apple and other system processes outside the application
container retain the original behavior.

## Release downloads

Each GitHub release contains both installable artifacts:

- `AppEnumGuard_1.0.0_roothide_iphoneos-arm64e.deb` — rootHide tweak
- `AppEnumGuardTester_1.0.0_sandboxed.ipa` — sandboxed verification app

## Install and verify

1. Install the rootHide `.deb` and respring.
2. Install the tester IPA using a normal developer/sideloading signature.
3. Ensure tweak injection is enabled for **AppEnum Test**.
4. Install WhatsApp, or enter the bundle identifier of another known installed
   application.
5. Tap **Run comparison**.

Expected results with WhatsApp installed:

| State | Target | Missing | Tester result |
|---|---:|---:|---|
| Tweak absent | 9 | 7 | Red / FAIL |
| Tweak active | 7 | 7 | Green / PASS |

The original device test reproduced both states: uninstalling the tweak produced
the red `9 / 7` result, while installing it produced the green `7 / 7` result.

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
- An application that disables tweak injection cannot be protected by a
  client-side injected tweak.
- A `7 / 7` test is meaningful only when the target application is known to be
  installed.
- The tester intentionally calls an undocumented private API and is not suitable
  for App Store submission.

## References

- [Apple iOS 18.5 security content](https://support.apple.com/en-us/122404)
- [NVD: CVE-2025-31207](https://nvd.nist.gov/vuln/detail/CVE-2025-31207)
- [Published TrollDetector proof of concept](https://gist.github.com/wh1te4ever/c7909dcb5b66c13a217b49ea3e320caf)
- [rootHide developer documentation](https://github.com/roothide/Developer)

## License

MIT
