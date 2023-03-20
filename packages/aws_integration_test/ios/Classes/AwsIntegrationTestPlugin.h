#import <Flutter/Flutter.h>


NS_ASSUME_NONNULL_BEGIN

@interface AwsIntegrationTestPlugin : NSObject<FlutterPlugin>
/**
 * Test results that are sent from Dart when integration test completes. Before the
 * completion, it is @c nil.
 */
@property(nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> *testResults;

/**
 * Mapping of screenshot images by suggested names, captured by the dart tests.
 */
@property (copy, readonly) NSDictionary<NSString *, UIImage *> *capturedScreenshotsByName;

/** Fetches the singleton instance of the plugin. */
+ (AwsIntegrationTestPlugin *)instance;


- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

