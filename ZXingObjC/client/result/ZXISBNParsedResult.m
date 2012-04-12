#import "ZXISBNParsedResult.h"

@implementation ZXISBNParsedResult

@synthesize isbn;
@synthesize displayResult;

- (id) initWithIsbn:(NSString *)anIsbn {
  if (self = [super initWithType:kParsedResultTypeISBN]) {
    isbn = [isbn copy];
  }
  return self;
}

- (void) dealloc {
  [isbn release];
  [super dealloc];
}

@end
