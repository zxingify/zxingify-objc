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
    return moduleSizeDiff <= 1.0f || moduleSizeDiff / self.estimatedModuleSize <= 1.0f;
  }

  return NO;
}

@end
