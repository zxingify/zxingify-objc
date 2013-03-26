/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXErrors.h"
#import "ZXGenericGF.h"
#import "ZXGenericGFPoly.h"
#import "ZXReedSolomonDecoder.h"

@interface ZXReedSolomonDecoder ()

@property (nonatomic, retain) ZXGenericGF *field;

- (NSArray *)runEuclideanAlgorithm:(ZXGenericGFPoly *)a b:(ZXGenericGFPoly *)b R:(int)R error:(NSError **)error;
- (NSArray *)findErrorLocations:(ZXGenericGFPoly *)errorLocator error:(NSError **)error;
- (NSArray *)findErrorMagnitudes:(ZXGenericGFPoly *)errorEvaluator errorLocations:(NSArray *)errorLocations;

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
- (BOOL)decode:(int *)received receivedLen:(int)receivedLen twoS:(int)twoS error:(NSError **)error {
  ZXGenericGFPoly *poly = [[[ZXGenericGFPoly alloc] initWithField:field coefficients:received coefficientsLen:receivedLen] autorelease];
  int syndromeCoefficientsLen = twoS;
  int syndromeCoefficients[syndromeCoefficientsLen];
  BOOL noError = YES;

  for (int i = 0; i < twoS; i++) {
    int eval = [poly evaluateAt:[field exp:i + field.generatorBase]];
    syndromeCoefficients[syndromeCoefficientsLen - 1 - i] = eval;
    if (eval != 0) {
      noError = NO;
    }
  }
  if (noError) {
    return YES;
  }
  ZXGenericGFPoly *syndrome = [[[ZXGenericGFPoly alloc] initWithField:field coefficients:syndromeCoefficients coefficientsLen:syndromeCoefficientsLen] autorelease];
  NSArray *sigmaOmega = [self runEuclideanAlgorithm:[field buildMonomial:twoS coefficient:1] b:syndrome R:twoS error:error];
  if (!sigmaOmega) {
    return NO;
  }
  ZXGenericGFPoly *sigma = [sigmaOmega objectAtIndex:0];
  ZXGenericGFPoly *omega = [sigmaOmega objectAtIndex:1];
  NSArray *errorLocations = [self findErrorLocations:sigma error:error];
  if (!errorLocations) {
    return NO;
  }
  NSArray *errorMagnitudes = [self findErrorMagnitudes:omega errorLocations:errorLocations];
  for (int i = 0; i < [errorLocations count]; i++) {
    int position = receivedLen - 1 - [field log:[[errorLocations objectAtIndex:i] intValue]];
    if (position < 0) {
      NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Bad error location"
                                                           forKey:NSLocalizedDescriptionKey];
      
      if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXReedSolomonError userInfo:userInfo] autorelease];
      return NO;
    }
    received[position] = [ZXGenericGF addOrSubtract:received[position] b:[[errorMagnitudes objectAtIndex:i] intValue]];
  }
  return YES;
}

- (NSArray *)runEuclideanAlgorithm:(ZXGenericGFPoly *)a b:(ZXGenericGFPoly *)b R:(int)R error:(NSError **)error {
  if (a.degree < b.degree) {
    ZXGenericGFPoly *temp = a;
    a = b;
    b = temp;
  }

  ZXGenericGFPoly *rLast = a;
  ZXGenericGFPoly *r = b;
  ZXGenericGFPoly *tLast = field.zero;
  ZXGenericGFPoly *t = field.one;

  while ([r degree] >= R / 2) {
    ZXGenericGFPoly *rLastLast = rLast;
    ZXGenericGFPoly *tLastLast = tLast;
    rLast = r;
    tLast = t;

    if ([rLast zero]) {
      NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"r_{i-1} was zero"
                                                           forKey:NSLocalizedDescriptionKey];

      if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXReedSolomonError userInfo:userInfo] autorelease];
      return NO;
    }
    r = rLastLast;
    ZXGenericGFPoly *q = [field zero];
    int denominatorLeadingTerm = [rLast coefficient:[rLast degree]];
    int dltInverse = [field inverse:denominatorLeadingTerm];

    while ([r degree] >= [rLast degree] && ![r zero]) {
      int degreeDiff = [r degree] - [rLast degree];
      int scale = [field multiply:[r coefficient:[r degree]] b:dltInverse];
      q = [q addOrSubtract:[field buildMonomial:degreeDiff coefficient:scale]];
      r = [r addOrSubtract:[rLast multiplyByMonomial:degreeDiff coefficient:scale]];
    }

    t = [[q multiply:tLast] addOrSubtract:tLastLast];
  }

  int sigmaTildeAtZero = [t coefficient:0];
  if (sigmaTildeAtZero == 0) {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"sigmaTilde(0) was zero"
                                                         forKey:NSLocalizedDescriptionKey];

    if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXReedSolomonError userInfo:userInfo] autorelease];
    return NO;
  }

  int inverse = [field inverse:sigmaTildeAtZero];
  ZXGenericGFPoly *sigma = [t multiplyScalar:inverse];
  ZXGenericGFPoly *omega = [r multiplyScalar:inverse];
  return [NSArray arrayWithObjects:sigma, omega, nil];
}

- (NSArray *)findErrorLocations:(ZXGenericGFPoly *)errorLocator error:(NSError **)error {
  int numErrors = [errorLocator degree];
  if (numErrors == 1) {
    return [NSArray arrayWithObject:[NSNumber numberWithInt:[errorLocator coefficient:1]]];
  }
  NSMutableArray *result = [NSMutableArray arrayWithCapacity:numErrors];
  int e = 0;
  for (int i = 1; i < [field size] && e < numErrors; i++) {
    if ([errorLocator evaluateAt:i] == 0) {
      [result addObject:[NSNumber numberWithInt:[field inverse:i]]];
      e++;
    }
  }

  if (e != numErrors) {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error locator degree does not match number of roots"
                                                         forKey:NSLocalizedDescriptionKey];
    
    if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXReedSolomonError userInfo:userInfo] autorelease];
    return nil;
  }
  return result;
}

- (NSArray *)findErrorMagnitudes:(ZXGenericGFPoly *)errorEvaluator errorLocations:(NSArray *)errorLocations {
  int s = [errorLocations count];
  NSMutableArray *result = [NSMutableArray array];
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
    if (self.field.generatorBase != 0) {
      [result replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:[self.field multiply:[[result objectAtIndex:i] intValue] b:xiInverse]]];
    }
  }

  return result;
}

@end
