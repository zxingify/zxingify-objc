#import "AztecDetectorResult.h"

@implementation AztecDetectorResult

@synthesize nbLayers;
@synthesize nbDatablocks;
@synthesize compact;

- (id) init:(BitMatrix *)bits points:(NSArray *)points compact:(BOOL)compact nbDatablocks:(int)nbDatablocks nbLayers:(int)nbLayers {
  if (self = [super init:bits param1:points]) {
    compact = compact;
    nbDatablocks = nbDatablocks;
    nbLayers = nbLayers;
  }
  return self;
}

@end
