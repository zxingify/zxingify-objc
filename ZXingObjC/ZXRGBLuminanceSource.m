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

#import "ZXRGBLuminanceSource.h"

@interface ZXRGBLuminanceSource ()

@property (nonatomic, assign) unsigned char *luminances;
@property (nonatomic, assign) int luminancesCount;
@property (nonatomic, assign) int dataWidth;
@property (nonatomic, assign) int dataHeight;
@property (nonatomic, assign) int left;
@property (nonatomic, assign) int top;

@end

@implementation ZXRGBLuminanceSource

@synthesize luminances;
@synthesize luminancesCount;
@synthesize dataWidth;
@synthesize dataHeight;
@synthesize left;
@synthesize top;

- (id)initWithWidth:(int)aWidth height:(int)aHeight pixels:(int *)pixels pixelsLen:(int)pixelsLen {
  if (self = [super initWithWidth:aWidth height:aHeight]) {
    self.dataWidth = self.width;
    self.dataHeight = self.height;
    self.left = 0;
    self.top = 0;

    // In order to measure pure decoding speed, we convert the entire image to a greyscale array
    // up front, which is the same as the Y channel of the YUVLuminanceSource in the real app.
    self.luminancesCount = self.width * self.height;
    self.luminances = (unsigned char *)malloc(self.luminancesCount * sizeof(unsigned char));
    for (int y = 0; y < self.height; y++) {
      int offset = y * self.width;
      for (int x = 0; x < self.width; x++) {
        int pixel = pixels[offset + x];
        int r = (pixel >> 16) & 0xff;
        int g = (pixel >> 8) & 0xff;
        int b = pixel & 0xff;
        if (r == g && g == b) {
          // Image is already greyscale, so pick any channel.
          self.luminances[offset + x] = (char) r;
        } else {
          // Calculate luminance cheaply, favoring green.
          self.luminances[offset + x] = (char) ((r + g + g + b) >> 2);
        }
      }
    }
  }

  return self;
}

- (id)initWithPixels:(unsigned char *)pixels pixelsLen:(int)pixelsLen dataWidth:(int)aDataWidth dataHeight:(int)aDataHeight
                left:(int)aLeft top:(int)aTop width:(int)aWidth height:(int)aHeight {
  if (self = [super initWithWidth:aWidth height:aHeight]) {
    if (aLeft + self.width > aDataWidth || aTop + self.height > aDataHeight) {
      [NSException raise:NSInvalidArgumentException
                  format:@"Crop rectangle does not fit within image data."];

    }

    self.luminancesCount = pixelsLen;
    self.luminances = (unsigned char *)malloc(pixelsLen * sizeof(unsigned char));
    memcpy(self.luminances, pixels, pixelsLen * sizeof(char));

    self.dataWidth = aDataWidth;
    self.dataHeight = aDataHeight;
    self.left = aLeft;
    self.top = aTop;
  }

  return self;
}

- (unsigned char *)row:(int)y {
  if (y < 0 || y >= self.height) {
    [NSException raise:NSInvalidArgumentException
                format:@"Requested row is outside the image: %d", y];
  }
  unsigned char *row = (unsigned char *)malloc(self.width * sizeof(unsigned char));

  int offset = (y + self.top) * self.dataWidth + self.left;
  memcpy(row, self.luminances + offset, self.width);
  return row;
}

- (unsigned char *)matrix {
  int area = self.width * self.height;
  unsigned char *matrix = (unsigned char *)malloc(area * sizeof(unsigned char));
  int inputOffset = self.top * self.dataWidth + self.left;

  // If the width matches the full width of the underlying data, perform a single copy.
  if (self.width == self.dataWidth) {
    memcpy(matrix, self.luminances + inputOffset, area - inputOffset);
    return matrix;
  }

  // Otherwise copy one cropped row at a time.
  for (int y = 0; y < self.height; y++) {
    int outputOffset = y * self.width;
    memcpy(matrix + outputOffset, self.luminances + inputOffset, self.width);
    inputOffset += self.dataWidth;
  }
  return matrix;
}

- (BOOL)cropSupported {
  return YES;
}

- (ZXLuminanceSource *)crop:(int)aLeft top:(int)aTop width:(int)aWidth height:(int)aHeight {
  return [[[[self class] alloc] initWithPixels:self.luminances
                                     pixelsLen:self.luminancesCount
                                     dataWidth:self.dataWidth
                                    dataHeight:self.dataHeight
                                          left:self.left + aLeft
                                           top:self.top + aTop
                                         width:aWidth
                                        height:aHeight] autorelease];
}

@end
