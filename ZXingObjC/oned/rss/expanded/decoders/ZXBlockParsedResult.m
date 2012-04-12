#import "ZXBlockParsedResult.h"
#import "ZXDecodedInformation.h"

@implementation ZXBlockParsedResult

@synthesize decodedInformation, finished;

- (id) initWithFinished:(BOOL)isFinished {
  self = [self initWithInformation:nil finished:isFinished];
  return self;
}

- (id) initWithInformation:(ZXDecodedInformation *)information finished:(BOOL)isFinished {
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
