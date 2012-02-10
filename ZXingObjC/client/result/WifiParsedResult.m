#import "ParsedResultType.h"
#import "WifiParsedResult.h"

@implementation WifiParsedResult

@synthesize ssid;
@synthesize networkEncryption;
@synthesize password;
@synthesize displayResult;

- (id) initWithNetworkEncryption:(NSString *)aNetworkEncryption ssid:(NSString *)anSsid password:(NSString *)aPassword {
  if (self = [super initWithType:kParsedResultTypeWifi]) {
    ssid = [anSsid copy];
    networkEncryption = [aNetworkEncryption copy];
    password = [aPassword copy];
  }
  return self;
}

- (NSString *) displayResult {
  NSMutableString *result = [NSMutableString stringWithCapacity:80];
  [ParsedResult maybeAppend:ssid result:result];
  [ParsedResult maybeAppend:networkEncryption result:result];
  [ParsedResult maybeAppend:password result:result];
  return result;
}

- (void) dealloc {
  [ssid release];
  [networkEncryption release];
  [password release];
  [super dealloc];
}

@end
