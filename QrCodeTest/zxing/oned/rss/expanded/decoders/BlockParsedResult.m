#import "BlockParsedResult.h"

@implementation BlockParsedResult

- (id) init {
  if (self = [super init]) {
    finished = YES;
    decodedInformation = nil;
  }
  return self;
}

- (id) initWithFinished:(BOOL)finished {
  if (self = [super init]) {
    finished = finished;
    decodedInformation = nil;
  }
  return self;
}

- (id) init:(DecodedInformation *)information finished:(BOOL)finished {
  if (self = [super init]) {
    finished = finished;
    decodedInformation = information;
  }
  return self;
}

- (DecodedInformation *) getDecodedInformation {
  return decodedInformation;
}

- (BOOL) isFinished {
  return finished;
}

- (void) dealloc {
  [decodedInformation release];
  [super dealloc];
}

@end
