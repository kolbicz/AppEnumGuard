#import <Foundation/Foundation.h>
#import <substrate.h>
#import <dlfcn.h>

// CVE-2025-31207 leaks whether a bundle ID exists by returning 9 for an
// installed app and 7 for a missing app.  Ordinary containerized apps are not
// legitimate callers of this private launch SPI, so give every query the same
// "not found" result.  Apple/system processes are deliberately left alone.
static const int kSBSApplicationNotFound = 7;

static BOOL AEFShouldDenyPrivateLaunchSPI(void) {
    static BOOL deny;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = NSBundle.mainBundle.bundlePath.stringByStandardizingPath;
        deny = [bundlePath hasPrefix:@"/private/var/containers/Bundle/Application/"] ||
               [bundlePath hasPrefix:@"/var/containers/Bundle/Application/"];
    });
    return deny;
}

typedef int (*SBSLaunchWithURLFn)(NSString *, NSURL *, NSDictionary *, NSDictionary *, BOOL);
typedef int (*SBSLaunchFn)(NSString *, NSDictionary *, NSDictionary *, BOOL);

static SBSLaunchWithURLFn originalLaunchWithURL;
static SBSLaunchFn originalLaunch;

static int replacedLaunchWithURL(NSString *bundleIdentifier, NSURL *url,
                                 NSDictionary *appOptions, NSDictionary *launchOptions,
                                 BOOL suspended) {
    if (AEFShouldDenyPrivateLaunchSPI()) {
        return kSBSApplicationNotFound;
    }
    return originalLaunchWithURL(bundleIdentifier, url, appOptions, launchOptions, suspended);
}

static int replacedLaunch(NSString *bundleIdentifier, NSDictionary *appOptions,
                          NSDictionary *launchOptions, BOOL suspended) {
    if (AEFShouldDenyPrivateLaunchSPI()) {
        return kSBSApplicationNotFound;
    }
    return originalLaunch(bundleIdentifier, appOptions, launchOptions, suspended);
}

__attribute__((constructor)) static void AEFInitialize(void) {
    @autoreleasepool {
        void *handle = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices",
                             RTLD_NOW | RTLD_LOCAL);
        if (handle != NULL) {
            void *launchWithURL = dlsym(handle, "SBSLaunchApplicationWithIdentifierAndURLAndLaunchOptions");
            void *launch = dlsym(handle, "SBSLaunchApplicationWithIdentifierAndLaunchOptions");

            if (launchWithURL != NULL) {
                MSHookFunction(launchWithURL, (void *)&replacedLaunchWithURL,
                               (void **)&originalLaunchWithURL);
            }
            if (launch != NULL) {
                MSHookFunction(launch, (void *)&replacedLaunch,
                               (void **)&originalLaunch);
            }
        }
    }
}
