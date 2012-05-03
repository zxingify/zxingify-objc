#import "ZXEncodeHints.h"

@implementation ZXEncodeHints

@synthesize encoding;
@synthesize errorCorrectionLevel;

- (void)dealloc {
  [errorCorrectionLevel release];

  [super dealloc];
}

@end