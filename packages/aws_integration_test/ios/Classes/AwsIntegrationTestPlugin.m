#import "AwsIntegrationTestPlugin.h"
#if __has_include(<aws_integration_test/aws_integration_test-Swift.h>)
#import <aws_integration_test/aws_integration_test-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "aws_integration_test-Swift.h"
#endif

@import UIKit;

static NSString *const kIntegrationTestPluginChannel = @"plugins.flutter.io/integration_test";
static NSString *const kMethodTestFinished = @"allTestsFinished";
static NSString *const kMethodScreenshot = @"captureScreenshot";
static NSString *const kMethodConvertSurfaceToImage = @"convertFlutterSurfaceToImage";
static NSString *const kMethodRevertImage = @"revertFlutterImage";

@interface AwsIntegrationTestPlugin ()

@property(nonatomic, readwrite) NSDictionary<NSString *, NSString *> *testResults;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

@implementation AwsIntegrationTestPlugin {
    NSDictionary<NSString *, NSString *> *_testResults;
    NSMutableDictionary<NSString *, UIImage *> *_capturedScreenshotsByName;
}

+ (instancetype)instance {
    static dispatch_once_t onceToken;
    static AwsIntegrationTestPlugin *sInstance;
    dispatch_once(&onceToken, ^{
        sInstance = [[AwsIntegrationTestPlugin alloc] initForRegistration];
    });
    return sInstance;
}

- (instancetype)initForRegistration {
    return [self init];
}

- (instancetype)init {
    self = [super init];
    _capturedScreenshotsByName = [NSMutableDictionary new];
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:kIntegrationTestPluginChannel
                                                                binaryMessenger:registrar.messenger];
    [registrar addMethodCallDelegate:[self instance] channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:kMethodTestFinished]) {
        self.testResults = call.arguments[@"results"];
        
        /* Send the test results to TestServer which will keep it in memory */
        TestServerClient *serverClient = [[TestServerClient alloc] initWithBaseURL:@"http://localhost:8081"];
        [serverClient sendPostRequestToStoreTestResultWithPath:@"results" payload:_testResults];
        
        result(nil);
    } else if ([call.method isEqualToString:kMethodScreenshot]) {
        // If running as a native Xcode test, attach to test.
        UIImage *screenshot = [self capturePngScreenshot];
        NSString *name = call.arguments[@"name"];
        _capturedScreenshotsByName[name] = screenshot;
        
        // Also pass back along the channel for the driver to handle.
        NSData *pngData = UIImagePNGRepresentation(screenshot);
        result([FlutterStandardTypedData typedDataWithBytes:pngData]);
    } else if ([call.method isEqualToString:kMethodConvertSurfaceToImage]
               || [call.method isEqualToString:kMethodRevertImage]) {
        // Android only, no-op on iOS.
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (UIImage *)capturePngScreenshot {
    UIWindow *window = [UIApplication.sharedApplication.windows
                        filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"keyWindow = YES"]].firstObject;
    CGRect screenshotBounds = window.bounds;
    UIImage *image;
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithBounds:screenshotBounds];
    image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *rendererContext) {
        [window drawViewHierarchyInRect:screenshotBounds afterScreenUpdates:YES];
    }];
    
    return image;
}

@end
