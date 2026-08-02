#import <Foundation/Foundation.h>
#import <CydiaSubstrate.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <string.h>

static NSString *const AEGOpenApplicationErrorDomain = @"FBSOpenApplicationErrorDomain";
static const NSInteger AEGSecurityPolicyError = 3;
static const NSInteger AEGApplicationNotFoundError = 4;

typedef BOOL (*AEGTrustRequestIMP)(id, SEL, id, id, id, id, id, NSError **);
static AEGTrustRequestIMP AEGOriginalTrustRequest;

static const char *AEGSkipTypeQualifiers(const char *type) {
    if (type == NULL) {
        return NULL;
    }
    while (*type != '\0' && strchr("rnNoORV", *type) != NULL) {
        type++;
    }
    return type;
}

static BOOL AEGTrustRequestReplacement(id self, SEL selector,
                                       id request, id caller, id client,
                                       id bundleInfo, id options,
                                       NSError **fatalError) {
    BOOL trusted = AEGOriginalTrustRequest(self, selector, request, caller,
                                           client, bundleInfo, options,
                                           fatalError);

    if (!trusted && fatalError != NULL && *fatalError != nil) {
        NSError *error = *fatalError;
        if ([error.domain isEqualToString:AEGOpenApplicationErrorDomain] &&
            error.code == AEGSecurityPolicyError) {
            *fatalError = [NSError errorWithDomain:AEGOpenApplicationErrorDomain
                                              code:AEGApplicationNotFoundError
                                          userInfo:nil];
        }
    }

    return trusted;
}

static BOOL AEGMethodHasExpectedABI(Method method) {
    if (method == NULL || method_getNumberOfArguments(method) != 8) {
        return NO;
    }

    char *returnType = method_copyReturnType(method);
    const char *unqualifiedReturnType = AEGSkipTypeQualifiers(returnType);
    BOOL booleanReturn = unqualifiedReturnType != NULL &&
                         (unqualifiedReturnType[0] == 'B' ||
                          unqualifiedReturnType[0] == 'c');
    free(returnType);
    if (!booleanReturn) {
        return NO;
    }

    for (unsigned int index = 2; index <= 6; index++) {
        char *argumentType = method_copyArgumentType(method, index);
        const char *unqualifiedType = AEGSkipTypeQualifiers(argumentType);
        BOOL objectArgument = unqualifiedType != NULL &&
                              unqualifiedType[0] == '@';
        free(argumentType);
        if (!objectArgument) {
            return NO;
        }
    }

    char *errorType = method_copyArgumentType(method, 7);
    const char *unqualifiedErrorType = AEGSkipTypeQualifiers(errorType);
    BOOL pointerArgument = unqualifiedErrorType != NULL &&
                           unqualifiedErrorType[0] == '^';
    free(errorType);
    return pointerArgument;
}

__attribute__((constructor)) static void AEGInitialize(void) {
    @autoreleasepool {
        Class serviceClass = objc_getClass("FBSystemService");
        if (serviceClass == Nil) {
            dlopen("/System/Library/PrivateFrameworks/FrontBoard.framework/FrontBoard",
                   RTLD_NOW | RTLD_LOCAL);
            serviceClass = objc_getClass("FBSystemService");
        }

        SEL selector = sel_registerName(
            "_isTrustedRequest:forCaller:fromClient:forBundleInfo:withOptions:fatalError:");
        Method method = serviceClass != Nil
            ? class_getInstanceMethod(serviceClass, selector)
            : NULL;

        // Do not hook an unknown ABI. This prevents a changed private method
        // signature from destabilizing SpringBoard.
        if (!AEGMethodHasExpectedABI(method)) {
            return;
        }

        MSHookMessageEx(serviceClass, selector,
                        (IMP)&AEGTrustRequestReplacement,
                        (IMP *)&AEGOriginalTrustRequest);
    }
}
