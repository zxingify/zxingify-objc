#import "GlobalHistogramBinarizer.h"

int const LUMINANCE_BITS = 5;
int const LUMINANCE_SHIFT = 8 - LUMINANCE_BITS;
int const LUMINANCE_BUCKETS = 1 << LUMINANCE_BITS;

@implementation GlobalHistogramBinarizer

@synthesize blackMatrix;

- (id) initWithSource:(LuminanceSource *)source {
  if (self = [super init:source]) {
    luminances = nil;
    buckets = nil;
  }
  return self;
}

- (BitArray *) getBlackRow:(int)y row:(BitArray *)row {
  LuminanceSource * source = [self luminanceSource];
  int width = [source width];
  if (row == nil || [row size] < width) {
    row = [[[BitArray alloc] init:width] autorelease];
  }
   else {
    [row clear];
  }
  [self initArrays:width];
  NSArray * localLuminances = [source getRow:y param1:luminances];
  NSArray * localBuckets = buckets;

  for (int x = 0; x < width; x++) {
    int pixel = localLuminances[x] & 0xff;
    localBuckets[pixel >> LUMINANCE_SHIFT]++;
  }

  int blackPoint = [self estimateBlackPoint:localBuckets];
  int left = localLuminances[0] & 0xff;
  int center = localLuminances[1] & 0xff;

  for (int x = 1; x < width - 1; x++) {
    int right = localLuminances[x + 1] & 0xff;
    int luminance = ((center << 2) - left - right) >> 1;
    if (luminance < blackPoint) {
      [row set:x];
    }
    left = center;
    center = right;
  }

  return row;
}

- (BitMatrix *) blackMatrix {
  LuminanceSource * source = [self luminanceSource];
  int width = [source width];
  int height = [source height];
  BitMatrix * matrix = [[[BitMatrix alloc] init:width param1:height] autorelease];
  [self initArrays:width];
  NSArray * localBuckets = buckets;

  for (int y = 1; y < 5; y++) {
    int row = height * y / 5;
    NSArray * localLuminances = [source getRow:row param1:luminances];
    int right = (width << 2) / 5;

    for (int x = width / 5; x < right; x++) {
      int pixel = localLuminances[x] & 0xff;
      localBuckets[pixel >> LUMINANCE_SHIFT]++;
    }

  }

  int blackPoint = [self estimateBlackPoint:localBuckets];
  NSArray * localLuminances = [source matrix];

  for (int y = 0; y < height; y++) {
    int offset = y * width;

    for (int x = 0; x < width; x++) {
      int pixel = localLuminances[offset + x] & 0xff;
      if (pixel < blackPoint) {
        [matrix set:x param1:y];
      }
    }

  }

  return matrix;
}

- (Binarizer *) createBinarizer:(LuminanceSource *)source {
  return [[[GlobalHistogramBinarizer alloc] init:source] autorelease];
}

- (void) initArrays:(int)luminanceSize {
  if (luminances == nil || luminances.length < luminanceSize) {
    luminances = [NSArray array];
  }
  if (buckets == nil) {
    buckets = [NSArray array];
  }
   else {

    for (int x = 0; x < LUMINANCE_BUCKETS; x++) {
      buckets[x] = 0;
    }

  }
}

+ (int) estimateBlackPoint:(NSArray *)buckets {
  int numBuckets = buckets.length;
  int maxBucketCount = 0;
  int firstPeak = 0;
  int firstPeakSize = 0;

  for (int x = 0; x < numBuckets; x++) {
    if (buckets[x] > firstPeakSize) {
      firstPeak = x;
      firstPeakSize = buckets[x];
    }
    if (buckets[x] > maxBucketCount) {
      maxBucketCount = buckets[x];
    }
  }

  int secondPeak = 0;
  int secondPeakScore = 0;

  for (int x = 0; x < numBuckets; x++) {
    int distanceToBiggest = x - firstPeak;
    int score = buckets[x] * distanceToBiggest * distanceToBiggest;
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
    @throw [NotFoundException notFoundInstance];
  }
  int bestValley = secondPeak - 1;
  int bestValleyScore = -1;

  for (int x = secondPeak - 1; x > firstPeak; x--) {
    int fromFirst = x - firstPeak;
    int score = fromFirst * fromFirst * (secondPeak - x) * (maxBucketCount - buckets[x]);
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
