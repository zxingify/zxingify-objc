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

#import <SenTestingKit/SenTestingKit.h>

@interface AbstractReedSolomonTestCase : SenTestCase

- (void)corrupt:(int*)received receivedLen:(int)receivedLen howMany:(int)howMany;
- (void)doTestQRCodeEncoding:(int*)dataBytes dataBytesLen:(int)dataBytesLen
             expectedECBytes:(int*)expectedECBytes expectedECBytesLen:(int)expectedECBytesLen;
- (void)assertArraysEqual:(int*)expected expectedOffset:(int)expectedOffset
                   actual:(int*)actual actualOffset:(int)actualOffset length:(int)length;

@end
