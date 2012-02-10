#import "TelParsedResult.h"

@implementation TelParsedResult

@synthesize number;
@synthesize telURI;
@synthesize title;
@synthesize displayResult;

- (id) initWithNumber:(NSString *)aNumber telURI:(NSString *)aTelURI title:(NSString *)aTitle {
  if (self = [super initWithType:kParsedResultTypeTel]) {
    number = [aNumber copy];
    telURI = [aTelURI copy];
    title = [aTitle copy];
  }
  return self;
}

- (NSString *) displayResult {
  NSMutableString *result = [NSMutableString stringWithCapacity:20];
  [ParsedResult maybeAppend:number result:result];
  [ParsedResult maybeAppend:title result:result];
  return result;
}

- (void) dealloc {
  [number release];
  [telURI release];
  [title release];
  [super dealloc];
}

@end
