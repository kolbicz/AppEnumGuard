#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
output_dir="$repo_dir/dist"
build_dir=$(mktemp -d "${TMPDIR:-/tmp}/AppEnumGuardTester.XXXXXX")
module_cache=$(mktemp -d "${TMPDIR:-/tmp}/AppEnumGuardModules.XXXXXX")
app_dir="$build_dir/Payload/AppEnumGuardTester.app"

cleanup() {
    rm -rf "$build_dir" "$module_cache"
}
trap cleanup EXIT INT TERM

mkdir -p "$app_dir" "$output_dir"
sdk=$(xcrun --sdk iphoneos --show-sdk-path)

CLANG_MODULE_CACHE_PATH="$module_cache" xcrun --sdk iphoneos clang \
    -arch arm64 \
    -isysroot "$sdk" \
    -miphoneos-version-min=15.0 \
    -fobjc-arc \
    -fmodules \
    -framework UIKit \
    -framework Foundation \
    "$repo_dir/Tester/main.m" \
    -o "$app_dir/AppEnumGuardTester"

cp "$repo_dir/Tester/Resources/Info.plist" "$app_dir/Info.plist"
codesign --force --sign - --timestamp=none "$app_dir"

ipa="$output_dir/AppEnumGuardTester_1.0.0_sandboxed.ipa"
rm -f "$ipa"
(cd "$build_dir" && /usr/bin/zip -qry "$ipa" Payload)

printf 'Built %s\n' "$ipa"
