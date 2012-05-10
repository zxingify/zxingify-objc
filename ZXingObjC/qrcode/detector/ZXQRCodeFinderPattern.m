#import "ZXQRCodeFinderPattern.h"

@interface ZXQRCodeFinderPattern ()

@property (nonatomic, assign) int count;
@property (nonatomic, assign) float estimatedModuleSize;

@end

@implementation ZXQRCodeFinderPattern

@synthesize count;
@synthesize estimatedModuleSize;

- (id)initWithPosX:(float)posX posY:(float)posY estimatedModuleSize:(float)anEstimatedModuleSize {
  if (self = [super initWithX:posX y:posY]) {
    self.estimatedModuleSize = anEstimatedModuleSize;
    self.count = 1;
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
    return moduleSizeDiff <= 1.0f || moduleSizeDiff / self.estimatedModuleSize <= 1.0f;
  }
  return NO;
}

@end
