#import "ISBNParsedResult.h"

@implementation ISBNParsedResult

@synthesize iSBN;
@synthesize displayResult;

- (id) initWithIsbn:(NSString *)isbn {
  if (self = [super init:ParsedResultType.ISBN]) {
    isbn = isbn;
  }
  return self;
}

- (void) dealloc {
  [isbn release];
  [super dealloc];
}

@end
