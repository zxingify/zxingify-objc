#import "Mode.h"

Mode * const TERMINATOR = [[[Mode alloc] init:[NSArray arrayWithObjects:0, 0, 0, nil] param1:0x00 param2:@"TERMINATOR"] autorelease];
Mode * const NUMERIC = [[[Mode alloc] init:[NSArray arrayWithObjects:10, 12, 14, nil] param1:0x01 param2:@"NUMERIC"] autorelease];
Mode * const ALPHANUMERIC = [[[Mode alloc] init:[NSArray arrayWithObjects:9, 11, 13, nil] param1:0x02 param2:@"ALPHANUMERIC"] autorelease];
Mode * const STRUCTURED_APPEND = [[[Mode alloc] init:[NSArray arrayWithObjects:0, 0, 0, nil] param1:0x03 param2:@"STRUCTURED_APPEND"] autorelease];
Mode * const BYTE = [[[Mode alloc] init:[NSArray arrayWithObjects:8, 16, 16, nil] param1:0x04 param2:@"BYTE"] autorelease];
Mode * const ECI = [[[Mode alloc] init:nil param1:0x07 param2:@"ECI"] autorelease];
Mode * const KANJI = [[[Mode alloc] init:[NSArray arrayWithObjects:8, 10, 12, nil] param1:0x08 param2:@"KANJI"] autorelease];
Mode * const FNC1_FIRST_POSITION = [[[Mode alloc] init:nil param1:0x05 param2:@"FNC1_FIRST_POSITION"] autorelease];
Mode * const FNC1_SECOND_POSITION = [[[Mode alloc] init:nil param1:0x09 param2:@"FNC1_SECOND_POSITION"] autorelease];

/**
 * See GBT 18284-2000; "Hanzi" is a transliteration of this mode name.
 */
Mode * const HANZI = [[[Mode alloc] init:[NSArray arrayWithObjects:8, 10, 12, nil] param1:0x0D param2:@"HANZI"] autorelease];

@implementation Mode

@synthesize bits;
@synthesize name;

- (id) init:(NSArray *)characterCountBitsForVersions bits:(int)bits name:(NSString *)name {
  if (self = [super init]) {
    characterCountBitsForVersions = characterCountBitsForVersions;
    bits = bits;
    name = name;
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
    return TERMINATOR;
  case 0x1:
    return NUMERIC;
  case 0x2:
    return ALPHANUMERIC;
  case 0x3:
    return STRUCTURED_APPEND;
  case 0x4:
    return BYTE;
  case 0x5:
    return FNC1_FIRST_POSITION;
  case 0x7:
    return ECI;
  case 0x8:
    return KANJI;
  case 0x9:
    return FNC1_SECOND_POSITION;
  case 0xD:
    return HANZI;
  default:
    @throw [[[IllegalArgumentException alloc] init] autorelease];
  }
}


/**
 * @param version version in question
 * @return number of bits used, in this QR Code symbol {@link Version}, to encode the
 * count of characters that will follow encoded in this Mode
 */
- (int) getCharacterCountBits:(Version *)version {
  if (characterCountBitsForVersions == nil) {
    @throw [[[IllegalArgumentException alloc] init:@"Character count doesn't apply to this mode"] autorelease];
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
  return characterCountBitsForVersions[offset];
}

- (NSString *) description {
  return name;
}

- (void) dealloc {
  [characterCountBitsForVersions release];
  [name release];
  [super dealloc];
}

@end
