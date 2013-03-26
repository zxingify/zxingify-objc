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

#import "ZXGenericGF.h"
#import "ZXGenericGFPoly.h"

@interface ZXGenericGF ()

@property (nonatomic, retain) ZXGenericGFPoly *zero;
@property (nonatomic, retain) ZXGenericGFPoly *one;
@property (nonatomic, assign) int size;
@property (nonatomic, assign) int *expTable;
@property (nonatomic, assign) int *logTable;
@property (nonatomic, assign) int primitive;
@property (nonatomic, assign) int generatorBase;

@end

@implementation ZXGenericGF

@synthesize zero;
@synthesize one;
@synthesize size;
@synthesize expTable;
@synthesize logTable;
@synthesize primitive;
@synthesize generatorBase;

/**
 * Create a representation of GF(size) using the given primitive polynomial.
 */
- (id)initWithPrimitive:(int)aPrimitive size:(int)aSize b:(int)b {
  if (self = [super init]) {
    self.primitive = aPrimitive;
    self.size = aSize;
    self.generatorBase = b;
    self.expTable = (int *)malloc(size * sizeof(int));
    self.logTable = (int *)malloc(size * sizeof(int));
    int x = 1;
    for (int i = 0; i < size; i++) {
      expTable[i] = x;
      x <<= 1; // x = x * 2; we're assuming the generator alpha is 2
      if (x >= size) {
        x ^= primitive;
        x &= size - 1;
      }
    }

    for (int i = 0; i < self.size-1; i++) {
      logTable[expTable[i]] = i;
    }
    // logTable[0] == 0 but this should never be used
    self.zero = [[[ZXGenericGFPoly alloc] initWithField:self coefficients:NULL coefficientsLen:0] autorelease];
    int oneInt = 1;
    self.one = [[[ZXGenericGFPoly alloc] initWithField:self coefficients:&oneInt coefficientsLen:1] autorelease];
  }

  return self;
}

- (void)dealloc {
  free(expTable);
  free(logTable);
  [zero release];
  [one release];
  
  [super dealloc];
}

+ (ZXGenericGF *)AztecData12 {
  static ZXGenericGF *AztecData12 = nil;
  if (!AztecData12) {
    AztecData12 = [[ZXGenericGF alloc] initWithPrimitive:0x1069 size:4096 b:1]; // x^12 + x^6 + x^5 + x^3 + 1
  }
  return AztecData12;
}

+ (ZXGenericGF *)AztecData10 {
  static ZXGenericGF *AztecData10 = nil;
  if (!AztecData10) {
    AztecData10 = [[ZXGenericGF alloc] initWithPrimitive:0x409 size:1024 b:1]; // x^10 + x^3 + 1
  }
  return AztecData10;
}

+ (ZXGenericGF *)AztecData6 {
  static ZXGenericGF *AztecData6 = nil;
  if (!AztecData6) {
    AztecData6 = [[ZXGenericGF alloc] initWithPrimitive:0x43 size:64 b:1]; // x^6 + x + 1
  }
  return AztecData6;
}

+ (ZXGenericGF *)AztecParam {
  static ZXGenericGF *AztecParam = nil;
  if (!AztecParam) {
    AztecParam = [[ZXGenericGF alloc] initWithPrimitive:0x13 size:16 b:1]; // x^4 + x + 1
  }
  return AztecParam;
}

+ (ZXGenericGF *)QrCodeField256 {
  static ZXGenericGF *QrCodeField256 = nil;
  if (!QrCodeField256) {
    QrCodeField256 = [[ZXGenericGF alloc] initWithPrimitive:0x011D size:256 b:0]; // x^8 + x^4 + x^3 + x^2 + 1
  }
  return QrCodeField256;
}

+ (ZXGenericGF *)DataMatrixField256 {
  static ZXGenericGF *DataMatrixField256 = nil;
  if (!DataMatrixField256) {
    DataMatrixField256 = [[ZXGenericGF alloc] initWithPrimitive:0x012D size:256 b:1]; // x^8 + x^5 + x^3 + x^2 + 1
  }
  return DataMatrixField256;
}

+ (ZXGenericGF *)AztecData8 {
  return [self DataMatrixField256];
}

+ (ZXGenericGF *)MaxiCodeField64 {
  return [self AztecData6];
}

- (ZXGenericGFPoly *)buildMonomial:(int)degree coefficient:(int)coefficient {
  if (degree < 0) {
    [NSException raise:NSInvalidArgumentException format:@"Degree must be greater than 0."];
  }
  if (coefficient == 0) {
    return zero;
  }

  int coefficientsLen = degree + 1;
  int coefficients[coefficientsLen];
  coefficients[0] = coefficient;
  for (int i = 1; i < coefficientsLen; i++) {
    coefficients[i] = 0;
  }
  return [[[ZXGenericGFPoly alloc] initWithField:self coefficients:coefficients coefficientsLen:coefficientsLen] autorelease];
}

/**
 * Implements both addition and subtraction -- they are the same in GF(size).
 */
+ (int)addOrSubtract:(int)a b:(int)b {
  return a ^ b;
}

- (int)exp:(int)a {
  return expTable[a];
}

- (int)log:(int)a {
  if (a == 0) {
    [NSException raise:NSInvalidArgumentException format:@"Argument must be non-zero."];
  }
  return logTable[a];
}

- (int)inverse:(int)a {
  if (a == 0) {
    [NSException raise:NSInvalidArgumentException format:@"Argument must be non-zero."];
  }
  return self.expTable[self.size - self.logTable[a] - 1];
}

- (int)multiply:(int)a b:(int)b {
  if (a == 0 || b == 0) {
    return 0;
  }

  return expTable[(logTable[a] + logTable[b]) % (size - 1)];
}

- (BOOL)isEqual:(ZXGenericGF *)object {
  return self.primitive == object->primitive && self.size == object->size;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"GF(0x%X,%d)", self.primitive, self.size];
}

@end
