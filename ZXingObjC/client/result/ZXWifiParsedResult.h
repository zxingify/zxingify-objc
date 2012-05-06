#import "ZXParsedResult.h"

@interface ZXWifiParsedResult : ZXParsedResult

@property (nonatomic, copy, readonly) NSString * ssid;
@property (nonatomic, copy, readonly) NSString * networkEncryption;
@property (nonatomic, copy, readonly) NSString * password;

- (id)initWithNetworkEncryption:(NSString *)networkEncryption ssid:(NSString *)ssid password:(NSString *)password;

@end
