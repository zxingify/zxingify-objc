#import "ZXAztecDetectorResult.h"

@interface ZXAztecDetectorResult ()

@property(nonatomic, readwrite) int nbLayers;
@property(nonatomic, readwrite) int nbDatablocks;
@property(nonatomic, readwrite) BOOL compact;

@end

@implementation ZXAztecDetectorResult

@synthesize nbLayers;
@synthesize nbDatablocks;
@synthesize compact;

- (id)initWithBits:(ZXBitMatrix *)_bits points:(NSArray *)_points compact:(BOOL)_compact
      nbDatablocks:(int)_nbDatablocks nbLayers:(int)_nbLayers {
  self = [super initWithBits:_bits points:_points];
  if (self) {
    self.compact = _compact;
    self.nbDatablocks = _nbDatablocks;
    self.nbLayers = _nbLayers;
  }

  return self;
}

@end
