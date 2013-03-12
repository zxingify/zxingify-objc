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

#import "ZXBarcodeMatrix.h"
#import "ZXBitMatrix.h"
#import "ZXEncodeHints.h"
#import "ZXPDF417.h"
#import "ZXPDF417Writer.h"

@interface ZXPDF417Writer ()

- (ZXBitMatrix *)bitMatrixFromEncoder:(ZXPDF417 *)encoder contents:(NSString *)contents width:(int)width height:(int)height error:(NSError **)error;
- (ZXBitMatrix *)bitMatrixFrombitArray:(unsigned char **)input height:(int)height width:(int)width;
- (unsigned char **)rotateArray:(unsigned char **)bitarray height:(int)height width:(int)width;

@end

@implementation ZXPDF417Writer

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height
                  hints:(ZXEncodeHints *)hints error:(NSError **)error {
  if (format != kBarcodeFormatPDF417) {
    [NSException raise:NSInvalidArgumentException format:@"Can only encode PDF_417, but got %d", format];
  }

  ZXPDF417 *encoder = [[[ZXPDF417 alloc] init] autorelease];

  if (hints != nil) {
    encoder.compact = hints.pdf417Compact;
    encoder.compaction = hints.pdf417Compaction;
    if (hints.pdf417Dimensions != nil) {
      ZXDimensions *dimensions = hints.pdf417Dimensions;
      [encoder setDimensionsWithMaxCols:dimensions.maxCols
                                minCols:dimensions.minCols
                                maxRows:dimensions.maxRows
                                minRows:dimensions.minRows];
    }
  }

  return [self bitMatrixFromEncoder:encoder contents:contents width:width height:height error:error];
}

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height error:(NSError **)error {
  return [self encode:contents format:format width:width height:height hints:nil error:error];
}

/**
 * Takes encoder, accounts for width/height, and retrieves bit matrix
 */
- (ZXBitMatrix *)bitMatrixFromEncoder:(ZXPDF417 *)encoder contents:(NSString *)contents width:(int)width height:(int)height error:(NSError **)error {
  int errorCorrectionLevel = 2;
  if (![encoder generateBarcodeLogic:contents errorCorrectionLevel:errorCorrectionLevel error:error]) {
    return nil;
  }

  int lineThickness = 2;
  int aspectRatio = 4;

  int scaleHeight;
  int scaleWidth;
  unsigned char **originalScale = [[encoder barcodeMatrix] scaledMatrixWithHeight:&scaleHeight width:&scaleWidth xScale:lineThickness yScale:aspectRatio * lineThickness];
  BOOL rotated = NO;
  if ((height > width) ^ (scaleWidth < scaleHeight)) {
    unsigned char **oldOriginalScale = originalScale;
    originalScale = [self rotateArray:oldOriginalScale height:scaleHeight width:scaleWidth];
    free(oldOriginalScale);
    rotated = YES;
  }

  int scaleX = width / scaleWidth;
  int scaleY = height / scaleHeight;

  int scale;
  if (scaleX < scaleY) {
    scale = scaleX;
  } else {
    scale = scaleY;
  }

  ZXBitMatrix *result = nil;
  if (scale > 1) {
    unsigned char **scaledMatrix =
      [[encoder barcodeMatrix] scaledMatrixWithHeight:&scaleHeight width:&scaleWidth xScale:scale * lineThickness yScale:scale * aspectRatio * lineThickness];
    if (rotated) {
      unsigned char **oldScaledMatrix = scaledMatrix;
      scaledMatrix = [self rotateArray:scaledMatrix height:scaleHeight width:scaleWidth];
      free(oldScaledMatrix);
    }
    result = [self bitMatrixFrombitArray:scaledMatrix height:scaleHeight width:scaleWidth];
    free(scaledMatrix);
  } else {
    result = [self bitMatrixFrombitArray:originalScale height:scaleHeight width:scaleWidth];
  }
  free(originalScale);
  return result;
}

/**
 * This takes an array holding the values of the PDF 417
 */
- (ZXBitMatrix *)bitMatrixFrombitArray:(unsigned char **)input height:(int)height width:(int)width {
  // Creates a small whitespace boarder around the barcode
  int whiteSpace = 30;

  // Creates the bitmatrix with extra space for whtespace
  ZXBitMatrix *output = [[[ZXBitMatrix alloc] initWithWidth:width + 2 * whiteSpace height:height + 2 * whiteSpace] autorelease];
  [output clear];
  for (int y = 0, yOutput = output.height - whiteSpace; y < height; y++, yOutput--) {
    for (int x = 0; x < width; x++) {
      // Zero is white in the bytematrix
      if (input[y][x] == 1) {
        [output setX:x + whiteSpace y:yOutput];
      }
    }
  }
  return output;
}

/**
 * Takes and rotates the it 90 degrees
 */
- (unsigned char **)rotateArray:(unsigned char **)bitarray height:(int)height width:(int)width {
  unsigned char **temp = (unsigned char **)malloc(width * sizeof(unsigned char *));
  for (int ii = 0; ii < height; ii++) {
    // This makes the direction consistent on screen when rotating the
    // screen;
    int inverseii = height - ii - 1;
    for (int jj = 0; jj < width; jj++) {
      temp[jj][inverseii] = bitarray[ii][jj];
    }
  }
  return temp;
}

@end
