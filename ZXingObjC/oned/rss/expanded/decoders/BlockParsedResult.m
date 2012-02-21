#import "BlockParsedResult.h"
#import "DecodedInformation.h"

@implementation BlockParsedResult

@synthesize decodedInformation, finished;

- (id) initWithFinished:(BOOL)isFinished {
  self = [self initWithInformation:nil finished:isFinished];
  return self;
}

- (id) initWithInformation:(DecodedInformation *)information finished:(BOOL)isFinished {
  if (self = [super init]) {
    finished = isFinished;
    decodedInformation = [information retain];
  }
  return self;
}

- (void) dealloc {
  [decodedInformation release];
  [super dealloc];
}

@end
