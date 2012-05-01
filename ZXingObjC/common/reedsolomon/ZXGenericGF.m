#import "ZXGenericGF.h"
#import "ZXGenericGFPoly.h"

int const INITIALIZATION_THRESHOLD = 0;

@interface ZXGenericGF ()

- (void) initialize;

@end

@implementation ZXGenericGF

@synthesize size;


/**
 * Create a representation of GF(size) using the given primitive polynomial.
 * 
 * @param primitive irreducible polynomial whose coefficients are represented by
 * the bits of an int, where the least-significant bit represents the constant
 * coefficient
 */
- (id) initWithPrimitive:(int)aPrimitive size:(int)aSize {
  if (self = [super init]) {
    initialized = NO;
    primitive = aPrimitive;
    size = aSize;
    if (size <= INITIALIZATION_THRESHOLD) {
      [self initialize];
    }
  }
  return self;
}

- (void) initialize {
  expTable = [[NSMutableArray alloc] initWithCapacity:size];
  logTable = [[NSMutableArray alloc] initWithCapacity:size];
  int x = 1;

  for (int i = 0; i < size; i++) {
    [expTable addObject:[NSNumber numberWithInt:x]];
    x <<= 1;
    if (x >= size) {
      x ^= primitive;
      x &= size - 1;
    }
  }

  for (int i = 0; i < size; i++) {
    [logTable addObject:[NSNull null]];
  }

  for (int i = 0; i < size - 1; i++) {
    [logTable replaceObjectAtIndex:[[expTable objectAtIndex:i] intValue] withObject:[NSNumber numberWithInt:i]];
  }

  zero = [[ZXGenericGFPoly alloc] initWithField:self coefficients:[NSArray arrayWithObjects:[NSNumber numberWithInt:0], nil]];
  one = [[ZXGenericGFPoly alloc] initWithField:self coefficients:[NSArray arrayWithObjects:[NSNumber numberWithInt:1], nil]];
  initialized = YES;
}

+ (ZXGenericGF *)AztecData12 {
  static ZXGenericGF *AztecData12 = nil;
  if (!AztecData12) {
    AztecData12 = [[ZXGenericGF alloc] initWithPrimitive:0x1069 size:4096];
  }
  return AztecData12;
}

+ (ZXGenericGF *)AztecData10 {
  static ZXGenericGF *AztecData10 = nil;
  if (!AztecData10) {
    AztecData10 = [[ZXGenericGF alloc] initWithPrimitive:0x409 size:1024];
  }
  return AztecData10;
}

+ (ZXGenericGF *)AztecData6 {
  static ZXGenericGF *AztecData6 = nil;
  if (!AztecData6) {
    AztecData6 = [[ZXGenericGF alloc] initWithPrimitive:0x43 size:64];
  }
  return AztecData6;
}

+ (ZXGenericGF *)AztecDataParam {
  static ZXGenericGF *AztecDataParam = nil;
  if (!AztecDataParam) {
    AztecDataParam = [[ZXGenericGF alloc] initWithPrimitive:0x13 size:16];
  }
  return AztecDataParam;
}

+ (ZXGenericGF *)QrCodeField256 {
  static ZXGenericGF *QrCodeField256 = nil;
  if (!QrCodeField256) {
    QrCodeField256 = [[ZXGenericGF alloc] initWithPrimitive:0x011D size:256];
  }
  return QrCodeField256;
}

+ (ZXGenericGF *)DataMatrixField256 {
  static ZXGenericGF *DataMatrixField256 = nil;
  if (!DataMatrixField256) {
    DataMatrixField256 = [[ZXGenericGF alloc] initWithPrimitive:0x012D size:256];
  }
  return DataMatrixField256;
}

+ (ZXGenericGF *)AztecData8 {
  return [self DataMatrixField256];
}

- (void) checkInit {
  if (!initialized) {
    [self initialize];
  }
}

- (ZXGenericGFPoly *) zero {
  [self checkInit];

  return zero;
}

- (ZXGenericGFPoly *) one {
  [self checkInit];

  return one;
}


/**
 * @return the monomial representing coefficient * x^degree
 */
- (ZXGenericGFPoly *) buildMonomial:(int)degree coefficient:(int)coefficient {
  [self checkInit];

  if (degree < 0) {
    [NSException raise:NSInvalidArgumentException format:@"Degree must be greater than 0."];
  }
  if (coefficient == 0) {
    return zero;
  }
  NSMutableArray * coefficients = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:coefficient]];
  for (int i = 1; i < degree + 1; i++) {
    [coefficients addObject:[NSNumber numberWithInt:0]];
  }
  return [[[ZXGenericGFPoly alloc] initWithField:self coefficients:coefficients] autorelease];
}


/**
 * Implements both addition and subtraction -- they are the same in GF(size).
 * 
 * @return sum/difference of a and b
 */
+ (int) addOrSubtract:(int)a b:(int)b {
  return a ^ b;
}


/**
 * @return 2 to the power of a in GF(size)
 */
- (int) exp:(int)a {
  [self checkInit];
  return [[expTable objectAtIndex:a] intValue];
}


/**
 * @return base 2 log of a in GF(size)
 */
- (int) log:(int)a {
  [self checkInit];
  if (a == 0) {
    [NSException raise:NSInvalidArgumentException format:@"Argument must be non-zero."];
  }
  return [[logTable objectAtIndex:a] intValue];
}


/**
 * @return multiplicative inverse of a
 */
- (int) inverse:(int)a {
  [self checkInit];

  if (a == 0) {
    [NSException raise:NSInvalidArgumentException format:@"Argument must be non-zero."];
  }
  return [[expTable objectAtIndex:size - [[logTable objectAtIndex:a] intValue] - 1] intValue];
}


/**
 * @param a
 * @param b
 * @return product of a and b in GF(size)
 */
- (int) multiply:(int)a b:(int)b {
  [self checkInit];

  if (a == 0 || b == 0) {
    return 0;
  }

  if (a < 0 || b < 0 || a >= size || b >= size) {
    a++;
  }

  int logSum = [[logTable objectAtIndex:a] intValue] + [[logTable objectAtIndex:b] intValue];
  return [[expTable objectAtIndex:(logSum % size) + logSum / size] intValue];
}

- (void) dealloc {
  [expTable release];
  [logTable release];
  [zero release];
  [one release];
  [super dealloc];
}

@end
