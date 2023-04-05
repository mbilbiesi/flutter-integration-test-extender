//
//  AWSIntegrationTestRunner.h
//  aws_integration_test
//
//  Created by Mazen Bilbiesi on 21/03/2023.
//

@import Foundation;
@import ObjectiveC.runtime;

@class UIImage;

NS_ASSUME_NONNULL_BEGIN

typedef void (^AWSIntegrationTestResults)(SEL nativeTestSelector, BOOL success, NSString *_Nullable failureMessage);

@interface AWSIntegrationTestRunner : NSObject

/**
 * Any screenshots captured by the plugin.
 */
@property (copy, readonly) NSDictionary<NSString *, UIImage *> *capturedScreenshotsByName;

/**
 * Starts dart tests and waits for results.
 *
 * @param testResult Will be called once per every completed dart test.
 */
- (void)testIntegrationTestWithResults:(NSDictionary<NSString *, NSString *> *)testResults :(NS_NOESCAPE AWSIntegrationTestResults)testResult;

/**
 * An appropriate XCTest method name based on the dart test name.
 *
 * Example: dart test "verify widget-ABC123" becomes "testVerifyWidgetABC123"
 */
+ (NSString *)testCaseNameFromDartTestName:(NSString *)dartTestName;

@end

#define AWS_INTEGRATION_TESTS(RunnerUITests) \
@interface RunnerUITests : XCTestCase \
@end\
\
@implementation RunnerUITests \
\
static XCUIApplication *springboard;\
static XCUIElementQuery *systemAlerts;\
\
+ (NSArray<NSInvocation *> *)testInvocations {\
    AWSIntegrationTestRunner *integrationTestRunner = [[AWSIntegrationTestRunner alloc] init];\
    NSMutableArray<NSInvocation *> *testInvocations = [[NSMutableArray alloc] init];\
    \
    XCUIApplication *app = [[XCUIApplication alloc] init];\
    [app activate];\
    \
    TestServer *server = [[TestServer alloc] init] ;\
    [server start];\
    \
    /* Spin the runloop. */ \
    while (!server.storedResults) {\
        [self handleAlert];\
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];\
    }\
    \
    [integrationTestRunner testIntegrationTestWithResults:server.storedResults :^(SEL testSelector, BOOL success, NSString *failureMessage) {\
        IMP assertImplementation = imp_implementationWithBlock(^(id _self) {\
            XCTAssertTrue(success, @"%@", failureMessage);\
        });\
        class_addMethod(self, testSelector, assertImplementation, "v@:");\
        NSMethodSignature *signature = [self instanceMethodSignatureForSelector:testSelector];\
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];\
        invocation.selector = testSelector;\
        [testInvocations addObject:invocation];\
    }];\
    NSDictionary<NSString *, UIImage *> *capturedScreenshotsByName = integrationTestRunner.capturedScreenshotsByName;\
    if (capturedScreenshotsByName.count > 0) {\
        IMP screenshotImplementation = imp_implementationWithBlock(^(id _self) {\
            [capturedScreenshotsByName enumerateKeysAndObjectsUsingBlock:^(NSString *name, UIImage *screenshot, BOOL *stop) {\
                XCTAttachment *attachment = [XCTAttachment attachmentWithImage:screenshot];\
                attachment.lifetime = XCTAttachmentLifetimeKeepAlways;\
                if (name != nil) {\
                    attachment.name = name;\
                }\
                [_self addAttachment:attachment];\
            }];\
        });\
        SEL attachmentSelector = NSSelectorFromString(@"screenshotPlaceholder");\
        class_addMethod(self, attachmentSelector, screenshotImplementation, "v@:");\
        NSMethodSignature *attachmentSignature = [self instanceMethodSignatureForSelector:attachmentSelector];\
        NSInvocation *attachmentInvocation = [NSInvocation invocationWithMethodSignature:attachmentSignature];\
        attachmentInvocation.selector = attachmentSelector;\
        [testInvocations addObject:attachmentInvocation];\
    }\
    return testInvocations;\
}\
\
\
+ (void)handleAlert {\
    /* Handle Alert appears in the screen */ \
    if (springboard == nil){\
        springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];\
        systemAlerts = springboard.alerts;\
    }\
    \
    if (systemAlerts.count > 0) {\
        XCUIElement *alert = systemAlerts.firstMatch;\
        /* Clicking on the second button, in most cases allowing the permission */ \
        XCUIElement *button = [alert.buttons elementBoundByIndex:1];\
        if (button.exists) {\
            [button tap];\
        } else if (alert.otherElements.count > 0) {\
            [alert.otherElements.firstMatch tap];\
        }\
    }\
}\
\
@end

NS_ASSUME_NONNULL_END