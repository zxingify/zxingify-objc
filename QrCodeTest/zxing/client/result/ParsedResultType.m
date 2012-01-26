#import "ParsedResultType.h"

ParsedResultType * const ADDRESSBOOK = [[[ParsedResultType alloc] init:@"ADDRESSBOOK"] autorelease];
ParsedResultType * const EMAIL_ADDRESS = [[[ParsedResultType alloc] init:@"EMAIL_ADDRESS"] autorelease];
ParsedResultType * const PRODUCT = [[[ParsedResultType alloc] init:@"PRODUCT"] autorelease];
ParsedResultType * const URI = [[[ParsedResultType alloc] init:@"URI"] autorelease];
ParsedResultType * const TEXT = [[[ParsedResultType alloc] init:@"TEXT"] autorelease];
ParsedResultType * const ANDROID_INTENT = [[[ParsedResultType alloc] init:@"ANDROID_INTENT"] autorelease];
ParsedResultType * const GEO = [[[ParsedResultType alloc] init:@"GEO"] autorelease];
ParsedResultType * const TEL = [[[ParsedResultType alloc] init:@"TEL"] autorelease];
ParsedResultType * const SMS = [[[ParsedResultType alloc] init:@"SMS"] autorelease];
ParsedResultType * const CALENDAR = [[[ParsedResultType alloc] init:@"CALENDAR"] autorelease];
ParsedResultType * const WIFI = [[[ParsedResultType alloc] init:@"WIFI"] autorelease];
ParsedResultType * const NDEF_SMART_POSTER = [[[ParsedResultType alloc] init:@"NDEF_SMART_POSTER"] autorelease];
ParsedResultType * const MOBILETAG_RICH_WEB = [[[ParsedResultType alloc] init:@"MOBILETAG_RICH_WEB"] autorelease];
ParsedResultType * const ISBN = [[[ParsedResultType alloc] init:@"ISBN"] autorelease];

@implementation ParsedResultType

- (id) initWithName:(NSString *)name {
  if (self = [super init]) {
    name = name;
  }
  return self;
}

- (NSString *) description {
  return name;
}

- (void) dealloc {
  [name release];
  [super dealloc];
}

@end
