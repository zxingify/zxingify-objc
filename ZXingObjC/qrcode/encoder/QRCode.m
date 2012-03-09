#import "ByteMatrix.h"
#import "ErrorCorrectionLevel.h"
#import "Mode.h"
#import "QRCode.h"

int const NUM_MASK_PATTERNS = 8;

@implementation QRCode

@synthesize mode;
@synthesize ecLevel;
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
  int value = [matrix get:x y:y];
  if (!(value == 0 || value == 1)) {
    [NSException raise:NSInternalInconsistencyException format:@"Bad value"];
  }
  return value;
}

- (BOOL) valid {
  return mode != nil && ecLevel != nil && version != -1 && matrixWidth != -1 && maskPattern != -1 && numTotalBytes != -1 && numDataBytes != -1 && numECBytes != -1 && numRSBlocks != -1 && [QRCode isValidMaskPattern:maskPattern] && numTotalBytes == numDataBytes + numECBytes && matrix != nil && matrixWidth == [matrix width] && [matrix width] == [matrix height];
}

- (NSString *) description {
  NSMutableString *result = [NSMutableString stringWithCapacity:200];
  [result appendFormat:@"<<\n mode: %@", mode];
  [result appendFormat:@"\n ecLevel: %@", ecLevel];
  [result appendFormat:@"\n version: %d", version];
  [result appendFormat:@"\n matrixWidth: %d", matrixWidth];
  [result appendFormat:@"\n maskPattern: %d", maskPattern];
  [result appendFormat:@"\n numTotalBytes: %d", numTotalBytes];
  [result appendFormat:@"\n numDataBytes: %d", numDataBytes];
  [result appendFormat:@"\n numECBytes: %d", numECBytes];
  [result appendFormat:@"\n numRSBlocks: %d", numRSBlocks];
  if (matrix == nil) {
    [result appendString:@"\n matrix: null\n"];
  } else {
    [result appendFormat:@"\n matrix:\n%@", [matrix description]];
  }
  [result appendString:@">>\n"];
  return result;
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
