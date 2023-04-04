//
//  AWSIntegrationTestRunner.m
//  aws_integration_test
//
//  Created by Mazen Bilbiesi on 21/03/2023.
//

#import <Foundation/Foundation.h>
#import "AWSIntegrationTestRunner.h"
#import "AwsIntegrationTestPlugin.h"

@import ObjectiveC.runtime;
@import UIKit;
@import XCTest;

@interface AWSIntegrationTestRunner ()

@property AwsIntegrationTestPlugin *integrationTestPlugin;

@end

@implementation AWSIntegrationTestRunner

- (instancetype)init {
    self = [super init];
    _integrationTestPlugin = [AwsIntegrationTestPlugin instance];
    
    return self;
}


- (void)testIntegrationTestWithResults:(NSDictionary<NSString *, NSString *> *)tests
                                      : (NS_NOESCAPE AWSIntegrationTestResults)testResult {
    
    NSMutableSet<NSString *> *testCaseNames = [[NSMutableSet alloc] init];
    [tests enumerateKeysAndObjectsUsingBlock:^(NSString *test, NSString *result, BOOL *stop) {
        NSString *testSelectorName = [[self class] testCaseNameFromDartTestName:test];
        
        // Validate Objective-C test names are unique after sanitization.
        if ([testCaseNames containsObject:testSelectorName]) {
            NSString *reason = [NSString stringWithFormat:@"Cannot test \"%@\", duplicate XCTestCase tests named %@", test, testSelectorName];
            testResult(NSSelectorFromString(@"testDuplicateTestNames"), NO, reason);
            *stop = YES;
            return;
        }
        [testCaseNames addObject:testSelectorName];
        SEL testSelector = NSSelectorFromString(testSelectorName);
        
        if ([result isEqualToString:@"success"]) {
            testResult(testSelector, YES, nil);
        } else {
            testResult(testSelector, NO, result);
        }
    }];
}

- (NSDictionary<NSString *,UIImage *> *)capturedScreenshotsByName {
    return self.integrationTestPlugin.capturedScreenshotsByName;
}

+ (NSString *)testCaseNameFromDartTestName:(NSString *)dartTestName {
    NSString *capitalizedString = dartTestName.localizedCapitalizedString;
    // Objective-C method names must be alphanumeric.
    NSCharacterSet *disallowedCharacters = NSCharacterSet.alphanumericCharacterSet.invertedSet;
    // Remove disallowed characters.
    NSString *upperCamelTestName = [[capitalizedString componentsSeparatedByCharactersInSet:disallowedCharacters] componentsJoinedByString:@""];
    return [NSString stringWithFormat:@"test%@", upperCamelTestName];
}

@end
