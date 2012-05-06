#import "ZXISBNParsedResult.h"

@interface ZXISBNParsedResult ()

@property (nonatomic, copy) NSString * isbn;

@end

@implementation ZXISBNParsedResult

@synthesize isbn;

- (id)initWithIsbn:(NSString *)anIsbn {
  self = [super initWithType:kParsedResultTypeISBN];
  if (self) {
    self.isbn = anIsbn;
  }

  return self;
}

- (void) dealloc {
  [isbn release];

  [super dealloc];
}

@end
