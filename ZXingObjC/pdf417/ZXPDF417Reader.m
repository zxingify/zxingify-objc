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

#import "ZXBarcodeFormat.h"
#import "ZXBinaryBitmap.h"
#import "ZXBitMatrix.h"
#import "ZXDecodeHints.h"
#import "ZXDecoderResult.h"
#import "ZXDetectorResult.h"
#import "ZXErrors.h"
#import "ZXPDF417Decoder.h"
#import "ZXPDF417Detector.h"
#import "ZXPDF417Reader.h"
#import "ZXResult.h"

@interface ZXPDF417Reader ()

@property (nonatomic, retain) ZXPDF417Decoder *decoder;

- (ZXBitMatrix *)extractPureBits:(ZXBitMatrix *)image;
- (int)findPatternStart:(int)x y:(int)y image:(ZXBitMatrix *)image;
- (int)findPatternEnd:(int)x y:(int)y image:(ZXBitMatrix *)image;
- (int)moduleSize:(NSArray *)leftTopBlack image:(ZXBitMatrix *)image;

@end

@implementation ZXPDF417Reader

@synthesize decoder;

- (id)init {
  if (self = [super init]) {
    self.decoder = [[[ZXPDF417Decoder alloc] init] autorelease];
  }
  return self;
}


- (void)dealloc {
  [decoder release];

  [super dealloc];
}

/**
 * Locates and decodes a PDF417 code in an image.
 */
- (ZXResult *)decode:(ZXBinaryBitmap *)image error:(NSError **)error {
  return [self decode:image hints:nil error:error];
}

- (ZXResult *)decode:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints error:(NSError **)error {
  ZXDecoderResult *decoderResult;
  NSArray *points;
  if (hints != nil && hints.pureBarcode) {
    ZXBitMatrix *matrix = [image blackMatrixWithError:error];
    if (!matrix) {
      return nil;
    }
    ZXBitMatrix *bits = [self extractPureBits:matrix];
    if (!bits) {
      if (error) *error = NotFoundErrorInstance();
      return nil;
    }
    decoderResult = [decoder decodeMatrix:bits error:error];
    if (!decoderResult) {
      return nil;
    }
    points = [NSArray array];
  } else {
    ZXDetectorResult *detectorResult = [[[[ZXPDF417Detector alloc] initWithImage:image] autorelease] detectWithError:error];
    if (!detectorResult) {
      return nil;
    }
    decoderResult = [decoder decodeMatrix:detectorResult.bits error:error];
    if (!decoderResult) {
      return nil;
    }
    points = detectorResult.points;
  }
  return [ZXResult resultWithText:decoderResult.text
                         rawBytes:decoderResult.rawBytes
                           length:decoderResult.length
                     resultPoints:points
                           format:kBarcodeFormatPDF417];
}

- (void)reset {
  // do nothing
}


/**
 * This method detects a code in a "pure" image -- that is, pure monochrome image
 * which contains only an unrotated, unskewed, image of a code, with some white border
 * around it. This is a specialized method that works exceptionally fast in this special
 * case.
 */
- (ZXBitMatrix *)extractPureBits:(ZXBitMatrix *)image {
  NSArray *leftTopBlack = image.topLeftOnBit;
  NSArray *rightBottomBlack = image.bottomRightOnBit;
  if (leftTopBlack == nil || rightBottomBlack == nil) {
    return nil;
  }

  int moduleSize = [self moduleSize:leftTopBlack image:image];
  if (moduleSize == -1) {
    return nil;
  }

  int top = [[leftTopBlack objectAtIndex:1] intValue];
  int bottom = [[rightBottomBlack objectAtIndex:1] intValue];
  int left = [self findPatternStart:[[leftTopBlack objectAtIndex:0] intValue] y:top image:image];
  if (left == -1) {
    return nil;
  }
  int right = [self findPatternEnd:[[leftTopBlack objectAtIndex:0] intValue] y:top image:image];
  if (right == -1) {
    return nil;
  }

  int matrixWidth = (right - left + 1) / moduleSize;
  int matrixHeight = (bottom - top + 1) / moduleSize;
  if (matrixWidth <= 0 || matrixHeight <= 0) {
    return nil;
  }

  int nudge = moduleSize >> 1;
  top += nudge;
  left += nudge;

  ZXBitMatrix *bits = [[[ZXBitMatrix alloc] initWithWidth:matrixWidth height:matrixHeight] autorelease];
  for (int y = 0; y < matrixHeight; y++) {
    int iOffset = top + y * moduleSize;
    for (int x = 0; x < matrixWidth; x++) {
      if ([image getX:left + x * moduleSize y:iOffset]) {
        [bits setX:x y:y];
      }
    }
  }

  return bits;
}

- (int)moduleSize:(NSArray *)leftTopBlack image:(ZXBitMatrix *)image {
  int x = [[leftTopBlack objectAtIndex:0] intValue];
  int y = [[leftTopBlack objectAtIndex:1] intValue];
  int width = [image width];
  while (x < width && [image getX:x y:y]) {
    x++;
  }
  if (x == width) {
    return -1;
  }

  int moduleSize = (int)((unsigned int)(x - [[leftTopBlack objectAtIndex:0] intValue]) >> 3);
  if (moduleSize == 0) {
    return -1;
  }

  return moduleSize;
}

- (int)findPatternStart:(int)x y:(int)y image:(ZXBitMatrix *)image {
  int width = image.width;
  int start = x;

  int transitions = 0;
  BOOL black = YES;
  while (start < width - 1 && transitions < 8) {
    start++;
    BOOL newBlack = [image getX:start y:y];
    if (black != newBlack) {
      transitions++;
    }
    black = newBlack;
  }
  if (start == width - 1) {
    return -1;
  }
  return start;
}

- (int)findPatternEnd:(int)x y:(int)y image:(ZXBitMatrix *)image {
  int width = image.width;
  int end = width - 1;

  while (end > x && ![image getX:end y:y]) {
    end--;
  }
  int transitions = 0;
  BOOL black = YES;
  while (end > x && transitions < 9) {
    end--;
    BOOL newBlack = [image getX:end y:y];
    if (black != newBlack) {
      transitions++;
    }
    black = newBlack;
  }

  if (end == x) {
    return -1;
  }
  return end;
}

@end
