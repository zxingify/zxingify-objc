/*
 * Copyright 2013 ZXing authors
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

#import "ZXDataMatrixWriterTestCase.h"

@implementation ZXDataMatrixWriterTestCase

- (void)testDataMatrixWriterIssue {
  NSString *hugeString = @"<MP v=\"022\" U=\"C42FFB11DA74E035CC8C0\" l=\"de-DE\"><P g=\"Mich\" f=\"Must_1\" egk=\"M996218\" b=\"1926\" s=\"M\" /><A lanr=\"165630\" n=\"Drs. X Über\" s=\"Haupt 55\" z=\"01234\" c=\"Am\" p=\"04-12345\" e=\"m.uebl@mein-z.de\" t=\"01-04\" /><O w=\"89\" /><S c=\"412\"><M p=\"2262\" m=\"1\" /><M p=\"7020\" m=\"1\" /><M p=\"772\" t=\"mo:½-1 mi:(½-1)\" i=\"Hello, World\" /><M p=\"984\" v=\"1\" i=\"abds 1x1\" /></S><S c=\"418\"><M p=\"6360\" d=\"1\" /></S></MP>";
  ZXDataMatrixWriter *writer = [[ZXDataMatrixWriter alloc] init];
  ZXBitMatrix *matrix = [writer encode:hugeString format:kBarcodeFormatDataMatrix width:0 height:0 hints:nil error:nil];
  ZXImage *image = [ZXImage imageWithMatrix:matrix];
  XCTAssertNotNil(image);
  
  ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:image.cgimage];
  ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
  
  ZXDataMatrixReader *reader = [[ZXDataMatrixReader alloc] init];
  ZXDecodeHints *hints = [ZXDecodeHints hints];
  hints.pureBarcode = YES;
  ZXResult *result = [reader decode:bitmap hints:hints error:nil];
  XCTAssertNotNil(result);
}

- (void)testDataMatrixImageWriter {
  ZXEncodeHints *hints = [ZXEncodeHints hints];
  hints.dataMatrixShape = ZXDataMatrixSymbolShapeHintForceSquare;

  int bigEnough = 64;
  ZXDataMatrixWriter *writer = [[ZXDataMatrixWriter alloc] init];
  ZXBitMatrix *matrix = [writer encode:@"Hello Google" format:kBarcodeFormatDataMatrix width:bigEnough height:bigEnough hints:hints error:nil];
  XCTAssertNotNil(matrix);
  XCTAssertTrue(bigEnough >= matrix.width);
  XCTAssertTrue(bigEnough >= matrix.height);
}

- (void)testDataMatrixWriter {
  ZXEncodeHints *hints = [ZXEncodeHints hints];
  hints.dataMatrixShape = ZXDataMatrixSymbolShapeHintForceSquare;

  int bigEnough = 14;
  ZXDataMatrixWriter *writer = [[ZXDataMatrixWriter alloc] init];
  ZXBitMatrix *matrix = [writer encode:@"Hello Me" format:kBarcodeFormatDataMatrix width:bigEnough height:bigEnough hints:hints error:nil];
  XCTAssertNotNil(matrix);
  XCTAssertEqual(bigEnough, matrix.width);
  XCTAssertEqual(bigEnough, matrix.height);
}

- (void)testDataMatrixTooSmall {
  // The DataMatrix will not fit in this size, so the matrix should come back bigger
  int tooSmall = 8;
  ZXDataMatrixWriter *writer = [[ZXDataMatrixWriter alloc] init];
  ZXBitMatrix *matrix = [writer encode:@"http://www.google.com/" format:kBarcodeFormatDataMatrix width:tooSmall height:tooSmall hints:nil error:nil];
  XCTAssertNotNil(matrix);
  XCTAssertTrue(tooSmall < matrix.width);
  XCTAssertTrue(tooSmall < matrix.height);
}

@end
