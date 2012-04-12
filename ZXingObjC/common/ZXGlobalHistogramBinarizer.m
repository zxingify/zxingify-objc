#import "ZXGlobalHistogramBinarizer.h"
#import "ZXBitArray.h"
#import "ZXBitMatrix.h"
#import "ZXLuminanceSource.h"
#import "ZXNotFoundException.h"

int const LUMINANCE_BITS = 5;
int const LUMINANCE_SHIFT = 8 - LUMINANCE_BITS;
int const LUMINANCE_BUCKETS = 1 << LUMINANCE_BITS;

@interface ZXGlobalHistogramBinarizer ()

- (void) initArrays:(int)luminanceSize;
- (int) estimateBlackPoint:(NSArray *)buckets;

@end

@implementation ZXGlobalHistogramBinarizer

@synthesize blackMatrix;

- (id) initWithSource:(ZXLuminanceSource *)source {
  if (self = [super initWithSource:source]) {
    luminances = nil;
    buckets = nil;
  }
  return self;
}

- (ZXBitArray *) getBlackRow:(int)y row:(ZXBitArray *)row {
  ZXLuminanceSource * source = [self luminanceSource];
  int width = [source width];
  if (row == nil || [row size] < width) {
    row = [[[ZXBitArray alloc] initWithSize:width] autorelease];
  }
   else {
    [row clear];
  }
  [self initArrays:width];
  NSArray * localLuminances = [source getRow:y row:luminances];
  NSMutableArray * localBuckets = [NSMutableArray arrayWithArray:buckets];

  for (int x = 0; x < width; x++) {
    int pixel = [[localLuminances objectAtIndex:x] intValue] & 0xff;
    [localBuckets replaceObjectAtIndex:pixel >> LUMINANCE_SHIFT withObject:[NSNumber numberWithInt:[[localBuckets objectAtIndex:pixel >> LUMINANCE_SHIFT] intValue] + 1]];
  }

  int blackPoint = [self estimateBlackPoint:localBuckets];
  int left = [[localLuminances objectAtIndex:0] intValue] & 0xff;
  int center = [[localLuminances objectAtIndex:1] intValue] & 0xff;

  for (int x = 1; x < width - 1; x++) {
    int right = [[localLuminances objectAtIndex:x + 1] intValue] & 0xff;
    int luminance = ((center << 2) - left - right) >> 1;
    if (luminance < blackPoint) {
      [row set:x];
    }
    left = center;
    center = right;
  }

  return row;
}

- (ZXBitMatrix *) blackMatrix {
  ZXLuminanceSource * source = [self luminanceSource];
  int width = [source width];
  int height = [source height];
  ZXBitMatrix * matrix = [[[ZXBitMatrix alloc] initWithWidth:width height:height] autorelease];
  [self initArrays:width];
  NSMutableArray * localBuckets = [NSMutableArray arrayWithArray:buckets];

  for (int y = 1; y < 5; y++) {
    int row = height * y / 5;
    NSArray * localLuminances = [source getRow:row row:luminances];
    int right = (width << 2) / 5;

    for (int x = width / 5; x < right; x++) {
      int pixel = [[localLuminances objectAtIndex:x] intValue] & 0xff;
      [localBuckets replaceObjectAtIndex:pixel >> LUMINANCE_SHIFT withObject:[NSNumber numberWithInt:[[localBuckets objectAtIndex:pixel >> LUMINANCE_SHIFT] intValue] + 1]];
    }

  }

  int blackPoint = [self estimateBlackPoint:localBuckets];
  NSArray * localLuminances = [source matrix];

  for (int y = 0; y < height; y++) {
    int offset = y * width;

    for (int x = 0; x < width; x++) {
      int pixel = [[localLuminances objectAtIndex:offset + x] intValue] & 0xff;
      if (pixel < blackPoint) {
        [matrix set:x y:y];
      }
    }

  }

  return matrix;
}

- (ZXBinarizer *) createBinarizer:(ZXLuminanceSource *)source {
  return [[[ZXGlobalHistogramBinarizer alloc] initWithSource:source] autorelease];
}

- (void) initArrays:(int)luminanceSize {
  if (luminances == nil || [luminances count] < luminanceSize) {
    luminances = [NSArray array];
  }
  if (buckets == nil) {
    buckets = [NSMutableArray arrayWithCapacity:LUMINANCE_BUCKETS];
  }
   else {
    for (int x = 0; x < LUMINANCE_BUCKETS; x++) {
      [buckets addObject:[NSNumber numberWithInt:0]];
    }

  }
}

- (int) estimateBlackPoint:(NSArray *)otherBuckets {
  int numBuckets = [otherBuckets count];
  int maxBucketCount = 0;
  int firstPeak = 0;
  int firstPeakSize = 0;

  for (int x = 0; x < numBuckets; x++) {
    if ([[otherBuckets objectAtIndex:x] intValue] > firstPeakSize) {
      firstPeak = x;
      firstPeakSize = [[otherBuckets objectAtIndex:x] intValue];
    }
    if ([[otherBuckets objectAtIndex:x] intValue] > maxBucketCount) {
      maxBucketCount = [[otherBuckets objectAtIndex:x] intValue];
    }
  }

  int secondPeak = 0;
  int secondPeakScore = 0;

  for (int x = 0; x < numBuckets; x++) {
    int distanceToBiggest = x - firstPeak;
    int score = [[otherBuckets objectAtIndex:x] intValue] * distanceToBiggest * distanceToBiggest;
    if (score > secondPeakScore) {
      secondPeak = x;
      secondPeakScore = score;
    }
  }

  if (firstPeak > secondPeak) {
    int temp = firstPeak;
    firstPeak = secondPeak;
    secondPeak = temp;
  }
  if (secondPeak - firstPeak <= numBuckets >> 4) {
    @throw [ZXNotFoundException notFoundInstance];
  }
  int bestValley = secondPeak - 1;
  int bestValleyScore = -1;

  for (int x = secondPeak - 1; x > firstPeak; x--) {
    int fromFirst = x - firstPeak;
    int score = fromFirst * fromFirst * (secondPeak - x) * (maxBucketCount - [[otherBuckets objectAtIndex:x] intValue]);
    if (score > bestValleyScore) {
      bestValley = x;
      bestValleyScore = score;
    }
  }

  return bestValley << LUMINANCE_SHIFT;
}

- (void) dealloc {
  [luminances release];
  [buckets release];
  [super dealloc];
}

@end
