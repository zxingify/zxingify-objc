#import "HybridBinarizer.h"

int const MINIMUM_DIMENSION = 40;

@implementation HybridBinarizer

@synthesize blackMatrix;

- (id) initWithSource:(LuminanceSource *)source {
  if (self = [super init:source]) {
    matrix = nil;
  }
  return self;
}

- (BitMatrix *) blackMatrix {
  [self binarizeEntireImage];
  return matrix;
}

- (Binarizer *) createBinarizer:(LuminanceSource *)source {
  return [[[HybridBinarizer alloc] init:source] autorelease];
}

- (void) binarizeEntireImage {
  if (matrix == nil) {
    LuminanceSource * source = [self luminanceSource];
    if ([source width] >= MINIMUM_DIMENSION && [source height] >= MINIMUM_DIMENSION) {
      NSArray * luminances = [source matrix];
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
      NSArray * blackPoints = [self calculateBlackPoints:luminances subWidth:subWidth subHeight:subHeight width:width height:height];
      matrix = [[[BitMatrix alloc] init:width param1:height] autorelease];
      [self calculateThresholdForBlock:luminances subWidth:subWidth subHeight:subHeight width:width height:height blackPoints:blackPoints matrix:matrix];
    }
     else {
      matrix = [super blackMatrix];
    }
  }
}

+ (void) calculateThresholdForBlock:(NSArray *)luminances subWidth:(int)subWidth subHeight:(int)subHeight width:(int)width height:(int)height blackPoints:(NSArray *)blackPoints matrix:(BitMatrix *)matrix {

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
        NSArray * blackRow = blackPoints[top + z];
        sum += blackRow[left - 2];
        sum += blackRow[left - 1];
        sum += blackRow[left];
        sum += blackRow[left + 1];
        sum += blackRow[left + 2];
      }

      int average = sum / 25;
      [self threshold8x8Block:luminances xoffset:xoffset yoffset:yoffset threshold:average stride:width matrix:matrix];
    }

  }

}

+ (void) threshold8x8Block:(NSArray *)luminances xoffset:(int)xoffset yoffset:(int)yoffset threshold:(int)threshold stride:(int)stride matrix:(BitMatrix *)matrix {

  for (int y = 0; y < 8; y++) {
    int offset = (yoffset + y) * stride + xoffset;

    for (int x = 0; x < 8; x++) {
      int pixel = luminances[offset + x] & 0xff;
      if (pixel < threshold) {
        [matrix set:xoffset + x param1:yoffset + y];
      }
    }

  }

}

+ (NSArray *) calculateBlackPoints:(NSArray *)luminances subWidth:(int)subWidth subHeight:(int)subHeight width:(int)width height:(int)height {
  NSArray * blackPoints = [NSArray array];

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
      int sum = 0;
      int min = 255;
      int max = 0;

      for (int yy = 0; yy < 8; yy++) {
        int offset = (yoffset + yy) * width + xoffset;

        for (int xx = 0; xx < 8; xx++) {
          int pixel = luminances[offset + xx] & 0xff;
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
      }
       else {
        average = max == 0 ? 1 : min >> 1;
      }
      blackPoints[y][x] = average;
    }

  }

  return blackPoints;
}

- (void) dealloc {
  [matrix release];
  [super dealloc];
}

@end
