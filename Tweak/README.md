# AppEnumGuard tweak

Compatibility: Relaxin jailbreak on iOS 17.0–17.3.1 using its rootHide
bootstrap. Install the rootHide `iphoneos-arm64e` package, not a conventional
rootless package. The tweak binary is arm64e-only, matching Relaxin's current
device support.

Version 1.1 hooks the common `FBSystemService` validation path inside SpringBoard.
When an unauthorized launch request produces FrontBoard security-policy error 3,
the tweak replaces it with application-not-found error 4. This closes the return
code distinction centrally without injecting into ordinary applications.

The hook validates the private method ABI before installation and fails open if
the expected selector or signature is unavailable.

Build using rootHide Theos:

```sh
THEOS=/path/to/theos-roothide \
  make clean package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=roothide
```
