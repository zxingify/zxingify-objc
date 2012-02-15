#import "ParsedResultType.h"
#import "TextParsedResult.h"

@implementation TextParsedResult

@synthesize text;
@synthesize language;
@synthesize displayResult;

- (id) initWithText:(NSString *)aText language:(NSString *)aLanguage {
  if (self = [super initWithType:kParsedResultTypeText]) {
    text = [aText copy];
    language = [aLanguage copy];
  }
  return self;
}

- (void) dealloc {
  [text release];
  [language release];
  [super dealloc];
}

@end
