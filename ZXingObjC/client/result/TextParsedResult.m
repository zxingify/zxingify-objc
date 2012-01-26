#import "TextParsedResult.h"

@implementation TextParsedResult

@synthesize text;
@synthesize language;
@synthesize displayResult;

- (id) init:(NSString *)text language:(NSString *)language {
  if (self = [super init:ParsedResultType.TEXT]) {
    text = text;
    language = language;
  }
  return self;
}

- (void) dealloc {
  [text release];
  [language release];
  [super dealloc];
}

@end
