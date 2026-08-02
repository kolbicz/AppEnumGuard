# AppEnumGuard tweak

The tweak hooks the two SpringBoardServices launch entry points used by the
published primitive and returns a uniform application-not-found result to
container-installed UIKit applications. System processes retain the original
behavior.

Build using rootHide Theos:

```sh
THEOS=/path/to/theos-roothide \
  make clean package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=roothide
```
