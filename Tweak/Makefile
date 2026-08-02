ARCHS := arm64e
TARGET := iphone:clang:latest:15.0
THEOS_PACKAGE_SCHEME ?= roothide

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := AppEnumerationFix
AppEnumerationFix_FILES := Tweak.mm
AppEnumerationFix_CFLAGS := -fobjc-arc
AppEnumerationFix_FRAMEWORKS := Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "sbreload"
