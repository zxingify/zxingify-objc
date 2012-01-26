#import "ReedSolomonDecoder.h"

@implementation ReedSolomonDecoder

- (id) initWithField:(GenericGF *)field {
  if (self = [super init]) {
    field = field;
  }
  return self;
}


/**
 * <p>Decodes given set of received codewords, which include both data and error-correction
 * codewords. Really, this means it uses Reed-Solomon to detect and correct errors, in-place,
 * in the input.</p>
 * 
 * @param received data and error-correction codewords
 * @param twoS number of error-correction codewords available
 * @throws ReedSolomonException if decoding fails for any reason
 */
- (void) decode:(NSArray *)received twoS:(int)twoS {
  GenericGFPoly * poly = [[[GenericGFPoly alloc] init:field param1:received] autorelease];
  NSArray * syndromeCoefficients = [NSArray array];
  BOOL dataMatrix = [field isEqualTo:GenericGF.DATA_MATRIX_FIELD_256];
  BOOL noError = YES;

  for (int i = 0; i < twoS; i++) {
    int eval = [poly evaluateAt:[field exp:dataMatrix ? i + 1 : i]];
    syndromeCoefficients[syndromeCoefficients.length - 1 - i] = eval;
    if (eval != 0) {
      noError = NO;
    }
  }

  if (noError) {
    return;
  }
  GenericGFPoly * syndrome = [[[GenericGFPoly alloc] init:field param1:syndromeCoefficients] autorelease];
  NSArray * sigmaOmega = [self runEuclideanAlgorithm:[field buildMonomial:twoS param1:1] b:syndrome R:twoS];
  GenericGFPoly * sigma = sigmaOmega[0];
  GenericGFPoly * omega = sigmaOmega[1];
  NSArray * errorLocations = [self findErrorLocations:sigma];
  NSArray * errorMagnitudes = [self findErrorMagnitudes:omega errorLocations:errorLocations dataMatrix:dataMatrix];

  for (int i = 0; i < errorLocations.length; i++) {
    int position = received.length - 1 - [field log:errorLocations[i]];
    if (position < 0) {
      @throw [[[ReedSolomonException alloc] init:@"Bad error location"] autorelease];
    }
    received[position] = [GenericGF addOrSubtract:received[position] param1:errorMagnitudes[i]];
  }

}

- (NSArray *) runEuclideanAlgorithm:(GenericGFPoly *)a b:(GenericGFPoly *)b R:(int)R {
  if ([a degree] < [b degree]) {
    GenericGFPoly * temp = a;
    a = b;
    b = temp;
  }
  GenericGFPoly * rLast = a;
  GenericGFPoly * r = b;
  GenericGFPoly * sLast = [field one];
  GenericGFPoly * s = [field zero];
  GenericGFPoly * tLast = [field zero];
  GenericGFPoly * t = [field one];

  while ([r degree] >= R / 2) {
    GenericGFPoly * rLastLast = rLast;
    GenericGFPoly * sLastLast = sLast;
    GenericGFPoly * tLastLast = tLast;
    rLast = r;
    sLast = s;
    tLast = t;
    if ([rLast zero]) {
      @throw [[[ReedSolomonException alloc] init:@"r_{i-1} was zero"] autorelease];
    }
    r = rLastLast;
    GenericGFPoly * q = [field zero];
    int denominatorLeadingTerm = [rLast getCoefficient:[rLast degree]];
    int dltInverse = [field inverse:denominatorLeadingTerm];

    while ([r degree] >= [rLast degree] && ![r zero]) {
      int degreeDiff = [r degree] - [rLast degree];
      int scale = [field multiply:[r getCoefficient:[r degree]] param1:dltInverse];
      q = [q addOrSubtract:[field buildMonomial:degreeDiff param1:scale]];
      r = [r addOrSubtract:[rLast multiplyByMonomial:degreeDiff param1:scale]];
    }

    s = [[q multiply:sLast] addOrSubtract:sLastLast];
    t = [[q multiply:tLast] addOrSubtract:tLastLast];
  }

  int sigmaTildeAtZero = [t getCoefficient:0];
  if (sigmaTildeAtZero == 0) {
    @throw [[[ReedSolomonException alloc] init:@"sigmaTilde(0) was zero"] autorelease];
  }
  int inverse = [field inverse:sigmaTildeAtZero];
  GenericGFPoly * sigma = [t multiply:inverse];
  GenericGFPoly * omega = [r multiply:inverse];
  return [NSArray arrayWithObjects:sigma, omega, nil];
}

- (NSArray *) findErrorLocations:(GenericGFPoly *)errorLocator {
  int numErrors = [errorLocator degree];
  if (numErrors == 1) {
    return [NSArray arrayWithObjects:[errorLocator getCoefficient:1], nil];
  }
  NSArray * result = [NSArray array];
  int e = 0;

  for (int i = 1; i < [field size] && e < numErrors; i++) {
    if ([errorLocator evaluateAt:i] == 0) {
      result[e] = [field inverse:i];
      e++;
    }
  }

  if (e != numErrors) {
    @throw [[[ReedSolomonException alloc] init:@"Error locator degree does not match number of roots"] autorelease];
  }
  return result;
}

- (NSArray *) findErrorMagnitudes:(GenericGFPoly *)errorEvaluator errorLocations:(NSArray *)errorLocations dataMatrix:(BOOL)dataMatrix {
  int s = errorLocations.length;
  NSArray * result = [NSArray array];

  for (int i = 0; i < s; i++) {
    int xiInverse = [field inverse:errorLocations[i]];
    int denominator = 1;

    for (int j = 0; j < s; j++) {
      if (i != j) {
        int term = [field multiply:errorLocations[j] param1:xiInverse];
        int termPlus1 = (term & 0x1) == 0 ? term | 1 : term & ~1;
        denominator = [field multiply:denominator param1:termPlus1];
      }
    }

    result[i] = [field multiply:[errorEvaluator evaluateAt:xiInverse] param1:[field inverse:denominator]];
    if (dataMatrix) {
      result[i] = [field multiply:result[i] param1:xiInverse];
    }
  }

  return result;
}

- (void) dealloc {
  [field release];
  [super dealloc];
}

@end
