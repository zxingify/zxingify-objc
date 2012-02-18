#import "QRCodeFinderPattern.h"

@implementation QRCodeFinderPattern

@synthesize count, estimatedModuleSize;

- (id) initWithPosX:(float)posX posY:(float)posY estimatedModuleSize:(float)anEstimatedModuleSize {
  if (self = [super initWithX:posX y:posY]) {
    estimatedModuleSize = anEstimatedModuleSize;
    count = 1;
  }
  return self;
}

- (void) incrementCount {
  count++;
}


/**
 * <p>Determines if this finder pattern "about equals" a finder pattern at the stated
 * position and size -- meaning, it is at nearly the same center with nearly the same size.</p>
 */
- (BOOL) aboutEquals:(float)moduleSize i:(float)i j:(float)j {
  if (abs(i - [self y]) <= moduleSize && abs(j - [self x]) <= moduleSize) {
    float moduleSizeDiff = abs(moduleSize - estimatedModuleSize);
    return moduleSizeDiff <= 1.0f || moduleSizeDiff / estimatedModuleSize <= 1.0f;
  }
  return NO;
}

@end
