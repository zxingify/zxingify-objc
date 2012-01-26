#import "TelParsedResult.h"

@implementation TelParsedResult

@synthesize number;
@synthesize telURI;
@synthesize title;
@synthesize displayResult;

- (id) init:(NSString *)number telURI:(NSString *)telURI title:(NSString *)title {
  if (self = [super init:ParsedResultType.TEL]) {
    number = number;
    telURI = telURI;
    title = title;
  }
  return self;
}

- (NSString *) displayResult {
  StringBuffer * result = [[[StringBuffer alloc] init:20] autorelease];
  [self maybeAppend:number param1:result];
  [self maybeAppend:title param1:result];
  return [result description];
}

- (void) dealloc {
  [number release];
  [telURI release];
  [title release];
  [super dealloc];
}

@end
