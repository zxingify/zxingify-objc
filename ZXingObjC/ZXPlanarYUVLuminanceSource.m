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

const int THUMBNAIL_SCALE_FACTOR = 2;

@interface ZXPlanarYUVLuminanceSource ()

- (void)reverseHorizontal:(int)width height:(int)height;

@end

@implementation ZXPlanarYUVLuminanceSource {
  unsigned char *yuvData;
  int yuvDataLen;
  int dataWidth;
  int dataHeight;
  int left;
  int top;
}

- (id)initWithYuvData:(unsigned char *)_yuvData yuvDataLen:(int)_yuvDataLen dataWidth:(int)_dataWidth
           dataHeight:(int)_dataHeight left:(int)_left top:(int)_top width:(int)_width height:(int)_height
    reverseHorizontal:(BOOL)_reverseHorizontal {
  if (self = [super initWithWidth:_width height:_height]) {
    if (_left + _width > _dataWidth || _top + _height > _dataHeight) {
      [NSException raise:NSInvalidArgumentException
                  format:@"Crop rectangle does not fit within image data."];

    }

    yuvDataLen = _yuvDataLen;
    yuvData = (unsigned char *)malloc(_yuvDataLen * sizeof(unsigned char));
    memcpy(yuvData, _yuvData, _yuvDataLen);
    dataWidth = _dataWidth;
    dataHeight = _dataHeight;
    left = _left;
    top = _top;
    if (_reverseHorizontal) {
      [self reverseHorizontal:_width height:_height];
    }
  }

  return self;
}

- (void)dealloc {
  if (yuvData != NULL) {
    free(yuvData);
    yuvData = NULL;
  }

  [super dealloc];
}

- (unsigned char *)row:(int)y {
  if (y < 0 || y >= self.height) {
    [NSException raise:NSInvalidArgumentException
                format:@"Requested row is outside the image: %d", y];
  }
  unsigned char *row = (unsigned char *)malloc(self.width * sizeof(unsigned char));
  int offset = (y + top) * dataWidth + left;
  memcpy(row, yuvData + offset, self.width);
  return row;
}

- (unsigned char *)matrix {
  int area = width * height;
  unsigned char *matrix = malloc(area * sizeof(unsigned char));
  int inputOffset = top * dataWidth + left;

  // If the width matches the full width of the underlying data, perform a single copy.
  if (width == dataWidth) {
    memcpy(matrix, yuvData + inputOffset, area - inputOffset);
    return matrix;
  }

  // Otherwise copy one cropped row at a time.
  for (int y = 0; y < height; y++) {
    int outputOffset = y * width;
    memcpy(matrix + outputOffset, yuvData + inputOffset, self.width);
    inputOffset += dataWidth;
  }
  return matrix;
}

- (BOOL)cropSupported {
  return YES;
}

- (ZXLuminanceSource *)crop:(int)_left top:(int)_top width:(int)_width height:(int)_height {
  return [[[self class] alloc] initWithYuvData:yuvData yuvDataLen:yuvDataLen dataWidth:dataWidth
                                    dataHeight:dataHeight left:left + _left top:top + _top
                                         width:_width height:_height reverseHorizontal:NO];
}

- (int *)renderThumbnail {
  int thumbWidth = self.width / THUMBNAIL_SCALE_FACTOR;
  int thumbHeight = self.height / THUMBNAIL_SCALE_FACTOR;
  int *pixels = (int *)malloc(thumbWidth * thumbHeight * sizeof(int));
  int inputOffset = top * dataWidth + left;

  for (int y = 0; y < height; y++) {
    int outputOffset = y * width;
    for (int x = 0; x < width; x++) {
      int grey = yuvData[inputOffset + x * THUMBNAIL_SCALE_FACTOR] & 0xff;
      pixels[outputOffset + x] = 0xFF000000 | (grey * 0x00010101);
    }
    inputOffset += dataWidth * THUMBNAIL_SCALE_FACTOR;
  }
  return pixels;
}

- (int)thumbnailWidth {
  return self.width / THUMBNAIL_SCALE_FACTOR;
}

- (int)thumbnailHeight {
  return self.height / THUMBNAIL_SCALE_FACTOR;
}

- (void)reverseHorizontal:(int)_width height:(int)_height {
  for (int y = 0, rowStart = top * dataWidth + left; y < _height; y++, rowStart += dataWidth) {
    int middle = rowStart + _width / 2;
    for (int x1 = rowStart, x2 = rowStart + _width - 1; x1 < middle; x1++, x2--) {
      unsigned char temp = yuvData[x1];
      yuvData[x1] = yuvData[x2];
      yuvData[x2] = temp;
    }
  }
}

@end
