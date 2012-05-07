#import "ZXISBNParsedResult.h"

@interface ZXISBNParsedResult ()

@property (nonatomic, copy) NSString * isbn;

@end

@implementation ZXISBNParsedResult

@synthesize isbn;

- (id)initWithIsbn:(NSString *)anIsbn {
  if (self = [super initWithType:kParsedResultTypeISBN]) {
    self.isbn = anIsbn;
  }

  return self;
}

- (void)dealloc {
  [isbn release];

  [super dealloc];
}

@end
