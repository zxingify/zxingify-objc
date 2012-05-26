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

#import "ZXReedSolomonDecoder.h"
#import "ReedSolomonDecoderQRCodeTestCase.h"
#import "ZXGenericGF.h"

@interface ReedSolomonDecoderQRCodeTestCase ()

@property (nonatomic, retain) ZXReedSolomonDecoder* qrRSDecoder;

- (BOOL)checkQRRSDecode:(int*)received receivedLen:(int)receivedLen;

@end


@implementation ReedSolomonDecoderQRCodeTestCase

/** See ISO 18004, Appendix I, from which this example is taken. */
const int QR_CODE_TEST_LEN = 16;
static int QR_CODE_TEST[QR_CODE_TEST_LEN] =
  { 0x10, 0x20, 0x0C, 0x56, 0x61, 0x80, 0xEC, 0x11, 0xEC,
    0x11, 0xEC, 0x11, 0xEC, 0x11, 0xEC, 0x11 };

const int QR_CODE_TEST_WITH_EC_LEN = 26;
static int QR_CODE_TEST_WITH_EC[QR_CODE_TEST_WITH_EC_LEN] =
  { 0x10, 0x20, 0x0C, 0x56, 0x61, 0x80, 0xEC, 0x11, 0xEC,
    0x11, 0xEC, 0x11, 0xEC, 0x11, 0xEC, 0x11, 0xA5, 0x24,
    0xD4, 0xC1, 0xED, 0x36, 0xC7, 0x87, 0x2C, 0x55 };

const int QR_CODE_ECC_BYTES = QR_CODE_TEST_WITH_EC_LEN - QR_CODE_TEST_LEN;
const int QR_CODE_CORRECTABLE = QR_CODE_ECC_BYTES / 2;

@synthesize qrRSDecoder;

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  if (self = [super initWithInvocation:anInvocation]) {
    self.qrRSDecoder = [[[ZXReedSolomonDecoder alloc] initWithField:[ZXGenericGF QrCodeField256]] autorelease];
  }

  return self;
}

- (void)dealloc {
  [qrRSDecoder release];

  [super dealloc];
}

- (void)testNoError {
  int receivedLen = QR_CODE_TEST_WITH_EC_LEN;
  int received[receivedLen];
  for (int i = 0; i < receivedLen; i++) {
    received[i] = QR_CODE_TEST_WITH_EC[i];
  }
  // no errors
  [self checkQRRSDecode:received receivedLen:receivedLen];
}

- (void)testMaxErrors {
  const int receivedLen = QR_CODE_TEST_WITH_EC_LEN;
  int received[receivedLen];
  for (int i = 0; i < QR_CODE_TEST_LEN; i++) {
    for (int i = 0; i < QR_CODE_TEST_WITH_EC_LEN; i++) {
      received[i] = QR_CODE_TEST_WITH_EC[i];
    }
    [self corrupt:received receivedLen:receivedLen howMany:QR_CODE_CORRECTABLE];
    [self checkQRRSDecode:received receivedLen:receivedLen];
  }
}

- (void)testTooManyErrors {
  const int receivedLen = QR_CODE_TEST_WITH_EC_LEN;
  int received[receivedLen];
  for (int i = 0; i < QR_CODE_TEST_WITH_EC_LEN; i++) {
    received[i] = QR_CODE_TEST_WITH_EC[i];
  }
  [self corrupt:received receivedLen:receivedLen howMany:QR_CODE_CORRECTABLE + 1];
  if ([self checkQRRSDecode:received receivedLen:receivedLen]) {
    STFail(@"Should not have decoded");
  }
}

- (BOOL)checkQRRSDecode:(int*)received receivedLen:(int)receivedLen {
  if (![self.qrRSDecoder decode:received receivedLen:receivedLen twoS:QR_CODE_ECC_BYTES error:nil]) {
    return NO;
  }
  for (int i = 0; i < QR_CODE_TEST_LEN; i++) {
    STAssertEquals(QR_CODE_TEST[i], received[i], @"Expected %d to equal %d", QR_CODE_TEST[i], received[i]);
  }
  return YES;
}

@end
