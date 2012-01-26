#import "QRCode.h"

int const NUM_MASK_PATTERNS = 8;

@implementation QRCode

@synthesize mode;
@synthesize eCLevel;
@synthesize version;
@synthesize matrixWidth;
@synthesize maskPattern;
@synthesize numTotalBytes;
@synthesize numDataBytes;
@synthesize numECBytes;
@synthesize numRSBlocks;
@synthesize matrix;
@synthesize valid;

- (id) init {
  if (self = [super init]) {
    mode = nil;
    ecLevel = nil;
    version = -1;
    matrixWidth = -1;
    maskPattern = -1;
    numTotalBytes = -1;
    numDataBytes = -1;
    numECBytes = -1;
    numRSBlocks = -1;
    matrix = nil;
  }
  return self;
}

- (int) at:(int)x y:(int)y {
  int value = [matrix get:x param1:y];
  if (!(value == 0 || value == 1)) {
    @throw [[[NSException alloc] init:@"Bad value"] autorelease];
  }
  return value;
}

- (BOOL) valid {
  return mode != nil && ecLevel != nil && version != -1 && matrixWidth != -1 && maskPattern != -1 && numTotalBytes != -1 && numDataBytes != -1 && numECBytes != -1 && numRSBlocks != -1 && [self isValidMaskPattern:maskPattern] && numTotalBytes == numDataBytes + numECBytes && matrix != nil && matrixWidth == [matrix width] && [matrix width] == [matrix height];
}

- (NSString *) description {
  StringBuffer * result = [[[StringBuffer alloc] init:200] autorelease];
  [result append:@"<<\n"];
  [result append:@" mode: "];
  [result append:mode];
  [result append:@"\n ecLevel: "];
  [result append:ecLevel];
  [result append:@"\n version: "];
  [result append:version];
  [result append:@"\n matrixWidth: "];
  [result append:matrixWidth];
  [result append:@"\n maskPattern: "];
  [result append:maskPattern];
  [result append:@"\n numTotalBytes: "];
  [result append:numTotalBytes];
  [result append:@"\n numDataBytes: "];
  [result append:numDataBytes];
  [result append:@"\n numECBytes: "];
  [result append:numECBytes];
  [result append:@"\n numRSBlocks: "];
  [result append:numRSBlocks];
  if (matrix == nil) {
    [result append:@"\n matrix: null\n"];
  }
   else {
    [result append:@"\n matrix:\n"];
    [result append:[matrix description]];
  }
  [result append:@">>\n"];
  return [result description];
}

+ (BOOL) isValidMaskPattern:(int)maskPattern {
  return maskPattern >= 0 && maskPattern < NUM_MASK_PATTERNS;
}

- (void) dealloc {
  [mode release];
  [ecLevel release];
  [matrix release];
  [super dealloc];
}

@end
