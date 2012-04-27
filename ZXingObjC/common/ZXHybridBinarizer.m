#import "ZXHybridBinarizer.h"

int const MINIMUM_DIMENSION = 40;

@interface ZXHybridBinarizer ()

- (void) binarizeEntireImage;
- (NSArray *) calculateBlackPoints:(unsigned char *)luminances subWidth:(int)subWidth subHeight:(int)subHeight width:(int)width height:(int)height;
- (void) calculateThresholdForBlock:(unsigned char *)luminances subWidth:(int)subWidth subHeight:(int)subHeight width:(int)width height:(int)height blackPoints:(NSArray *)blackPoints matrix:(ZXBitMatrix *)matrix;
- (void) threshold8x8Block:(unsigned char *)luminances xoffset:(int)xoffset yoffset:(int)yoffset threshold:(int)threshold stride:(int)stride matrix:(ZXBitMatrix *)matrix;

@end

@implementation ZXHybridBinarizer

@synthesize blackMatrix;

- (id) initWithSource:(ZXLuminanceSource *)aSource {
  if (self = [super initWithSource:aSource]) {
    matrix = nil;
  }
  return self;
}

- (ZXBitMatrix *) blackMatrix {
  [self binarizeEntireImage];
  return matrix;
}

- (ZXBinarizer *) createBinarizer:(ZXLuminanceSource *)source {
  return [[[ZXHybridBinarizer alloc] initWithSource:source] autorelease];
}

// Calculates the final BitMatrix once for all requests. This could be called once from the
// constructor instead, but there are some advantages to doing it lazily, such as making
// profiling easier, and not doing heavy lifting when callers don't expect it.
- (void) binarizeEntireImage {
  if (matrix == nil) {
    ZXLuminanceSource * source = [self luminanceSource];
    if ([source width] >= MINIMUM_DIMENSION && [source height] >= MINIMUM_DIMENSION) {
      unsigned char * _luminances = [source matrix];
      int width = [source width];
      int height = [source height];
      int subWidth = width >> 3;
      if ((width & 0x07) != 0) {
        subWidth++;
      }
      int subHeight = height >> 3;
      if ((height & 0x07) != 0) {
        subHeight++;
      }
      NSArray * blackPoints = [self calculateBlackPoints:_luminances subWidth:subWidth subHeight:subHeight width:width height:height];
      matrix = [[[ZXBitMatrix alloc] initWithWidth:width height:height] autorelease];
      [self calculateThresholdForBlock:_luminances subWidth:subWidth subHeight:subHeight width:width height:height blackPoints:blackPoints matrix:matrix];

      if (_luminances) {
        free(_luminances);
        _luminances = NULL;
      }
    } else {
      matrix = [super blackMatrix];
    }
  }
}

// For each 8x8 block in the image, calculate the average black point using a 5x5 grid
// of the blocks around it. Also handles the corner cases (fractional blocks are computed based
// on the last 8 pixels in the row/column which are also used in the previous block).
- (void) calculateThresholdForBlock:(unsigned char *)_luminances subWidth:(int)subWidth subHeight:(int)subHeight width:(int)width height:(int)height blackPoints:(NSArray *)blackPoints matrix:(ZXBitMatrix *)_matrix {
  for (int y = 0; y < subHeight; y++) {
    int yoffset = y << 3;
    if ((yoffset + 8) >= height) {
      yoffset = height - 8;
    }
    for (int x = 0; x < subWidth; x++) {
      int xoffset = x << 3;
      if ((xoffset + 8) >= width) {
        xoffset = width - 8;
      }
      int left = x > 1 ? x : 2;
      left = left < subWidth - 2 ? left : subWidth - 3;
      int top = y > 1 ? y : 2;
      top = top < subHeight - 2 ? top : subHeight - 3;
      int sum = 0;
      for (int z = -2; z <= 2; z++) {
        NSArray * blackRow = [blackPoints objectAtIndex:top + z];
        sum += [[blackRow objectAtIndex:left - 2] intValue];
        sum += [[blackRow objectAtIndex:left - 1] intValue];
        sum += [[blackRow objectAtIndex:left] intValue];
        sum += [[blackRow objectAtIndex:left + 1] intValue];
        sum += [[blackRow objectAtIndex:left + 2] intValue];
      }
      int average = sum / 25;
      [self threshold8x8Block:_luminances xoffset:xoffset yoffset:yoffset threshold:average stride:width matrix:_matrix];
    }
  }
}

- (void) threshold8x8Block:(unsigned char *)_luminances xoffset:(int)xoffset yoffset:(int)yoffset threshold:(int)threshold stride:(int)stride matrix:(ZXBitMatrix *)_matrix {
  for (int y = 0; y < 8; y++) {
    int offset = (yoffset + y) * stride + xoffset;
    for (int x = 0; x < 8; x++) {
      int pixel = _luminances[offset + x] & 0xff;
      if (pixel < threshold) {
        [_matrix set:xoffset + x y:yoffset + y];
      }
    }
  }
}

- (NSArray *) calculateBlackPoints:(unsigned char *)_luminances subWidth:(int)subWidth subHeight:(int)subHeight width:(int)width height:(int)height {
  NSMutableArray * blackPoints = [NSMutableArray arrayWithCapacity:subHeight];

  for (int y = 0; y < subHeight; y++) {
    int yoffset = y << 3;
    if ((yoffset + 8) >= height) {
      yoffset = height - 8;
    }

    [blackPoints addObject:[NSMutableArray arrayWithCapacity:subWidth]];
    for (int x = 0; x < subWidth; x++) {
      int xoffset = x << 3;
      if ((xoffset + 8) >= width) {
        xoffset = width - 8;
      }
      int sum = 0;
      int min = 255;
      int max = 0;
      for (int yy = 0; yy < 8; yy++) {
        int offset = (yoffset + yy) * width + xoffset;

        for (int xx = 0; xx < 8; xx++) {
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

- (void) dealloc {
  [matrix release];
  [super dealloc];
}

@end
