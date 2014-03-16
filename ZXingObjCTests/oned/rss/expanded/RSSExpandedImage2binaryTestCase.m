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

#import "RSSExpandedImage2binaryTestCase.h"

@interface ZXRSSExpandedReader (PrivateMethods)

- (NSMutableArray *)decodeRow2pairs:(int)rowNumber row:(ZXBitArray *)row;

@end

@implementation RSSExpandedImage2binaryTestCase

- (void)testDecodeRow2binary_1 {
  // (11)100224(17)110224(3102)000100
  NSString *path = @"Resources/blackbox/rssexpanded-1/1.png";
  NSString *expected = @" ...X...X .X....X. .XX...X. X..X...X ...XX.X. ..X.X... ..X.X..X ...X..X. X.X....X .X....X. .....X.. X...X...";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)testDecodeRow2binary_2 {
  // (01)90012345678908(3103)001750
  NSString *path = @"Resources/blackbox/rssexpanded-1/2.png";
  NSString *expected = @" ..X..... ......X. .XXX.X.X .X...XX. XXXXX.XX XX.X.... .XX.XX.X .XX.";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)testDecodeRow2binary_3 {
  // (10)12A
  NSString *path = @"Resources/blackbox/rssexpanded-1/3.png";
  NSString *expected = @" .......X ..XX..X. X.X....X .......X ....";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)testDecodeRow2binary_4 {
  // (01)98898765432106(3202)012345(15)991231
  NSString *path = @"Resources/blackbox/rssexpanded-1/4.png";
  NSString *expected = @" ..XXXX.X XX.XXXX. .XXX.XX. XX..X... .XXXXX.. XX.X..X. ..XX..XX XX.X.XXX X..XX..X .X.XXXXX XXXX";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)testDecodeRow2binary_5 {
  // (01)90614141000015(3202)000150
  NSString *path = @"Resources/blackbox/rssexpanded-1/5.png";
  NSString *expected = @" ..X.X... .XXXX.X. XX..XXXX ....XX.. X....... ....X... ....X..X .XX.";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)testDecodeRow2binary_10 {
  // (01)98898765432106(15)991231(3103)001750(10)12A(422)123(21)123456(423)0123456789012
  NSString *path = @"Resources/blackbox/rssexpanded-1/10.png";
  NSString *expected = @" .X.XX..X XX.XXXX. .XXX.XX. XX..X... .XXXXX.. XX.X..X. ..XX...X XX.X.... X.X.X.X. X.X..X.X .X....X. XX...X.. ...XX.X. .XXXXXX. .X..XX.. X.X.X... .X...... XXXX.... XX.XX... XXXXX.X. ...XXXXX .....X.X ...X.... X.XXX..X X.X.X... XX.XX..X .X..X..X .X.X.X.X X.XX...X .XX.XXX. XXX.X.XX ..X.";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)testDecodeRow2binary_11 {
  // (01)98898765432106(15)991231(3103)001750(10)12A(422)123(21)123456
  NSString *expected = @" .X.XX..X XX.XXXX. .XXX.XX. XX..X... .XXXXX.. XX.X..X. ..XX...X XX.X.... X.X.X.X. X.X..X.X .X....X. XX...X.. ...XX.X. .XXXXXX. .X..XX.. X.X.X... .X...... XXXX.... XX.XX... XXXXX.X. ...XXXXX .....X.X ...X.... X.XXX..X X.X.X... ....";
  NSString *path = @"Resources/blackbox/rssexpanded-1/11.png";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)testDecodeRow2binary_12 {
  // (01)98898765432106(3103)001750

  NSString *expected = @" ..X..XX. XXXX..XX X.XX.XX. .X....XX XXX..XX. X..X.... .XX.XX.X .XX.";
  NSString *path = @"Resources/blackbox/rssexpanded-1/12.png";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)testDecodeRow2binary_13 {
  // (01)90012345678908(3922)795

  NSString *expected = @" ..XX..X. ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. X.X.XXXX .X..X..X ......X.";
  NSString *path = @"Resources/blackbox/rssexpanded-1/13.png";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)testDecodeRow2binary_14 {
  // (01)90012345678908(3932)0401234

  NSString *expected = @" ..XX.X.. ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. X.....X. X.....X. X.X.X.XX .X...... X...";
  NSString *path = @"Resources/blackbox/rssexpanded-1/14.png";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)testDecodeRow2binary_15 {
  // (01)90012345678908(3102)001750(11)100312

  NSString *expected = @" ..XXX... ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX..";
  NSString *path = @"Resources/blackbox/rssexpanded-1/15.png";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)testDecodeRow2binary_16 {
  // (01)90012345678908(3202)001750(11)100312

  NSString *expected = @" ..XXX..X ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX..";
  NSString *path = @"Resources/blackbox/rssexpanded-1/16.png";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)testDecodeRow2binary_17 {
  // (01)90012345678908(3102)001750(13)100312

  NSString *expected = @" ..XXX.X. ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX..";
  NSString *path = @"Resources/blackbox/rssexpanded-1/17.png";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)testDecodeRow2binary_18 {
  // (01)90012345678908(3202)001750(13)100312

  NSString *expected = @" ..XXX.XX ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX..";
  NSString *path = @"Resources/blackbox/rssexpanded-1/18.png";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)testDecodeRow2binary_19 {
  // (01)90012345678908(3102)001750(15)100312

  NSString *expected = @" ..XXXX.. ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX..";
  NSString *path = @"Resources/blackbox/rssexpanded-1/19.png";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)testDecodeRow2binary_20 {
  // (01)90012345678908(3202)001750(15)100312

  NSString *expected = @" ..XXXX.X ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX..";
  NSString *path = @"Resources/blackbox/rssexpanded-1/20.png";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)testDecodeRow2binary_21 {
  // (01)90012345678908(3102)001750(17)100312

  NSString *expected = @" ..XXXXX. ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX..";
  NSString *path = @"Resources/blackbox/rssexpanded-1/21.png";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)testDecodeRow2binary_22 {
  // (01)90012345678908(3202)001750(17)100312

  NSString *expected = @" ..XXXXXX ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX..";
  NSString *path = @"Resources/blackbox/rssexpanded-1/22.png";

  [self assertCorrectImage2binary:path expected:expected];
}

- (void)assertCorrectImage2binary:(NSString *)path expected:(NSString *)expected {
  ZXImage *image = [[ZXImage alloc] initWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:path withExtension:nil]];
  ZXBinaryBitmap *binaryMap = [[ZXBinaryBitmap alloc] initWithBinarizer:[[ZXGlobalHistogramBinarizer alloc] initWithSource:[[ZXCGImageLuminanceSource alloc] initWithZXImage:image]]];
  int rowNumber = binaryMap.height / 2;
  ZXBitArray *row = [binaryMap blackRow:rowNumber row:nil error:nil];

  ZXRSSExpandedReader *rssExpandedReader = [[ZXRSSExpandedReader alloc] init];
  NSArray *pairs = [rssExpandedReader decodeRow2pairs:rowNumber row:row];
  if (!pairs) {
    XCTFail(@"Unable to decode pairs");
    return;
  }
  ZXBitArray *binary = [ZXBitArrayBuilder buildBitArray:pairs];
  XCTAssertEqualObjects([binary description], expected, @"Expected %@ to equal %@", [binary description], expected);
}

@end
