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

#import "ReedSolomonDecoderDataMatrixTestCase.h"
#import "ZXGenericGF.h"
#import "ZXReedSolomonDecoder.h"

@interface ReedSolomonDecoderDataMatrixTestCase ()

@property (nonatomic, retain) ZXReedSolomonDecoder* dmRSDecoder;

- (BOOL)checkQRRSDecode:(int*)received receivedLen:(int)receivedLen;

@end


@implementation ReedSolomonDecoderDataMatrixTestCase

const int DM_CODE_TEST_LEN = 3;
static int DM_CODE_TEST[DM_CODE_TEST_LEN] = { 142, 164, 186 };

const int DM_CODE_TEST_WITH_EC_LEN = 8;
static int DM_CODE_TEST_WITH_EC[DM_CODE_TEST_WITH_EC_LEN] = { 142, 164, 186, 114, 25, 5, 88, 102 };

const int DM_CODE_ECC_BYTES = DM_CODE_TEST_WITH_EC_LEN - DM_CODE_TEST_LEN;
const int DM_CODE_CORRECTABLE = DM_CODE_ECC_BYTES / 2;

@synthesize dmRSDecoder;

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  if (self = [super initWithInvocation:anInvocation]) {
    self.dmRSDecoder = [[[ZXReedSolomonDecoder alloc] initWithField:[ZXGenericGF DataMatrixField256]] autorelease];
  }

  return self;
}

- (void)dealloc {
  [dmRSDecoder release];

  [super dealloc];
}

- (void)testNoError {
  int receivedLen = DM_CODE_TEST_WITH_EC_LEN;
  int received[receivedLen];
  for (int i = 0; i < receivedLen; i++) {
    received[i] = DM_CODE_TEST_WITH_EC[i];
  }
  // no errors
  [self checkQRRSDecode:received receivedLen:receivedLen];
}

- (void)testMaxErrors {
  const int receivedLen = DM_CODE_TEST_WITH_EC_LEN;
  int received[receivedLen];
  for (int i = 0; i < DM_CODE_TEST_LEN; i++) {
    for (int i = 0; i < DM_CODE_TEST_WITH_EC_LEN; i++) {
      received[i] = DM_CODE_TEST_WITH_EC[i];
    }
    [self corrupt:received receivedLen:receivedLen howMany:DM_CODE_CORRECTABLE];
    [self checkQRRSDecode:received receivedLen:receivedLen];
  }
}

- (void)testTooManyErrors {
  const int receivedLen = DM_CODE_TEST_WITH_EC_LEN;
  int received[receivedLen];
  for (int i = 0; i < DM_CODE_TEST_WITH_EC_LEN; i++) {
    received[i] = DM_CODE_TEST_WITH_EC[i];
  }
  [self corrupt:received receivedLen:receivedLen howMany:DM_CODE_CORRECTABLE + 1];
  if ([self checkQRRSDecode:received receivedLen:receivedLen]) {
    STFail(@"Should not have decoded");
  }
}

- (BOOL)checkQRRSDecode:(int*)received receivedLen:(int)receivedLen {
  if (![self.dmRSDecoder decode:received receivedLen:receivedLen twoS:DM_CODE_ECC_BYTES error:nil]) {
    return NO;
  }
  for (int i = 0; i < DM_CODE_TEST_LEN; i++) {
    STAssertEquals(DM_CODE_TEST[i], received[i], @"Expected %d to equal %d", DM_CODE_TEST[i], received[i]);
  }
  return YES;
}

@end
