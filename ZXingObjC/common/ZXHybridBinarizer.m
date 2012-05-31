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

#import "ZXHybridBinarizer.h"

// This class uses 5x5 blocks to compute local luminance, where each block is 8x8 pixels.
// So this is the smallest dimension in each axis we can accept.
const int BLOCK_SIZE_POWER = 3;
const int BLOCK_SIZE = 1 << BLOCK_SIZE_POWER;
const int BLOCK_SIZE_MASK = BLOCK_SIZE - 1;
const int MINIMUM_DIMENSION = BLOCK_SIZE * 5;

@interface ZXHybridBinarizer ()

@property (nonatomic, retain) ZXBitMatrix * matrix;

- (NSArray *)calculateBlackPoints:(unsigned char *)luminances subWidth:(int)subWidth subHeight:(int)subHeight width:(int)width height:(int)height;
- (void)calculateThresholdForBlock:(unsigned char *)luminances subWidth:(int)subWidth subHeight:(int)subHeight width:(int)width height:(int)height blackPoints:(NSArray *)blackPoints matrix:(ZXBitMatrix *)matrix;
- (void)threshold8x8Block:(unsigned char *)luminances xoffset:(int)xoffset yoffset:(int)yoffset threshold:(int)threshold stride:(int)stride matrix:(ZXBitMatrix *)matrix;

@end

@implementation ZXHybridBinarizer

@synthesize matrix;

- (id)initWithSource:(ZXLuminanceSource *)aSource {
  if (self = [super initWithSource:aSource]) {
    self.matrix = nil;
  }

  return self;
}

- (void)dealloc {
  [matrix release];

  [super dealloc];
}

- (ZXBitMatrix *)blackMatrixWithError:(NSError **)error {
  // Calculates the final BitMatrix once for all requests. This could be called once from the
  // constructor instead, but there are some advantages to doing it lazily, such as making
  // profiling easier, and not doing heavy lifting when callers don't expect it.
  if (self.matrix != nil) {
    return self.matrix;
  }
  ZXLuminanceSource * source = [self luminanceSource];
  if ([source width] >= MINIMUM_DIMENSION && [source height] >= MINIMUM_DIMENSION) {
    unsigned char * _luminances = source.matrix;
    int width = source.width;
    int height = source.height;
    int subWidth = width >> BLOCK_SIZE_POWER;
    if ((width & BLOCK_SIZE_MASK) != 0) {
      subWidth++;
    }
    int subHeight = height >> BLOCK_SIZE_POWER;
    if ((height & BLOCK_SIZE_MASK) != 0) {
      subHeight++;
    }
    NSArray * blackPoints = [self calculateBlackPoints:_luminances subWidth:subWidth subHeight:subHeight width:width height:height];

    ZXBitMatrix * newMatrix = [[[ZXBitMatrix alloc] initWithWidth:width height:height] autorelease];
    [self calculateThresholdForBlock:_luminances subWidth:subWidth subHeight:subHeight width:width height:height blackPoints:blackPoints matrix:newMatrix];
    self.matrix = newMatrix;
  } else {
    // If the image is too small, fall back to the global histogram approach.
    self.matrix = [super blackMatrixWithError:error];
  }
  return self.matrix;
}

- (ZXBinarizer *)createBinarizer:(ZXLuminanceSource *)source {
  return [[[ZXHybridBinarizer alloc] initWithSource:source] autorelease];
}

// For each 8x8 block in the image, calculate the average black point using a 5x5 grid
// of the blocks around it. Also handles the corner cases (fractional blocks are computed based
// on the last 8 pixels in the row/column which are also used in the previous block).
- (void)calculateThresholdForBlock:(unsigned char *)_luminances
                          subWidth:(int)subWidth
                         subHeight:(int)subHeight
                             width:(int)width
                            height:(int)height
                       blackPoints:(NSArray *)blackPoints
                            matrix:(ZXBitMatrix *)_matrix {
  for (int y = 0; y < subHeight; y++) {
    int yoffset = y << BLOCK_SIZE_POWER;
    if ((yoffset + BLOCK_SIZE) >= height) {
      yoffset = height - BLOCK_SIZE;
    }
    for (int x = 0; x < subWidth; x++) {
      int xoffset = x << BLOCK_SIZE_POWER;
      if ((xoffset + BLOCK_SIZE) >= width) {
        xoffset = width - BLOCK_SIZE;
      }
      int left = x > 1 ? x : 2;
      left = left < subWidth - 2 ? left : subWidth - 3;
      int top = y > 1 ? y : 2;
      top = top < subHeight - 2 ? top : subHeight - 3;
      int sum = 0;
      for (int z = -2; z <= 2; z++) {
        NSArray * blackRow = [blackPoints objectAtIndex:top + z];
        sum += [[blackRow objectAtIndex:left - 2] intValue] +
               [[blackRow objectAtIndex:left - 1] intValue] +
               [[blackRow objectAtIndex:left] intValue] +
               [[blackRow objectAtIndex:left + 1] intValue] +
               [[blackRow objectAtIndex:left + 2] intValue];
      }
      int average = sum / 25;
      [self threshold8x8Block:_luminances xoffset:xoffset yoffset:yoffset threshold:average stride:width matrix:_matrix];
    }
  }
}

// Applies a single threshold to an 8x8 block of pixels.
- (void)threshold8x8Block:(unsigned char *)_luminances
                  xoffset:(int)xoffset yoffset:(int)yoffset
                threshold:(int)threshold
                   stride:(int)stride
                   matrix:(ZXBitMatrix *)_matrix {
  for (int y = 0, offset = yoffset * stride + xoffset; y < BLOCK_SIZE; y++, offset += stride) {
    for (int x = 0; x < BLOCK_SIZE; x++) {
      if ((_luminances[offset + x] & 0xFF) < threshold) {
        [_matrix setX:xoffset + x y:yoffset + y];
      }
    }
  }
}

// Calculates a single black point for each 8x8 block of pixels and saves it away.
- (NSArray *)calculateBlackPoints:(unsigned char *)_luminances
                         subWidth:(int)subWidth
                        subHeight:(int)subHeight
                            width:(int)width
                           height:(int)height {
  NSMutableArray * blackPoints = [NSMutableArray arrayWithCapacity:subHeight];

  for (int y = 0; y < subHeight; y++) {
    int yoffset = y << BLOCK_SIZE_POWER;
    if ((yoffset + BLOCK_SIZE) >= height) {
      yoffset = height - BLOCK_SIZE;
    }

    [blackPoints addObject:[NSMutableArray arrayWithCapacity:subWidth]];
    for (int x = 0; x < subWidth; x++) {
      int xoffset = x << BLOCK_SIZE_POWER;
      if ((xoffset + BLOCK_SIZE) >= width) {
        xoffset = width - BLOCK_SIZE;
      }
      int sum = 0;
      int min = 0xFF;
      int max = 0;
      for (int yy = 0, offset = yoffset * width + xoffset; yy < BLOCK_SIZE; yy++, offset += width) {
        for (int xx = 0; xx < BLOCK_SIZE; xx++) {
          int pixel = _luminances[offset + xx] & 0xff;
          sum += pixel;
          if (pixel < min) {
            min = pixel;
          }
          if (pixel > max) {
            max = pixel;
          }
        }
      }

      int average;
      if (max - min > 24) {
        average = sum >> 6;
      } else {
        average = max == 0 ? 1 : min >> 1;
      }
      [[blackPoints objectAtIndex:y] addObject:[NSNumber numberWithInt:average]];
    }
  }

  return blackPoints;
}

@end
