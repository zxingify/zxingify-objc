#import "GenericGF.h"

GenericGF * const AZTEC_DATA_12 = [[[GenericGF alloc] init:0x1069 param1:4096] autorelease];
GenericGF * const AZTEC_DATA_10 = [[[GenericGF alloc] init:0x409 param1:1024] autorelease];
GenericGF * const AZTEC_DATA_6 = [[[GenericGF alloc] init:0x43 param1:64] autorelease];
GenericGF * const AZTEC_PARAM = [[[GenericGF alloc] init:0x13 param1:16] autorelease];
GenericGF * const QR_CODE_FIELD_256 = [[[GenericGF alloc] init:0x011D param1:256] autorelease];
GenericGF * const DATA_MATRIX_FIELD_256 = [[[GenericGF alloc] init:0x012D param1:256] autorelease];
GenericGF * const AZTEC_DATA_8 = DATA_MATRIX_FIELD_256;
int const INITIALIZATION_THRESHOLD = 0;

@implementation GenericGF

@synthesize size;


/**
 * Create a representation of GF(size) using the given primitive polynomial.
 * 
 * @param primitive irreducible polynomial whose coefficients are represented by
 * the bits of an int, where the least-significant bit represents the constant
 * coefficient
 */
- (id) init:(int)primitive size:(int)size {
  if (self = [super init]) {
    initialized = NO;
    primitive = primitive;
    size = size;
    if (size <= INITIALIZATION_THRESHOLD) {
      [self initialize];
    }
  }
  return self;
}

- (void) initialize {
  expTable = [NSArray array];
  logTable = [NSArray array];
  int x = 1;

  for (int i = 0; i < size; i++) {
    expTable[i] = x;
    x <<= 1;
    if (x >= size) {
      x ^= primitive;
      x &= size - 1;
    }
  }


  for (int i = 0; i < size - 1; i++) {
    logTable[expTable[i]] = i;
  }

  zero = [[[GenericGFPoly alloc] init:self param1:[NSArray arrayWithObjects:0, nil]] autorelease];
  one = [[[GenericGFPoly alloc] init:self param1:[NSArray arrayWithObjects:1, nil]] autorelease];
  initialized = YES;
}

- (void) checkInit {
  if (!initialized) {
    [self initialize];
  }
}

- (GenericGFPoly *) getZero {
  [self checkInit];
  return zero;
}

- (GenericGFPoly *) getOne {
  [self checkInit];
  return one;
}


/**
 * @return the monomial representing coefficient * x^degree
 */
- (GenericGFPoly *) buildMonomial:(int)degree coefficient:(int)coefficient {
  [self checkInit];
  if (degree < 0) {
    @throw [[[IllegalArgumentException alloc] init] autorelease];
  }
  if (coefficient == 0) {
    return zero;
  }
  NSArray * coefficients = [NSArray array];
  coefficients[0] = coefficient;
  return [[[GenericGFPoly alloc] init:self param1:coefficients] autorelease];
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
  return expTable[a];
}


/**
 * @return base 2 log of a in GF(size)
 */
- (int) log:(int)a {
  [self checkInit];
  if (a == 0) {
    @throw [[[IllegalArgumentException alloc] init] autorelease];
  }
  return logTable[a];
}


/**
 * @return multiplicative inverse of a
 */
- (int) inverse:(int)a {
  [self checkInit];
  if (a == 0) {
    @throw [[[ArithmeticException alloc] init] autorelease];
  }
  return expTable[size - logTable[a] - 1];
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
  int logSum = logTable[a] + logTable[b];
  return expTable[(logSum % size) + logSum / size];
}

- (void) dealloc {
  [expTable release];
  [logTable release];
  [zero release];
  [one release];
  [super dealloc];
}

@end
