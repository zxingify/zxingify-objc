#import "FinderPattern.h"

@implementation FinderPattern

@synthesize estimatedModuleSize;

- (id) init:(float)posX posY:(float)posY estimatedModuleSize:(float)estimatedModuleSize {
  if (self = [super init:posX param1:posY]) {
    estimatedModuleSize = estimatedModuleSize;
    count = 1;
  }
  return self;
}

- (int) getCount {
  return count;
}

- (void) incrementCount {
  count++;
}


/**
 * <p>Determines if this finder pattern "about equals" a finder pattern at the stated
 * position and size -- meaning, it is at nearly the same center with nearly the same size.</p>
 */
- (BOOL) aboutEquals:(float)moduleSize i:(float)i j:(float)j {
  if ([Math abs:i - [self y]] <= moduleSize && [Math abs:j - [self x]] <= moduleSize) {
    float moduleSizeDiff = [Math abs:moduleSize - estimatedModuleSize];
    return moduleSizeDiff <= 1.0f || moduleSizeDiff / estimatedModuleSize <= 1.0f;
  }
  return NO;
}

@end
