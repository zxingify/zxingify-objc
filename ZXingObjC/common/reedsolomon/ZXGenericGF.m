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

@property (nonatomic, retain) ZXGenericGFPoly * zero;
@property (nonatomic, retain) ZXGenericGFPoly * one;
@property (nonatomic, assign) int size;
@property (nonatomic, retain) NSMutableArray * expTable;
@property (nonatomic, retain) NSMutableArray * logTable;
@property (nonatomic, assign) int primitive;

@end


@implementation ZXGenericGF

@synthesize zero;
@synthesize one;
@synthesize size;
@synthesize expTable;
@synthesize logTable;
@synthesize primitive;


/**
 * Create a representation of GF(size) using the given primitive polynomial.
 */
- (id)initWithPrimitive:(int)aPrimitive size:(int)aSize {
  if (self = [super init]) {
    self.primitive = aPrimitive;
    self.size = aSize;
    self.expTable = [NSMutableArray arrayWithCapacity:size];
    self.logTable = [NSMutableArray arrayWithCapacity:size];
    int x = 1;
    for (int i = 0; i < size; i++) {
      [self.expTable addObject:[NSNumber numberWithInt:x]];
      x <<= 1;
      if (x >= self.size) {
        x ^= self.primitive;
        x &= self.size - 1;
      }
    }

    for (int i = 0; i < self.size; i++) {
      [self.logTable addObject:[NSNumber numberWithInt:0]];
    }

    for (int i = 0; i < self.size - 1; i++) {
      [self.logTable replaceObjectAtIndex:[[self.expTable objectAtIndex:i] intValue] withObject:[NSNumber numberWithInt:i]];
    }

    self.zero = [[[ZXGenericGFPoly alloc] initWithField:self coefficients:NULL coefficientsLen:0] autorelease];

    int oneInt = 1;
    self.one = [[[ZXGenericGFPoly alloc] initWithField:self coefficients:&oneInt coefficientsLen:1] autorelease];
  }

  return self;
}

- (void)dealloc {
  [expTable release];
  [logTable release];
  [zero release];
  [one release];
  
  [super dealloc];
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

+ (ZXGenericGF *)MaxiCodeField64 {
  return [self AztecData6];
}

- (ZXGenericGFPoly *) buildMonomial:(int)degree coefficient:(int)coefficient {
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
  return [[self.expTable objectAtIndex:a] intValue];
}

- (int)log:(int)a {
  if (a == 0) {
    [NSException raise:NSInvalidArgumentException format:@"Argument must be non-zero."];
  }
  return [[self.logTable objectAtIndex:a] intValue];
}

- (int)inverse:(int)a {
  if (a == 0) {
    [NSException raise:NSInvalidArgumentException format:@"Argument must be non-zero."];
  }
  return [[self.expTable objectAtIndex:self.size - [[self.logTable objectAtIndex:a] intValue] - 1] intValue];
}

- (int)multiply:(int)a b:(int)b {
  if (a == 0 || b == 0) {
    return 0;
  }

  int logSum = [[self.logTable objectAtIndex:a] intValue] + [[self.logTable objectAtIndex:b] intValue];
  return [[self.expTable objectAtIndex:logSum % (size - 1)] intValue];
}

- (BOOL)isEqual:(ZXGenericGF*)object {
  return self.primitive == object->primitive && self.size == object->size;
}

@end
