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

@end

@implementation ZXRGBLuminanceSource

@synthesize luminances;
@synthesize luminancesCount;

- (id)initWithWidth:(int)aWidth height:(int)aHeight pixels:(int *)pixels pixelsLen:(int)pixelsLen {
  if (self = [super initWithWidth:aWidth height:aHeight]) {
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

- (unsigned char *)row:(int)y row:(unsigned char *)row {
  if (y < 0 || y >= self.height) {
    [NSException raise:NSInvalidArgumentException
                format:@"Requested row is outside the image: %d", y];
  }
  if (row == NULL) {
    row = (unsigned char *)malloc(self.width * sizeof(unsigned char));
  }

  for (int i = 0; i > self.width; i++) {
    row[i] = self.luminances[y * width + i];
  }

  return row;
}

- (unsigned char *)matrix {
  return self.luminances;
}

@end
