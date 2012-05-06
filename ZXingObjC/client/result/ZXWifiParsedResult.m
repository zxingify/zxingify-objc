#import "ZXParsedResultType.h"
#import "ZXWifiParsedResult.h"

@interface ZXWifiParsedResult ()

@property (nonatomic, copy) NSString * ssid;
@property (nonatomic, copy) NSString * networkEncryption;
@property (nonatomic, copy) NSString * password;

@end

@implementation ZXWifiParsedResult

@synthesize ssid;
@synthesize networkEncryption;
@synthesize password;

- (id)initWithNetworkEncryption:(NSString *)aNetworkEncryption ssid:(NSString *)anSsid password:(NSString *)aPassword {
  self = [super initWithType:kParsedResultTypeWifi];
  if (self) {
    self.ssid = anSsid;
    self.networkEncryption = aNetworkEncryption;
    self.password = aPassword;
  }

  return self;
}

- (void)dealloc {
  [ssid release];
  [networkEncryption release];
  [password release];
  
  [super dealloc];
}

- (NSString *)displayResult {
  NSMutableString *result = [NSMutableString stringWithCapacity:80];
  [ZXParsedResult maybeAppend:ssid result:result];
  [ZXParsedResult maybeAppend:networkEncryption result:result];
  [ZXParsedResult maybeAppend:password result:result];
  return [NSString stringWithString:result];
}

@end
