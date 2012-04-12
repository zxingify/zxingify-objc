#import "ZXAztecDetectorResult.h"

@implementation ZXAztecDetectorResult

@synthesize nbLayers;
@synthesize nbDatablocks;
@synthesize compact;

- (id) initWithBits:(ZXBitMatrix *)_bits points:(NSArray *)_points compact:(BOOL)_compact nbDatablocks:(int)_nbDatablocks nbLayers:(int)_nbLayers {
  if (self = [super initWithBits:_bits points:_points]) {
    compact = _compact;
    nbDatablocks = _nbDatablocks;
    nbLayers = _nbLayers;
  }
  return self;
}

@end
