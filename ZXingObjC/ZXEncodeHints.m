#import "ZXEncodeHints.h"

@implementation ZXEncodeHints

@synthesize encoding;
@synthesize errorCorrectionLevel;

+ (ZXEncodeHints*)hints {
  return [[[self alloc] init] autorelease];
}

- (void)dealloc {
  [errorCorrectionLevel release];

  [super dealloc];
}

@end