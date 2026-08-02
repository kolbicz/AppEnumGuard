# AppEnumGuard tweak

Compatibility: Relaxin jailbreak on iOS 17.0–17.3.1 using its rootHide
bootstrap. Install the rootHide `iphoneos-arm64e` package, not a conventional
rootless package.

The tweak hooks the two SpringBoardServices launch entry points used by the
published primitive and returns a uniform application-not-found result to
container-installed UIKit applications. System processes retain the original
behavior.

Build using rootHide Theos:

```sh
THEOS=/path/to/theos-roothide \
  make clean package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=roothide
```
