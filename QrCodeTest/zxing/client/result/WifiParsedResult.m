#import "WifiParsedResult.h"

@implementation WifiParsedResult

@synthesize ssid;
@synthesize networkEncryption;
@synthesize password;
@synthesize displayResult;

- (id) init:(NSString *)networkEncryption ssid:(NSString *)ssid password:(NSString *)password {
  if (self = [super init:ParsedResultType.WIFI]) {
    ssid = ssid;
    networkEncryption = networkEncryption;
    password = password;
  }
  return self;
}

- (NSString *) displayResult {
  StringBuffer * result = [[[StringBuffer alloc] init:80] autorelease];
  [self maybeAppend:ssid param1:result];
  [self maybeAppend:networkEncryption param1:result];
  [self maybeAppend:password param1:result];
  return [result description];
}

- (void) dealloc {
  [ssid release];
  [networkEncryption release];
  [password release];
  [super dealloc];
}

@end
