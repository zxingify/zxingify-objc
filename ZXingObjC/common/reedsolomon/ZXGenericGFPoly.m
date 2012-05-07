#import "ZXGenericGF.h"
#import "ZXGenericGFPoly.h"

@interface ZXGenericGFPoly ()

@property (nonatomic, retain) NSArray* coefficients;
@property (nonatomic, retain) ZXGenericGF * field;

@end


@implementation ZXGenericGFPoly

@synthesize coefficients;
@synthesize field;

- (id)initWithField:(ZXGenericGF *)aField coefficients:(NSArray *)aCoefficients {
  self = [super init];
  if (self) {
    if (aCoefficients == nil || [aCoefficients count] == 0) {
      [NSException raise:NSInvalidArgumentException format:@"Coefficients must be provided."];
    }
    self.field = aField;
    int coefficientsLength = [aCoefficients count];
    if (coefficientsLength > 1 && [[aCoefficients objectAtIndex:0] intValue] == 0) {
      int firstNonZero = 1;
      while (firstNonZero < coefficientsLength && [[aCoefficients objectAtIndex:firstNonZero] intValue] == 0) {
        firstNonZero++;
      }
      if (firstNonZero == coefficientsLength) {
        self.coefficients = [field zero].coefficients;
      } else {
        self.coefficients = [aCoefficients subarrayWithRange:NSMakeRange(firstNonZero, [aCoefficients count] - firstNonZero)];
      }
    } else {
      self.coefficients = aCoefficients;
    }
  }

  return self;
}

- (void) dealloc {
  [field release];
  [coefficients release];

  [super dealloc];
}


- (int)degree {
  return [self.coefficients count] - 1;
}

- (BOOL)zero {
  return [[self.coefficients objectAtIndex:0] intValue] == 0;
}

- (int)coefficient:(int)degree {
  return [[self.coefficients objectAtIndex:[self.coefficients count] - 1 - degree] intValue];
}

- (int)evaluateAt:(int)a {
  if (a == 0) {
    return [self coefficient:0];
  }
  int size = self.coefficients.count;
  if (a == 1) {
    int result = 0;
    for (int i = 0; i < size; i++) {
      result = [ZXGenericGF addOrSubtract:result b:[[self.coefficients objectAtIndex:i] intValue]];
    }
    return result;
  }
  int result = [[self.coefficients objectAtIndex:0] intValue];
  for (int i = 1; i < size; i++) {
    result = [ZXGenericGF addOrSubtract:[self.field multiply:a b:result] b:[[self.coefficients objectAtIndex:i] intValue]];
  }
  return result;
}

- (ZXGenericGFPoly *)addOrSubtract:(ZXGenericGFPoly *)other {
  if (![self.field isEqual:other->field]) {
    [NSException raise:NSInvalidArgumentException format:@"ZXGenericGFPolys do not have same GenericGF field"];
  }
  if (self.zero) {
    return other;
  }
  if (other.zero) {
    return self;
  }

  NSArray * smallerCoefficients = self.coefficients;
  NSArray * largerCoefficients = other.coefficients;
  if ([smallerCoefficients count] > [largerCoefficients count]) {
    NSArray * temp = smallerCoefficients;
    smallerCoefficients = largerCoefficients;
    largerCoefficients = temp;
  }
  int lengthDiff = [largerCoefficients count] - [smallerCoefficients count];
  NSMutableArray * sumDiff = [[[largerCoefficients subarrayWithRange:NSMakeRange(0, lengthDiff)] mutableCopy] autorelease];

  for (int i = lengthDiff; i < [largerCoefficients count]; i++) {
    [sumDiff addObject:[NSNumber numberWithInt:[ZXGenericGF addOrSubtract:[[smallerCoefficients objectAtIndex:i - lengthDiff] intValue]
                                                                      b:[[largerCoefficients objectAtIndex:i] intValue]]]];
  }

  return [[[ZXGenericGFPoly alloc] initWithField:self.field coefficients:sumDiff] autorelease];
}

- (ZXGenericGFPoly *) multiply:(ZXGenericGFPoly *)other {
  if (![self.field isEqual:other->field]) {
    [NSException raise:NSInvalidArgumentException format:@"ZXGenericGFPolys do not have same GenericGF field"];
  }
  if (self.zero || other.zero) {
    return self.field.zero;
  }
  NSArray * aCoefficients = self.coefficients;
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
                         withObject:[NSNumber numberWithInt:[ZXGenericGF addOrSubtract:[[product objectAtIndex:i + j] intValue]
                                                                                     b:[self.field multiply:aCoeff b:[[bCoefficients objectAtIndex:j] intValue]]]]];
    }
  }
  return [[[ZXGenericGFPoly alloc] initWithField:field coefficients:product] autorelease];
}

- (ZXGenericGFPoly *)multiplyScalar:(int)scalar {
  if (scalar == 0) {
    return self.field.zero;
  }
  if (scalar == 1) {
    return self;
  }
  int size = self.coefficients.count;
  NSMutableArray * product = [NSMutableArray arrayWithCapacity:size];
  for (int i = 0; i < size; i++) {
    [product addObject:[NSNumber numberWithInt:[self.field multiply:[[self.coefficients objectAtIndex:i] intValue] b:scalar]]];
  }
  return [[[ZXGenericGFPoly alloc] initWithField:self.field coefficients:product] autorelease];
}

- (ZXGenericGFPoly *)multiplyByMonomial:(int)degree coefficient:(int)coefficient {
  if (degree < 0) {
    [NSException raise:NSInvalidArgumentException format:@"Degree must be greater than 0."];
  }
  if (coefficient == 0) {
    return field.zero;
  }
  int size = self.coefficients.count;
  NSMutableArray * product = [NSMutableArray arrayWithCapacity:size + degree];
  for (int i = 0; i < size + degree; i++) {
    if (i < size) {
      [product addObject:[NSNumber numberWithInt:[self.field multiply:[[self.coefficients objectAtIndex:i] intValue] b:coefficient]]];
    } else {
      [product addObject:[NSNumber numberWithInt:0]];
    }
  }

  return [[[ZXGenericGFPoly alloc] initWithField:self.field coefficients:product] autorelease];
}

- (NSArray *)divide:(ZXGenericGFPoly *)other {
  if (![self.field isEqual:other->field]) {
    [NSException raise:NSInvalidArgumentException format:@"ZXGenericGFPolys do not have same GenericGF field"];
  }
  if (other.zero) {
    [NSException raise:NSInvalidArgumentException format:@"Divide by 0"];
  }

  ZXGenericGFPoly * quotient = self.field.zero;
  ZXGenericGFPoly * remainder = self;

  int denominatorLeadingTerm = [other coefficient:other.degree];
  int inverseDenominatorLeadingTerm = [self.field inverse:denominatorLeadingTerm];

  while ([remainder degree] >= other.degree && !remainder.zero) {
    int degreeDifference = remainder.degree - other.degree;
    int scale = [self.field multiply:[remainder coefficient:remainder.degree] b:inverseDenominatorLeadingTerm];
    ZXGenericGFPoly * term = [other multiplyByMonomial:degreeDifference coefficient:scale];
    ZXGenericGFPoly * iterationQuotient = [field buildMonomial:degreeDifference coefficient:scale];
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

  return [NSString stringWithString:result];
}

@end
