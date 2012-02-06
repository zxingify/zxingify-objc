#import "Mode.h"
#import "QrCodeVersion.h"

@implementation Mode

@synthesize bits;
@synthesize name;

- (id)initWithCharacterCountBitsForVersions:(NSArray *)aCharacterCountBitsForVersions
                                       bits:(int)aBits
                                       name:(NSString *)aName {
  if (self = [super init]) {
    characterCountBitsForVersions = [aCharacterCountBitsForVersions retain];
    bits = aBits;
    name = [aName copy];
  }
  return self;
}

/**
 * @param bits four bits encoding a QR Code data mode
 * @return Mode encoded by these bits
 * @throws IllegalArgumentException if bits do not correspond to a known mode
 */
+ (Mode *) forBits:(int)bits {
  switch (bits) {
    case 0x0:
      return [Mode terminatorMode];
    case 0x1:
      return [Mode numericMode];
    case 0x2:
      return [Mode alphanumericMode];
    case 0x3:
      return [Mode structuredAppendMode];
    case 0x4:
      return [Mode byteMode];
    case 0x5:
      return [Mode fnc1FirstPositionMode];
    case 0x7:
      return [Mode eciMode];
    case 0x8:
      return [Mode kanjiMode];
    case 0x9:
      return [Mode fnc1SecondPositionMode];
    case 0xD:
      return [Mode hanziMode];
    default:
      @throw [NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"Invalid bits"
                                   userInfo:nil];
  }
}

/**
 * @param version version in question
 * @return number of bits used, in this QR Code symbol {@link Version}, to encode the
 * count of characters that will follow encoded in this Mode
 */
- (int) getCharacterCountBits:(QrCodeVersion *)version {
  if (characterCountBitsForVersions == nil) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"Character count doesn't apply to this mode"
                                 userInfo:nil];
  }
  int number = [version versionNumber];
  int offset;
  if (number <= 9) {
    offset = 0;
  }
   else if (number <= 26) {
    offset = 1;
  }
   else {
    offset = 2;
  }
  return [[characterCountBitsForVersions objectAtIndex:offset] intValue];
}

- (NSString *) description {
  return name;
}

- (void) dealloc {
  [characterCountBitsForVersions release];
  [name release];
  [super dealloc];
}

+ (Mode *)terminatorMode {
  static Mode* thisMode = nil;
  if (!thisMode) {
    thisMode = [[Mode alloc] initWithCharacterCountBitsForVersions:[NSArray arrayWithObjects:
                                                                    [NSNumber numberWithInt:0],
                                                                    [NSNumber numberWithInt:0],
                                                                    [NSNumber numberWithInt:0], nil]
                                                              bits:0x00
                                                              name:@"TERMINATOR"];
  }
  return thisMode;
}

+ (Mode *)numericMode {
  static Mode* thisMode = nil;
  if (!thisMode) {
    thisMode = [[Mode alloc] initWithCharacterCountBitsForVersions:[NSArray arrayWithObjects:
                                                                    [NSNumber numberWithInt:10],
                                                                    [NSNumber numberWithInt:12],
                                                                    [NSNumber numberWithInt:14], nil]
                                                              bits:0x01
                                                              name:@"NUMERIC"];
  }
  return thisMode;
}

+ (Mode *)alphanumericMode {
  static Mode* thisMode = nil;
  if (!thisMode) {
    thisMode = [[Mode alloc] initWithCharacterCountBitsForVersions:[NSArray arrayWithObjects:
                                                                    [NSNumber numberWithInt:9],
                                                                    [NSNumber numberWithInt:11],
                                                                    [NSNumber numberWithInt:13], nil]
                                                              bits:0x02
                                                              name:@"ALPHANUMERIC"];
  }
  return thisMode;
}

+ (Mode *)structuredAppendMode {
  static Mode* thisMode = nil;
  if (!thisMode) {
    thisMode = [[Mode alloc] initWithCharacterCountBitsForVersions:[NSArray arrayWithObjects:
                                                                    [NSNumber numberWithInt:0],
                                                                    [NSNumber numberWithInt:0],
                                                                    [NSNumber numberWithInt:0], nil]
                                                              bits:0x03
                                                              name:@"STRUCTURED_APPEND"];
  }
  return thisMode;
}

+ (Mode *)byteMode {
  static Mode* thisMode = nil;
  if (!thisMode) {
    thisMode = [[Mode alloc] initWithCharacterCountBitsForVersions:[NSArray arrayWithObjects:
                                                                    [NSNumber numberWithInt:8],
                                                                    [NSNumber numberWithInt:16],
                                                                    [NSNumber numberWithInt:16], nil]
                                                              bits:0x04
                                                              name:@"BYTE"];
  }
  return thisMode;
}

+ (Mode *)eciMode {
  static Mode* thisMode = nil;
  if (!thisMode) {
    thisMode = [[Mode alloc] initWithCharacterCountBitsForVersions:nil
                                                              bits:0x07
                                                              name:@"ECI"];
  }
  return thisMode;
}

+ (Mode *)kanjiMode {
  static Mode* thisMode = nil;
  if (!thisMode) {
    thisMode = [[Mode alloc] initWithCharacterCountBitsForVersions:[NSArray arrayWithObjects:
                                                                    [NSNumber numberWithInt:8],
                                                                    [NSNumber numberWithInt:10],
                                                                    [NSNumber numberWithInt:12], nil]
                                                              bits:0x08
                                                              name:@"KANJI"];
  }
  return thisMode;
}

+ (Mode *)fnc1FirstPositionMode {
  static Mode* thisMode = nil;
  if (!thisMode) {
    thisMode = [[Mode alloc] initWithCharacterCountBitsForVersions:nil
                                                              bits:0x05
                                                              name:@"FNC1_FIRST_POSITION"];
  }
  return thisMode;
}

+ (Mode *)fnc1SecondPositionMode {
  static Mode* thisMode = nil;
  if (!thisMode) {
    thisMode = [[Mode alloc] initWithCharacterCountBitsForVersions:nil
                                                              bits:0x09
                                                              name:@"FNC1_SECOND_POSITION"];
  }
  return thisMode;
}

/**
 * See GBT 18284-2000; "Hanzi" is a transliteration of this mode name.
 */
+ (Mode *)hanziMode {
  static Mode* thisMode = nil;
  if (!thisMode) {
    thisMode = [[Mode alloc] initWithCharacterCountBitsForVersions:[NSArray arrayWithObjects:
                                                                    [NSNumber numberWithInt:8],
                                                                    [NSNumber numberWithInt:10],
                                                                    [NSNumber numberWithInt:12], nil]
                                                              bits:0x0D
                                                              name:@"HANZI"];
  }
  return thisMode;
}

@end
