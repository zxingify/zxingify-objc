#import "ErrorCorrectionLevel.h"


/**
 * L = ~7% correction
 */
ErrorCorrectionLevel * const L = [[[ErrorCorrectionLevel alloc] init:0 param1:0x01 param2:@"L"] autorelease];

/**
 * M = ~15% correction
 */
ErrorCorrectionLevel * const M = [[[ErrorCorrectionLevel alloc] init:1 param1:0x00 param2:@"M"] autorelease];

/**
 * Q = ~25% correction
 */
ErrorCorrectionLevel * const Q = [[[ErrorCorrectionLevel alloc] init:2 param1:0x03 param2:@"Q"] autorelease];

/**
 * H = ~30% correction
 */
ErrorCorrectionLevel * const H = [[[ErrorCorrectionLevel alloc] init:3 param1:0x02 param2:@"H"] autorelease];
NSArray * const FOR_BITS = [NSArray arrayWithObjects:M, L, H, Q, nil];

@implementation ErrorCorrectionLevel

@synthesize bits;
@synthesize name;

- (id) init:(int)ordinal bits:(int)bits name:(NSString *)name {
  if (self = [super init]) {
    ordinal = ordinal;
    bits = bits;
    name = name;
  }
  return self;
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
+ (ErrorCorrectionLevel *) forBits:(int)bits {
  if (bits < 0 || bits >= FOR_BITS.length) {
    @throw [[[IllegalArgumentException alloc] init] autorelease];
  }
  return FOR_BITS[bits];
}

- (void) dealloc {
  [name release];
  [super dealloc];
}

@end
