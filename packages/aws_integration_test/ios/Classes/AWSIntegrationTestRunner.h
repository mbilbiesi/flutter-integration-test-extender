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

- (void)handlePermissions;

/**
 * An appropriate XCTest method name based on the dart test name.
 *
 * Example: dart test "verify widget-ABC123" becomes "testVerifyWidgetABC123"
 */
+ (NSString *)testCaseNameFromDartTestName:(NSString *)dartTestName;

@end

NS_ASSUME_NONNULL_END
