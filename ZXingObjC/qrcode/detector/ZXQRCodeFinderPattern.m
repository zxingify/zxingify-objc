#import "ZXQRCodeFinderPattern.h"

@interface ZXQRCodeFinderPattern ()

@property (nonatomic, assign) int count;
@property (nonatomic, assign) float estimatedModuleSize;

@end

@implementation ZXQRCodeFinderPattern

@synthesize count;
@synthesize estimatedModuleSize;

- (id)initWithPosX:(float)posX posY:(float)posY estimatedModuleSize:(float)anEstimatedModuleSize {
  return [self initWithPosX:posX posY:posY estimatedModuleSize:anEstimatedModuleSize count:1];
}

- (id)initWithPosX:(float)posX posY:(float)posY estimatedModuleSize:(float)anEstimatedModuleSize count:(int)aCount {
  if (self = [super initWithX:posX y:posY]) {
    self.estimatedModuleSize = anEstimatedModuleSize;
    self.count = aCount;
  }

  return self;
}

- (void)incrementCount {
  self.count++;
}

/**
 * Determines if this finder pattern "about equals" a finder pattern at the stated
 * position and size -- meaning, it is at nearly the same center with nearly the same size.
 */
- (BOOL)aboutEquals:(float)moduleSize i:(float)i j:(float)j {
  if (fabsf(i - [self y]) <= moduleSize && fabsf(j - [self x]) <= moduleSize) {
    float moduleSizeDiff = fabsf(moduleSize - self.estimatedModuleSize);
    return moduleSizeDiff <= 1.0f || moduleSizeDiff <= estimatedModuleSize;
  }
  return NO;
}

/**
 * Combines this object's current estimate of a finder pattern position and module size
 * with a new estimate. It returns a new ZXQRCodeFinderPattern containing a weighted average
 * based on count.
 */
- (ZXQRCodeFinderPattern*)combineEstimateI:(float)i j:(float)j newModuleSize:(float)newModuleSize {
  int combinedCount = self.count + 1;
  float combinedX = (self.count * self.x + j) / combinedCount;
  float combinedY = (self.count * self.y + i) / combinedCount;
  float combinedModuleSize = (self.count * self.estimatedModuleSize + newModuleSize) / combinedCount;
  return [[[ZXQRCodeFinderPattern alloc] initWithPosX:combinedX
                                                 posY:combinedY
                                  estimatedModuleSize:combinedModuleSize
                                                count:combinedCount] autorelease];
}

@end
