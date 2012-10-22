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

#import "ReedSolomonEncoderQRCodeTestCase.h"
#import "ZXGenericGF.h"
#import "ZXReedSolomonDecoder.h"
#import "ZXReedSolomonEncoder.h"

@implementation ReedSolomonEncoderQRCodeTestCase

/**
 * Tests example given in ISO 18004, Annex I
 */
- (void)testISO18004Example {
  const int dataBytesLen = 16;
  int dataBytes[dataBytesLen] = {
    0x10, 0x20, 0x0C, 0x56, 0x61, 0x80, 0xEC, 0x11,
    0xEC, 0x11, 0xEC, 0x11, 0xEC, 0x11, 0xEC, 0x11 };
  const int expectedECBytesLen = 10;
  int expectedECBytes[expectedECBytesLen] = {
    0xA5, 0x24, 0xD4, 0xC1, 0xED, 0x36, 0xC7, 0x87,
    0x2C, 0x55 };
  [self doTestQRCodeEncoding:dataBytes dataBytesLen:dataBytesLen expectedECBytes:expectedECBytes expectedECBytesLen:expectedECBytesLen];
}

- (void)testQRCodeVersusDecoder {
  ZXReedSolomonEncoder* encoder = [[[ZXReedSolomonEncoder alloc] initWithField:[ZXGenericGF QrCodeField256]] autorelease];
  ZXReedSolomonDecoder* decoder = [[[ZXReedSolomonDecoder alloc] initWithField:[ZXGenericGF QrCodeField256]] autorelease];
  for (int i = 0; i < 100; i++) {
    int size = 2 + (arc4random() % 254);
    int toEncode[size];
    int ecBytes = 1 + (arc4random() % (2 * (1 + size / 8)));
    ecBytes = MIN(ecBytes, size - 1);
    int dataBytes = size - ecBytes;
    for (int j = 0; j < size; j++) {
      if (j < dataBytes) {
        toEncode[j] = arc4random() % 256;
      } else {
        toEncode[j] = 0;
      }
    }
    int original[dataBytes];
    for (int j = 0; j < dataBytes; j++) {
      original[j] = toEncode[j];
    }
    [encoder encode:toEncode toEncodeLen:size ecBytes:ecBytes];
    [self corrupt:toEncode receivedLen:size howMany:ecBytes / 2];
    [decoder decode:toEncode receivedLen:size twoS:ecBytes error:nil];

    [self assertArraysEqual:original expectedOffset:0 actual:toEncode actualOffset:0 length:dataBytes];
  }
}

@end
