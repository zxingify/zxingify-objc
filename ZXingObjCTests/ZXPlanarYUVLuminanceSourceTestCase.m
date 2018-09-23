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

#import "ZXPlanarYUVLuminanceSource.h"
#import "ZXPlanarYUVLuminanceSourceTestCase.h"

const int8_t YUV[] = {
  0,  1,  1,  2,  3,  5,
  8, 13, 21, 34, 55, 89,
  0,  -1,  -1,  -2,  -3,  -5,
  -8, -13, -21, -34, -55, -89,
  127, 127, 127, 127, 127, 127,
  127, 127, 127, 127, 127, 127,
};
const int COLS = 6;
const int ROWS = 4;
static int8_t Y[COLS * ROWS];

@implementation ZXPlanarYUVLuminanceSourceTestCase

+ (void)initialize {
  memcpy(Y, YUV, COLS * ROWS);
}

- (void)testNoCrop {
  ZXPlanarYUVLuminanceSource *source =
    [[ZXPlanarYUVLuminanceSource alloc] initWithYuvData:(int8_t *)YUV yuvDataLen:COLS * ROWS dataWidth:COLS dataHeight:ROWS left:0 top:0 width:COLS height:ROWS reverseHorizontal:NO];
  [self assertEqualsExpected:(int8_t *)Y expectedFrom:0 actual:source.matrix.array actualFrom:0 length:COLS * ROWS];
  for (int r = 0; r < ROWS; r++) {
    [self assertEqualsExpected:Y expectedFrom:r * COLS actual:[source rowAtY:r row:nil].array actualFrom:0 length:COLS];
  }
}

- (void)testCrop {
  ZXPlanarYUVLuminanceSource *source =
    [[ZXPlanarYUVLuminanceSource alloc] initWithYuvData:(int8_t *)YUV yuvDataLen:COLS * ROWS dataWidth:COLS dataHeight:ROWS left:1 top:1 width:COLS-2 height:ROWS-2 reverseHorizontal:NO];
  XCTAssertTrue([source cropSupported]);
  ZXByteArray *cropMatrix = [source matrix];
  for (int r = 0; r < ROWS-2; r++) {
    [self assertEqualsExpected:Y expectedFrom:(r + 1) * COLS + 1 actual:[source rowAtY:r row:nil].array actualFrom:0 length:COLS-2];
  }
  for (int r = 0; r < ROWS-2; r++) {
    [self assertEqualsExpected:Y expectedFrom:(r + 1) * COLS + 1 actual:cropMatrix.array actualFrom:r * (COLS - 2) length:COLS-2];
  }
}

- (void)assertEqualsExpected:(int8_t *)expected expectedFrom:(int)expectedFrom
                      actual:(int8_t *)actual actualFrom:(int)actualFrom
                      length:(int)length {
  for (int i = 0; i < length; i++) {
    XCTAssertEqual(expected[expectedFrom + i], actual[actualFrom + i]);
  }
}

@end
