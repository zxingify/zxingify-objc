#import "ParsedResult.h"

/**
 * @author Vikram Aggarwal
 */

@interface WifiParsedResult : ParsedResult {
  NSString * ssid;
  NSString * networkEncryption;
  NSString * password;
}

@property(nonatomic, retain, readonly) NSString * ssid;
@property(nonatomic, retain, readonly) NSString * networkEncryption;
@property(nonatomic, retain, readonly) NSString * password;
@property(nonatomic, retain, readonly) NSString * displayResult;
- (id) initWithNetworkEncryption:(NSString *)networkEncryption ssid:(NSString *)ssid password:(NSString *)password;
@end
