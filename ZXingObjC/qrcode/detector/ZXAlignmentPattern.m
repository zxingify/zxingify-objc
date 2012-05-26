#import "ZXAlignmentPattern.h"

@interface ZXAlignmentPattern ()

@property (nonatomic, assign) float estimatedModuleSize;

@end

@implementation ZXAlignmentPattern

@synthesize estimatedModuleSize;

- (id)initWithPosX:(float)posX posY:(float)posY estimatedModuleSize:(float)anEstimatedModuleSize {
  if (self = [super initWithX:posX y:posY]) {
    self.estimatedModuleSize = anEstimatedModuleSize;
  }

  return self;
}

/**
 * Determines if this alignment pattern "about equals" an alignment pattern at the stated
 * position and size -- meaning, it is at nearly the same center with nearly the same size.
 */
- (BOOL)aboutEquals:(float)moduleSize i:(float)i j:(float)j {
  if (fabsf(i - self.y) <= moduleSize && fabsf(j - self.x) <= moduleSize) {
    float moduleSizeDiff = fabsf(moduleSize - self.estimatedModuleSize);
    return moduleSizeDiff <= 1.0f || moduleSizeDiff <= estimatedModuleSize;
  }

  return NO;
}

/**
 * Combines this object's current estimate of a finder pattern position and module size
 * with a new estimate. It returns a new FinderPattern containing an average of the two.
 */
- (ZXAlignmentPattern*)combineEstimateI:(float)i j:(float)j newModuleSize:(float)newModuleSize {
  float combinedX = (self.x + j) / 2.0f;
  float combinedY = (self.y + i) / 2.0f;
  float combinedModuleSize = (self.estimatedModuleSize + newModuleSize) / 2.0f;
  return [[[ZXAlignmentPattern alloc] initWithPosX:combinedX posY:combinedY estimatedModuleSize:combinedModuleSize] autorelease];
}

@end
