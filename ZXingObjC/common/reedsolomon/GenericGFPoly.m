#import "GenericGF.h"
#import "GenericGFPoly.h"

@implementation GenericGFPoly

@synthesize coefficients;

/**
 * @param field the {@link GenericGF} instance representing the field to use
 * to perform computations
 * @param coefficients coefficients as ints representing elements of GF(size), arranged
 * from most significant (highest-power term) coefficient to least significant
 * @throws IllegalArgumentException if argument is null or empty,
 * or if leading coefficient is 0 and this is not a
 * constant polynomial (that is, it is not the monomial "0")
 */
- (id) initWithField:(GenericGF *)aField coefficients:(NSArray *)aCoefficients {
  if (self = [super init]) {
    if (aCoefficients == nil || [aCoefficients count] == 0) {
      [NSException raise:NSInvalidArgumentException format:@"Coefficients must be provided."];
    }
    field = [aField retain];
    int coefficientsLength = [aCoefficients count];
    if (coefficientsLength > 1 && [[aCoefficients objectAtIndex:0] intValue] == 0) {
      int firstNonZero = 1;

      while (firstNonZero < coefficientsLength && [[aCoefficients objectAtIndex:firstNonZero] intValue] == 0) {
        firstNonZero++;
      }

      if (firstNonZero == coefficientsLength) {
        coefficients = [field zero].coefficients;
      } else {
        coefficients = [[aCoefficients subarrayWithRange:NSMakeRange(firstNonZero, [aCoefficients count] - firstNonZero)] retain];
      }
    } else {
      coefficients = [aCoefficients retain];
    }
  }
  return self;
}

/**
 * @return degree of this polynomial
 */
- (int) degree {
  return [coefficients count] - 1;
}

/**
 * @return true iff this polynomial is the monomial "0"
 */
- (BOOL) zero {
  return [[coefficients objectAtIndex:0] intValue] == 0;
}

/**
 * @return coefficient of x^degree term in this polynomial
 */
- (int) coefficient:(int)degree {
  return [[coefficients objectAtIndex:[coefficients count] - 1 - degree] intValue];
}

/**
 * @return evaluation of this polynomial at a given point
 */
- (int) evaluateAt:(int)a {
  if (a == 0) {
    return [self coefficient:0];
  }
  int size = [coefficients count];
  if (a == 1) {
    int result = 0;
    for (int i = 0; i < size; i++) {
      result = [GenericGF addOrSubtract:result b:[[coefficients objectAtIndex:i] intValue]];
    }
    return result;
  }
  int result = [[coefficients objectAtIndex:0] intValue];
  for (int i = 1; i < size; i++) {
    result = [GenericGF addOrSubtract:[field multiply:a b:result] b:[[coefficients objectAtIndex:i] intValue]];
  }
  return result;
}

- (GenericGFPoly *) addOrSubtract:(GenericGFPoly *)other {
  if (![field isEqual:other->field]) {
    [NSException raise:NSInvalidArgumentException format:@"GenericGFPolys do not have same GenericGF field"];
  }
  if ([self zero]) {
    return other;
  }
  if ([other zero]) {
    return self;
  }

  NSArray * smallerCoefficients = coefficients;
  NSArray * largerCoefficients = other.coefficients;
  if ([smallerCoefficients count] > [largerCoefficients count]) {
    NSArray * temp = smallerCoefficients;
    smallerCoefficients = largerCoefficients;
    largerCoefficients = temp;
  }
  int lengthDiff = [largerCoefficients count] - [smallerCoefficients count];
  NSMutableArray * sumDiff = [[[largerCoefficients subarrayWithRange:NSMakeRange(0, lengthDiff)] mutableCopy] autorelease];

  for (int i = lengthDiff; i < [largerCoefficients count]; i++) {
    [sumDiff addObject:[NSNumber numberWithInt:[GenericGF addOrSubtract:[[smallerCoefficients objectAtIndex:i - lengthDiff] intValue]
                                                                      b:[[largerCoefficients objectAtIndex:i] intValue]]]];
  }

  return [[[GenericGFPoly alloc] initWithField:field coefficients:sumDiff] autorelease];
}

- (GenericGFPoly *) multiply:(GenericGFPoly *)other {
  if (![field isEqual:other->field]) {
    [NSException raise:NSInvalidArgumentException format:@"GenericGFPolys do not have same GenericGF field"];
  }
  if ([self zero] || [other zero]) {
    return [field zero];
  }
  NSArray * aCoefficients = coefficients;
  int aLength = [aCoefficients count];
  NSArray * bCoefficients = other.coefficients;
  int bLength = [bCoefficients count];
  NSMutableArray * product = [NSMutableArray arrayWithCapacity:aLength + bLength - 1];
  for (int i = 0; i < aLength + bLength - 1; i++) {
    [product addObject:[NSNumber numberWithInt:0]];
  }
  
  for (int i = 0; i < aLength; i++) {
    int aCoeff = [[aCoefficients objectAtIndex:i] intValue];
    for (int j = 0; j < bLength; j++) {
      [product replaceObjectAtIndex:i + j
                         withObject:[NSNumber numberWithInt:[GenericGF addOrSubtract:[[product objectAtIndex:i + j] intValue]
                                                                                   b:[field multiply:aCoeff b:[[bCoefficients objectAtIndex:j] intValue]]]]];
    }
  }
  return [[[GenericGFPoly alloc] initWithField:field coefficients:product] autorelease];
}

- (GenericGFPoly *) multiplyScalar:(int)scalar {
  if (scalar == 0) {
    return [field zero];
  }
  if (scalar == 1) {
    return self;
  }
  int size = [coefficients count];
  NSMutableArray * product = [NSMutableArray arrayWithCapacity:size];
  for (int i = 0; i < size; i++) {
    [product addObject:[NSNumber numberWithInt:[field multiply:[[coefficients objectAtIndex:i] intValue] b:scalar]]];
  }
  return [[[GenericGFPoly alloc] initWithField:field coefficients:product] autorelease];
}

- (GenericGFPoly *) multiplyByMonomial:(int)degree coefficient:(int)coefficient {
  if (degree < 0) {
    [NSException raise:NSInvalidArgumentException format:@"Degree must be greater than 0."];
  }
  if (coefficient == 0) {
    return [field zero];
  }
  int size = [coefficients count];
  NSMutableArray * product = [NSMutableArray arrayWithCapacity:size + degree];
  for (int i = 0; i < size + degree; i++) {
    if (i < size) {
      [product addObject:[NSNumber numberWithInt:[field multiply:[[coefficients objectAtIndex:i] intValue] b:coefficient]]];
    } else {
      [product addObject:[NSNumber numberWithInt:0]];
    }
  }

  return [[[GenericGFPoly alloc] initWithField:field coefficients:product] autorelease];
}

- (NSArray *) divide:(GenericGFPoly *)other {
  if (![field isEqual:other->field]) {
    [NSException raise:NSInvalidArgumentException format:@"GenericGFPolys do not have same GenericGF field"];
  }
  if ([other zero]) {
    [NSException raise:NSInvalidArgumentException format:@"Divide by 0"];
  }

  GenericGFPoly * quotient = [field zero];
  GenericGFPoly * remainder = self;

  int denominatorLeadingTerm = [other coefficient:[other degree]];
  int inverseDenominatorLeadingTerm = [field inverse:denominatorLeadingTerm];

  while ([remainder degree] >= [other degree] && ![remainder zero]) {
    int degreeDifference = [remainder degree] - [other degree];
    int scale = [field multiply:[remainder coefficient:[remainder degree]] b:inverseDenominatorLeadingTerm];
    GenericGFPoly * term = [other multiplyByMonomial:degreeDifference coefficient:scale];
    GenericGFPoly * iterationQuotient = [field buildMonomial:degreeDifference coefficient:scale];
    quotient = [quotient addOrSubtract:iterationQuotient];
    remainder = [remainder addOrSubtract:term];
  }

  return [NSArray arrayWithObjects:quotient, remainder, nil];
}

- (NSString *) description {
  NSMutableString * result = [NSMutableString stringWithCapacity:8 * [self degree]];
  for (int degree = [self degree]; degree >= 0; degree--) {
    int coefficient = [self coefficient:degree];
    if (coefficient != 0) {
      if (coefficient < 0) {
        [result appendString:@" - "];
        coefficient = -coefficient;
      } else {
        if ([result length] > 0) {
          [result appendString:@" + "];
        }
      }
      if (degree == 0 || coefficient != 1) {
        int alphaPower = [field log:coefficient];
        if (alphaPower == 0) {
          [result appendString:@"1"];
        } else if (alphaPower == 1) {
          [result appendString:@"a"];
        } else {
          [result appendString:@"a^"];
          [result appendFormat:@"%d", alphaPower];
        }
      }
      if (degree != 0) {
        if (degree == 1) {
          [result appendString:@"x"];
        } else {
          [result appendString:@"x^"];
          [result appendFormat:@"%d", degree];
        }
      }
    }
  }

  return result;
}

- (void) dealloc {
  [field release];
  [coefficients release];
  [super dealloc];
}

@end
