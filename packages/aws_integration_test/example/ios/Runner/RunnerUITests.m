//
//  RunnerUITests.m
//  RunnerUITests
//
//  Created by Mazen Bilbiesi on 02/04/2023.
//

#import <Foundation/Foundation.h>
@import XCTest;
@import aws_integration_test;

@interface RunnerUITests : XCTestCase
@end

@implementation RunnerUITests

+ (NSArray<NSInvocation *> *)testInvocations {
    AWSIntegrationTestRunner *integrationTestRunner = [[AWSIntegrationTestRunner alloc] init];
    NSMutableArray<NSInvocation *> *testInvocations = [[NSMutableArray alloc] init];

    TestServer *server = [[TestServer alloc] init] ;
    [server start];

    XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
    XCUIElementQuery *systemAlerts = springboard.alerts;
    if (systemAlerts.buttons[@"Allow"].exists) {
      [systemAlerts.buttons[@"Allow"] tap];
    }

    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app activate];

    [integrationTestRunner handlePermissions];

    // Spin the runloop.
    while (!server.storedResults) {
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }

    [integrationTestRunner testIntegrationTestWithResults:server.storedResults :^(SEL testSelector, BOOL success, NSString *failureMessage) {
        IMP assertImplementation = imp_implementationWithBlock(^(id _self) {
            XCTAssertTrue(success, @"%@", failureMessage);
        });
        class_addMethod(self, testSelector, assertImplementation, "v@:");
        NSMethodSignature *signature = [self instanceMethodSignatureForSelector:testSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.selector = testSelector;
        [testInvocations addObject:invocation];
    }];
    NSDictionary<NSString *, UIImage *> *capturedScreenshotsByName = integrationTestRunner.capturedScreenshotsByName;
    if (capturedScreenshotsByName.count > 0) {
        IMP screenshotImplementation = imp_implementationWithBlock(^(id _self) {
            [capturedScreenshotsByName enumerateKeysAndObjectsUsingBlock:^(NSString *name, UIImage *screenshot, BOOL *stop) {
                XCTAttachment *attachment = [XCTAttachment attachmentWithImage:screenshot];
                attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
                if (name != nil) {
                    attachment.name = name;
                }
                [_self addAttachment:attachment];
            }];
        });
        SEL attachmentSelector = NSSelectorFromString(@"screenshotPlaceholder");
        class_addMethod(self, attachmentSelector, screenshotImplementation, "v@:");
        NSMethodSignature *attachmentSignature = [self instanceMethodSignatureForSelector:attachmentSelector];
        NSInvocation *attachmentInvocation = [NSInvocation invocationWithMethodSignature:attachmentSignature];
        attachmentInvocation.selector = attachmentSelector;
        [testInvocations addObject:attachmentInvocation];
    }
    return testInvocations;
}

@end
