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

#import "ZXStringUtils.h"
#import "ZXStringUtilsTestCase.h"

@interface ZXStringUtilsTestCase ()

- (void)doTestWithBytes:(unsigned char*)bytes length:(int)length encoding:(NSStringEncoding)encoding;

@end

@implementation ZXStringUtilsTestCase

- (void)testShortShiftJIS_1 {
  // ÈáëÈ≠ö
  unsigned char bytes[4] = { 0x8b, 0xe0, 0x8b, 0x9b };
  [self doTestWithBytes:bytes length:4 encoding:NSShiftJISStringEncoding];
}

- (void)testShortISO88591_1 {
  // b√•d
  unsigned char bytes[3] = { 0x62, 0xe5, 0x64 };
  [self doTestWithBytes:bytes length:3 encoding:NSISOLatin1StringEncoding];
}

- (void)testMixedShiftJIS_1 {
  // Hello Èáë!
  unsigned char bytes[9] = { 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x8b, 0xe0, 0x21 };
  [self doTestWithBytes:bytes length:9 encoding:NSShiftJISStringEncoding];
}

- (void)doTestWithBytes:(unsigned char*)bytes length:(int)length encoding:(NSStringEncoding)encoding {
  STAssertEquals([ZXStringUtils guessEncoding:bytes length:length hints:nil], encoding, @"Encodings do not match");
}

@end
