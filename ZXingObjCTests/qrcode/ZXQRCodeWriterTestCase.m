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

#import "ZXQRCodeWriterTestCase.h"

static NSString *BASE_IMAGE_PATH = @"Resources/golden/qrcode/";

@implementation ZXQRCodeWriterTestCase

- (ZXImage *)loadImage:(NSString *)fileName {
  return [[ZXImage alloc] initWithURL:
           [[NSBundle bundleForClass:[self class]] URLForResource:
            [BASE_IMAGE_PATH stringByAppendingString:fileName] withExtension:nil]];
}

// In case the golden images are not monochromatic, convert the RGB values to greyscale.
- (ZXBitMatrix *)createMatrixFromImage:(ZXImage *)image {
  size_t width = image.width;
  size_t height = image.height;
  uint32_t *data;

  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(0, width, height, 8, width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
  CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
  CGContextSetShouldAntialias(context, NO);

  CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.cgimage);

  data = (uint32_t *) malloc(width * height * sizeof(uint32_t));
  memcpy(data, CGBitmapContextGetData(context), width * height * sizeof(uint32_t));

  ZXBitMatrix *matrix = [[ZXBitMatrix alloc] initWithWidth:(int)width height:(int)height];
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int pixel = data[y * width + x];
      int luminance = (306 * ((pixel >> 16) & 0xFF) +
                       601 * ((pixel >> 8) & 0xFF) +
                       117 * (pixel & 0xFF)) >> 10;
      if (luminance <= 0x7F) {
        [matrix setX:x y:y];
      }
    }
  }
  return matrix;
}

- (void)testQRCodeWriter {
  // The QR should be multiplied up to fit, with extra padding if necessary
  int bigEnough = 256;
  ZXQRCodeWriter *writer = [[ZXQRCodeWriter alloc] init];
  ZXBitMatrix *matrix = [writer encode:@"http://www.google.com/" format:kBarcodeFormatQRCode width:bigEnough
                                height:bigEnough hints:nil error:nil];
  XCTAssertNotNil(matrix);
  XCTAssertEqual(bigEnough, matrix.width);
  XCTAssertEqual(bigEnough, matrix.height);

  // The QR will not fit in this size, so the matrix should come back bigger
  int tooSmall = 20;
  matrix = [writer encode:@"http://www.google.com/" format:kBarcodeFormatQRCode width:tooSmall
                   height:tooSmall hints:nil error:nil];
  XCTAssertNotNil(matrix);
  XCTAssertTrue(tooSmall < matrix.width);
  XCTAssertTrue(tooSmall < matrix.height);

  // We should also be able to handle non-square requests by padding them
  int strangeWidth = 500;
  int strangeHeight = 100;
  matrix = [writer encode:@"http://www.google.com/" format:kBarcodeFormatQRCode width:strangeWidth
                   height:strangeHeight hints:nil error:nil];
  XCTAssertNotNil(matrix);
  XCTAssertEqual(strangeWidth, matrix.width);
  XCTAssertEqual(strangeHeight, matrix.height);
}

- (void)compareToGoldenFile:(NSString *)contents ecLevel:(ZXErrorCorrectionLevel *)ecLevel
                 resolution:(int)resolution fileName:(NSString *)fileName {
  ZXImage *image = [self loadImage:fileName];
  XCTAssertNotNil(image);
  ZXBitMatrix *goldenResult = [self createMatrixFromImage:image];
  XCTAssertNotNil(goldenResult);

  ZXEncodeHints *hints = [[ZXEncodeHints alloc] init];
  hints.errorCorrectionLevel = ecLevel;
  ZXQRCodeWriter *writer = [[ZXQRCodeWriter alloc] init];
  ZXBitMatrix *generatedResult = [writer encode:contents format:kBarcodeFormatQRCode width:resolution
                                         height:resolution hints:hints error:nil];

  XCTAssertEqual(resolution, generatedResult.width);
  XCTAssertEqual(resolution, generatedResult.height);
  XCTAssertEqualObjects(goldenResult, generatedResult);
}

// Golden images are generated with "qrcode_sample.cc". The images are checked with both eye balls
// and cell phones. We expect pixel-perfect results, because the error correction level is known,
// and the pixel dimensions matches exactly.
- (void)testRegressionTest {
  [self compareToGoldenFile:@"http://www.google.com/" ecLevel:[ZXErrorCorrectionLevel errorCorrectionLevelM]
                 resolution:99 fileName:@"renderer-test-01.png"];
}

@end
