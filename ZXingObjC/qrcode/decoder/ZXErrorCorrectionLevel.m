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

#import "ZXErrorCorrectionLevel.h"

@interface ZXErrorCorrectionLevel ()

@property (nonatomic, assign) int bits;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int ordinal;

@end

@implementation ZXErrorCorrectionLevel

static NSArray *FOR_BITS = nil;

@synthesize bits;
@synthesize name;
@synthesize ordinal;

- (id)initWithOrdinal:(int)anOrdinal bits:(int)theBits name:(NSString *)aName {
  if (self = [super init]) {
    self.ordinal = anOrdinal;
    self.bits = theBits;
    self.name = aName;
  }

  return self;
}

- (void)dealloc {
  [name release];

  [super dealloc];
}

- (NSString *)description {
  return self.name;
}


+ (ZXErrorCorrectionLevel *)forBits:(int)bits {
  if (!FOR_BITS) {
    FOR_BITS = [[NSArray alloc] initWithObjects:[ZXErrorCorrectionLevel errorCorrectionLevelM],
                [ZXErrorCorrectionLevel errorCorrectionLevelL], [ZXErrorCorrectionLevel errorCorrectionLevelH],
                [ZXErrorCorrectionLevel errorCorrectionLevelQ], nil];
  }

  if (bits < 0 || bits >= [FOR_BITS count]) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"Invalid bits"
                                 userInfo:nil];
  }
  return [FOR_BITS objectAtIndex:bits];
}

/**
 * L = ~7% correction
 */
+ (ZXErrorCorrectionLevel *)errorCorrectionLevelL {
  static ZXErrorCorrectionLevel *thisLevel = nil;
  if (!thisLevel) {
    thisLevel = [[ZXErrorCorrectionLevel alloc] initWithOrdinal:0 bits:0x01 name:@"L"];
  }
  return thisLevel;
}

/**
 * M = ~15% correction
 */
+ (ZXErrorCorrectionLevel *)errorCorrectionLevelM {
  static ZXErrorCorrectionLevel *thisLevel = nil;
  if (!thisLevel) {
    thisLevel = [[ZXErrorCorrectionLevel alloc] initWithOrdinal:1 bits:0x00 name:@"M"];
  }
  return thisLevel;
}

/**
 * Q = ~25% correction
 */
+ (ZXErrorCorrectionLevel *)errorCorrectionLevelQ {
  static ZXErrorCorrectionLevel *thisLevel = nil;
  if (!thisLevel) {
    thisLevel = [[ZXErrorCorrectionLevel alloc] initWithOrdinal:2 bits:0x03 name:@"Q"];
  }
  return thisLevel;
}

/**
 * H = ~30% correction
 */
+ (ZXErrorCorrectionLevel *)errorCorrectionLevelH {
  static ZXErrorCorrectionLevel *thisLevel = nil;
  if (!thisLevel) {
    thisLevel = [[ZXErrorCorrectionLevel alloc] initWithOrdinal:3 bits:0x02 name:@"H"];
  }
  return thisLevel;
}

@end
