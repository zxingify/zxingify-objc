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

#import "ZXModulusGF.h"
#import "ZXModulusPoly.h"

@interface ZXModulusGF ()

@property (nonatomic, retain) NSMutableArray *expTable;
@property (nonatomic, retain) NSMutableArray *logTable;
@property (nonatomic, assign) int modulus;

@end

@implementation ZXModulusGF

@synthesize expTable;
@synthesize logTable;
@synthesize modulus;
@synthesize one;
@synthesize zero;

+ (ZXModulusGF *)PDF417_GF {
  return [[[ZXModulusGF alloc] initWithModulus:929 generator:3] autorelease];
}

- (id)initWithModulus:(int)aModulus generator:(int)generator {
  if (self = [super init]) {
    self.modulus = aModulus;
    self.expTable = [NSMutableArray arrayWithCapacity:self.modulus];
    self.logTable = [NSMutableArray arrayWithCapacity:self.modulus];
    int x = 1;
    for (int i = 0; i < self.modulus; i++) {
      [self.expTable addObject:[NSNumber numberWithInt:x]];
      x = (x * generator) % self.modulus;
    }

    for (int i = 0; i < self.size; i++) {
      [self.logTable addObject:[NSNumber numberWithInt:0]];
    }

    for (int i = 0; i < self.size - 1; i++) {
      [self.logTable replaceObjectAtIndex:[[self.expTable objectAtIndex:i] intValue] withObject:[NSNumber numberWithInt:i]];
    }
    // logTable[0] == 0 but this should never be used
    int zeroInt = 0;
    self.zero = [[[ZXModulusPoly alloc] initWithField:self coefficients:&zeroInt coefficientsLen:1] autorelease];

    int oneInt = 1;
    self.one = [[[ZXModulusPoly alloc] initWithField:self coefficients:&oneInt coefficientsLen:1] autorelease];
  }

  return self;
}

- (ZXModulusPoly *)buildMonomial:(int)degree coefficient:(int)coefficient {
  if (degree < 0) {
    [NSException raise:NSInvalidArgumentException format:@"Degree must be greater than 0."];
  }
  if (coefficient == 0) {
    return self.zero;
  }

  int coefficientsLen = degree + 1;
  int coefficients[coefficientsLen];
  coefficients[0] = coefficient;
  for (int i = 1; i < coefficientsLen; i++) {
    coefficients[i] = 0;
  }
  return [[[ZXModulusPoly alloc] initWithField:self coefficients:coefficients coefficientsLen:coefficientsLen] autorelease];
}

- (int)add:(int)a b:(int)b {
  return (a + b) % self.modulus;
}

- (int)subtract:(int)a b:(int)b {
  return (self.modulus + a - b) % self.modulus;
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
  return [[self.expTable objectAtIndex:logSum % (self.modulus - 1)] intValue];
}

- (int)size {
  return self.modulus;
}

@end
