#import "ZXParsedResultType.h"
#import "ZXTextParsedResult.h"

@implementation ZXTextParsedResult

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
