#import "ZXGenericGF.h"
#import "ZXGenericGFPoly.h"
#import "ZXReedSolomonDecoder.h"
#import "ZXReedSolomonException.h"

@interface ZXReedSolomonDecoder ()

@property (nonatomic, retain) ZXGenericGF * field;

- (NSArray *)runEuclideanAlgorithm:(ZXGenericGFPoly *)a b:(ZXGenericGFPoly *)b R:(int)R;
- (NSArray *)findErrorLocations:(ZXGenericGFPoly *)errorLocator;
- (NSArray *)findErrorMagnitudes:(ZXGenericGFPoly *)errorEvaluator errorLocations:(NSArray *)errorLocations dataMatrix:(BOOL)dataMatrix;

@end


@implementation ZXReedSolomonDecoder

@synthesize field;

- (id)initWithField:(ZXGenericGF *)aField {
  if (self = [super init]) {
    self.field = aField;
  }

  return self;
}

- (void)dealloc {
  [field release];

  [super dealloc];
}


/**
 * Decodes given set of received codewords, which include both data and error-correction
 * codewords. Really, this means it uses Reed-Solomon to detect and correct errors, in-place,
 * in the input.
 */
- (void)decode:(NSMutableArray *)received twoS:(int)twoS {
  ZXGenericGFPoly * poly = [[[ZXGenericGFPoly alloc] initWithField:field coefficients:received] autorelease];
  NSMutableArray * syndromeCoefficients = [NSMutableArray arrayWithCapacity:twoS];
  for (int i = 0; i < twoS; i++) {
    [syndromeCoefficients addObject:[NSNull null]];
  }

  BOOL dataMatrix = [self.field isEqual:[ZXGenericGF DataMatrixField256]];
  BOOL noError = YES;

  for (int i = 0; i < twoS; i++) {
    int eval = [poly evaluateAt:[self.field exp:dataMatrix ? i + 1 : i]];
    [syndromeCoefficients replaceObjectAtIndex:[syndromeCoefficients count] - 1 - i withObject:[NSNumber numberWithInt:eval]];
    if (eval != 0) {
      noError = NO;
    }
  }

  if (noError) {
    return;
  }
  ZXGenericGFPoly * syndrome = [[[ZXGenericGFPoly alloc] initWithField:field coefficients:syndromeCoefficients] autorelease];
  NSArray * sigmaOmega = [self runEuclideanAlgorithm:[field buildMonomial:twoS coefficient:1] b:syndrome R:twoS];
  ZXGenericGFPoly * sigma = [sigmaOmega objectAtIndex:0];
  ZXGenericGFPoly * omega = [sigmaOmega objectAtIndex:1];
  NSArray * errorLocations = [self findErrorLocations:sigma];
  NSArray * errorMagnitudes = [self findErrorMagnitudes:omega errorLocations:errorLocations dataMatrix:dataMatrix];

  for (int i = 0; i < [errorLocations count]; i++) {
    int position = [received count] - 1 - [self.field log:[[errorLocations objectAtIndex:i] intValue]];
    if (position < 0) {
      @throw [[[ZXReedSolomonException alloc] initWithName:@"ZXReedSolomonException"
                                                    reason:@"Bad error location"
                                                  userInfo:nil] autorelease];
    }
    [received replaceObjectAtIndex:position
                        withObject:[NSNumber numberWithInt:[ZXGenericGF addOrSubtract:[[received objectAtIndex:position] intValue] b:[[errorMagnitudes objectAtIndex:i] intValue]]]];
  }
}

- (NSArray *)runEuclideanAlgorithm:(ZXGenericGFPoly *)a b:(ZXGenericGFPoly *)b R:(int)R {
  if (a.degree < b.degree) {
    ZXGenericGFPoly * temp = a;
    a = b;
    b = temp;
  }

  ZXGenericGFPoly * rLast = a;
  ZXGenericGFPoly * r = b;
  ZXGenericGFPoly * sLast = field.one;
  ZXGenericGFPoly * s = field.zero;
  ZXGenericGFPoly * tLast = field.zero;
  ZXGenericGFPoly * t = field.one;

  while ([r degree] >= R / 2) {
    ZXGenericGFPoly * rLastLast = rLast;
    ZXGenericGFPoly * sLastLast = sLast;
    ZXGenericGFPoly * tLastLast = tLast;
    rLast = r;
    sLast = s;
    tLast = t;

    if ([rLast zero]) {
      @throw [[[ZXReedSolomonException alloc] initWithName:@"ZXReedSolomonException"
                                                    reason:@"r_{i-1} was zero"
                                                  userInfo:nil] autorelease];
    }
    r = rLastLast;
    ZXGenericGFPoly * q = [field zero];
    int denominatorLeadingTerm = [rLast coefficient:[rLast degree]];
    int dltInverse = [field inverse:denominatorLeadingTerm];

    while ([r degree] >= [rLast degree] && ![r zero]) {
      int degreeDiff = [r degree] - [rLast degree];
      int scale = [field multiply:[r coefficient:[r degree]] b:dltInverse];
      q = [q addOrSubtract:[field buildMonomial:degreeDiff coefficient:scale]];
      r = [r addOrSubtract:[rLast multiplyByMonomial:degreeDiff coefficient:scale]];
    }

    s = [[q multiply:sLast] addOrSubtract:sLastLast];
    t = [[q multiply:tLast] addOrSubtract:tLastLast];
  }

  int sigmaTildeAtZero = [t coefficient:0];
  if (sigmaTildeAtZero == 0) {
    @throw [[[ZXReedSolomonException alloc] initWithName:@"ZXReedSolomonException"
                                                  reason:@"sigmaTilde(0) was zero"
                                                userInfo:nil] autorelease];
  }

  int inverse = [field inverse:sigmaTildeAtZero];
  ZXGenericGFPoly * sigma = [t multiplyScalar:inverse];
  ZXGenericGFPoly * omega = [r multiplyScalar:inverse];
  return [NSArray arrayWithObjects:sigma, omega, nil];
}

- (NSArray *)findErrorLocations:(ZXGenericGFPoly *)errorLocator {
  int numErrors = [errorLocator degree];
  if (numErrors == 1) {
    return [NSArray arrayWithObject:[NSNumber numberWithInt:[errorLocator coefficient:1]]];
  }
  NSMutableArray * result = [NSMutableArray arrayWithCapacity:numErrors];
  int e = 0;
  for (int i = 1; i < [field size] && e < numErrors; i++) {
    if ([errorLocator evaluateAt:i] == 0) {
      [result addObject:[NSNumber numberWithInt:[field inverse:i]]];
      e++;
    }
  }

  if (e != numErrors) {
    @throw [[[ZXReedSolomonException alloc] initWithName:@"ZXReedSolomonException"
                                                  reason:@"Error locator degree does not match number of roots"
                                                userInfo:nil] autorelease];
  }
  return result;
}

- (NSArray *)findErrorMagnitudes:(ZXGenericGFPoly *)errorEvaluator errorLocations:(NSArray *)errorLocations dataMatrix:(BOOL)dataMatrix {
  int s = [errorLocations count];
  NSMutableArray * result = [NSMutableArray array];
  for (int i = 0; i < s; i++) {
    int xiInverse = [self.field inverse:[[errorLocations objectAtIndex:i] intValue]];
    int denominator = 1;
    for (int j = 0; j < s; j++) {
      if (i != j) {
        int term = [self.field multiply:[[errorLocations objectAtIndex:j] intValue] b:xiInverse];
        int termPlus1 = (term & 0x1) == 0 ? term | 1 : term & ~1;
        denominator = [self.field multiply:denominator b:termPlus1];
      }
    }

    [result addObject:[NSNumber numberWithInt:[self.field multiply:[errorEvaluator evaluateAt:xiInverse] b:[self.field inverse:denominator]]]];
    if (dataMatrix) {
      [result replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:[self.field multiply:[[result objectAtIndex:i] intValue] b:xiInverse]]];
    }
  }

  return result;
}

@end
