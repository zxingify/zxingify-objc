#import "GenericGF.h"
#import "GenericGFPoly.h"

@implementation GenericGFPoly


/**
 * @param field the {@link GenericGF} instance representing the field to use
 * to perform computations
 * @param coefficients coefficients as ints representing elements of GF(size), arranged
 * from most significant (highest-power term) coefficient to least significant
 * @throws IllegalArgumentException if argument is null or empty,
 * or if leading coefficient is 0 and this is not a
 * constant polynomial (that is, it is not the monomial "0")
 */
- (id) init:(GenericGF *)field coefficients:(NSArray *)coefficients {
  if (self = [super init]) {
    if (coefficients == nil || coefficients.length == 0) {
      @throw [[[IllegalArgumentException alloc] init] autorelease];
    }
    field = field;
    int coefficientsLength = coefficients.length;
    if (coefficientsLength > 1 && coefficients[0] == 0) {
      int firstNonZero = 1;

      while (firstNonZero < coefficientsLength && coefficients[firstNonZero] == 0) {
        firstNonZero++;
      }

      if (firstNonZero == coefficientsLength) {
        coefficients = [field zero].coefficients;
      }
       else {
        coefficients = [NSArray array];
        [System arraycopy:coefficients param1:firstNonZero param2:coefficients param3:0 param4:coefficients.length];
      }
    }
     else {
      coefficients = coefficients;
    }
  }
  return self;
}

- (NSArray *) getCoefficients {
  return coefficients;
}


/**
 * @return degree of this polynomial
 */
- (int) getDegree {
  return coefficients.length - 1;
}


/**
 * @return true iff this polynomial is the monomial "0"
 */
- (BOOL) isZero {
  return coefficients[0] == 0;
}


/**
 * @return coefficient of x^degree term in this polynomial
 */
- (int) getCoefficient:(int)degree {
  return coefficients[coefficients.length - 1 - degree];
}


/**
 * @return evaluation of this polynomial at a given point
 */
- (int) evaluateAt:(int)a {
  if (a == 0) {
    return [self getCoefficient:0];
  }
  int size = coefficients.length;
  if (a == 1) {
    int result = 0;

    for (int i = 0; i < size; i++) {
      result = [GenericGF addOrSubtract:result param1:coefficients[i]];
    }

    return result;
  }
  int result = coefficients[0];

  for (int i = 1; i < size; i++) {
    result = [GenericGF addOrSubtract:[field multiply:a param1:result] param1:coefficients[i]];
  }

  return result;
}

- (GenericGFPoly *) addOrSubtract:(GenericGFPoly *)other {
  if (![field isEqualTo:other.field]) {
    @throw [[[IllegalArgumentException alloc] init:@"GenericGFPolys do not have same GenericGF field"] autorelease];
  }
  if ([self zero]) {
    return other;
  }
  if ([other zero]) {
    return self;
  }
  NSArray * smallerCoefficients = coefficients;
  NSArray * largerCoefficients = other.coefficients;
  if (smallerCoefficients.length > largerCoefficients.length) {
    NSArray * temp = smallerCoefficients;
    smallerCoefficients = largerCoefficients;
    largerCoefficients = temp;
  }
  NSArray * sumDiff = [NSArray array];
  int lengthDiff = largerCoefficients.length - smallerCoefficients.length;
  [System arraycopy:largerCoefficients param1:0 param2:sumDiff param3:0 param4:lengthDiff];

  for (int i = lengthDiff; i < largerCoefficients.length; i++) {
    sumDiff[i] = [GenericGF addOrSubtract:smallerCoefficients[i - lengthDiff] param1:largerCoefficients[i]];
  }

  return [[[GenericGFPoly alloc] init:field param1:sumDiff] autorelease];
}

- (GenericGFPoly *) multiply:(GenericGFPoly *)other {
  if (![field isEqualTo:other.field]) {
    @throw [[[IllegalArgumentException alloc] init:@"GenericGFPolys do not have same GenericGF field"] autorelease];
  }
  if ([self zero] || [other zero]) {
    return [field zero];
  }
  NSArray * aCoefficients = coefficients;
  int aLength = aCoefficients.length;
  NSArray * bCoefficients = other.coefficients;
  int bLength = bCoefficients.length;
  NSArray * product = [NSArray array];

  for (int i = 0; i < aLength; i++) {
    int aCoeff = aCoefficients[i];

    for (int j = 0; j < bLength; j++) {
      product[i + j] = [GenericGF addOrSubtract:product[i + j] param1:[field multiply:aCoeff param1:bCoefficients[j]]];
    }

  }

  return [[[GenericGFPoly alloc] init:field param1:product] autorelease];
}

- (GenericGFPoly *) multiplyScalar:(int)scalar {
  if (scalar == 0) {
    return [field zero];
  }
  if (scalar == 1) {
    return self;
  }
  int size = coefficients.length;
  NSArray * product = [NSArray array];

  for (int i = 0; i < size; i++) {
    product[i] = [field multiply:coefficients[i] param1:scalar];
  }

  return [[[GenericGFPoly alloc] init:field param1:product] autorelease];
}

- (GenericGFPoly *) multiplyByMonomial:(int)degree coefficient:(int)coefficient {
  if (degree < 0) {
    @throw [[[IllegalArgumentException alloc] init] autorelease];
  }
  if (coefficient == 0) {
    return [field zero];
  }
  int size = coefficients.length;
  NSArray * product = [NSArray array];

  for (int i = 0; i < size; i++) {
    product[i] = [field multiply:coefficients[i] param1:coefficient];
  }

  return [[[GenericGFPoly alloc] init:field param1:product] autorelease];
}

- (NSArray *) divide:(GenericGFPoly *)other {
  if (![field isEqualTo:other.field]) {
    @throw [[[IllegalArgumentException alloc] init:@"GenericGFPolys do not have same GenericGF field"] autorelease];
  }
  if ([other zero]) {
    @throw [[[IllegalArgumentException alloc] init:@"Divide by 0"] autorelease];
  }
  GenericGFPoly * quotient = [field zero];
  GenericGFPoly * remainder = self;
  int denominatorLeadingTerm = [other getCoefficient:[other degree]];
  int inverseDenominatorLeadingTerm = [field inverse:denominatorLeadingTerm];

  while ([remainder degree] >= [other degree] && ![remainder zero]) {
    int degreeDifference = [remainder degree] - [other degree];
    int scale = [field multiply:[remainder getCoefficient:[remainder degree]] param1:inverseDenominatorLeadingTerm];
    GenericGFPoly * term = [other multiplyByMonomial:degreeDifference param1:scale];
    GenericGFPoly * iterationQuotient = [field buildMonomial:degreeDifference param1:scale];
    quotient = [quotient addOrSubtract:iterationQuotient];
    remainder = [remainder addOrSubtract:term];
  }

  return [NSArray arrayWithObjects:quotient, remainder, nil];
}

- (NSString *) description {
  StringBuffer * result = [[[StringBuffer alloc] init:8 * [self degree]] autorelease];

  for (int degree = [self degree]; degree >= 0; degree--) {
    int coefficient = [self getCoefficient:degree];
    if (coefficient != 0) {
      if (coefficient < 0) {
        [result append:@" - "];
        coefficient = -coefficient;
      }
       else {
        if ([result length] > 0) {
          [result append:@" + "];
        }
      }
      if (degree == 0 || coefficient != 1) {
        int alphaPower = [field log:coefficient];
        if (alphaPower == 0) {
          [result append:'1'];
        }
         else if (alphaPower == 1) {
          [result append:'a'];
        }
         else {
          [result append:@"a^"];
          [result append:alphaPower];
        }
      }
      if (degree != 0) {
        if (degree == 1) {
          [result append:'x'];
        }
         else {
          [result append:@"x^"];
          [result append:degree];
        }
      }
    }
  }

  return [result description];
}

- (void) dealloc {
  [field release];
  [coefficients release];
  [super dealloc];
}

@end
