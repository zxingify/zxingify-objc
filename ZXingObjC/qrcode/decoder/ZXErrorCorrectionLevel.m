#import "ZXErrorCorrectionLevel.h"

@implementation ZXErrorCorrectionLevel

static NSArray* FOR_BITS = nil;

@synthesize bits;
@synthesize name;

- (id)initWithOrdinal:(int)anOrdinal bits:(int)theBits name:(NSString *)aName {
  if (self = [super init]) {
    ordinal = anOrdinal;
    bits = theBits;
    name = [aName copy];
  }
  return self;
}

- (void)dealloc {
  [name release];
  [super dealloc];
}

- (int) ordinal {
  return ordinal;
}

- (NSString *) description {
  return name;
}


/**
 * @param bits int containing the two bits encoding a QR Code's error correction level
 * @return ErrorCorrectionLevel representing the encoded error correction level
 */
+ (ZXErrorCorrectionLevel *) forBits:(int)bits {
  if (!FOR_BITS) {
    FOR_BITS = [NSArray arrayWithObjects:[ZXErrorCorrectionLevel errorCorrectionLevelM],
                [ZXErrorCorrectionLevel errorCorrectionLevelL], [ZXErrorCorrectionLevel errorCorrectionLevelH],
                [ZXErrorCorrectionLevel errorCorrectionLevelQ], nil];
  }

  if (bits < 0 || bits >= [FOR_BITS count]) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"Invalid bits"
                                 userInfo:nil];
  }
  return [FOR_BITS objectAtIndex:bits];
}

/**
 * L = ~7% correction
 */
+ (ZXErrorCorrectionLevel *)errorCorrectionLevelL {
  static ZXErrorCorrectionLevel* thisLevel = nil;
  if (!thisLevel) {
    thisLevel = [[ZXErrorCorrectionLevel alloc] initWithOrdinal:0 bits:0x01 name:@"L"];
  }
  return thisLevel;
}

/**
 * M = ~15% correction
 */
+ (ZXErrorCorrectionLevel *)errorCorrectionLevelM {
  static ZXErrorCorrectionLevel* thisLevel = nil;
  if (!thisLevel) {
    thisLevel = [[ZXErrorCorrectionLevel alloc] initWithOrdinal:1 bits:0x00 name:@"M"];
  }
  return thisLevel;
}

/**
 * Q = ~25% correction
 */
+ (ZXErrorCorrectionLevel *)errorCorrectionLevelQ {
  static ZXErrorCorrectionLevel* thisLevel = nil;
  if (!thisLevel) {
    thisLevel = [[ZXErrorCorrectionLevel alloc] initWithOrdinal:2 bits:0x03 name:@"Q"];
  }
  return thisLevel;
}

/**
 * H = ~30% correction
 */
+ (ZXErrorCorrectionLevel *)errorCorrectionLevelH {
  static ZXErrorCorrectionLevel* thisLevel = nil;
  if (!thisLevel) {
    thisLevel = [[ZXErrorCorrectionLevel alloc] initWithOrdinal:3 bits:0x02 name:@"H"];
  }
  return thisLevel;
}

@end
