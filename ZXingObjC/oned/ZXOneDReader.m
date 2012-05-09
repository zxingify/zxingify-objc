#import "ZXBinaryBitmap.h"
#import "ZXBitArray.h"
#import "ZXDecodeHints.h"
#import "ZXFormatException.h"
#import "ZXNotFoundException.h"
#import "ZXOneDReader.h"
#import "ZXResult.h"
#import "ZXResultPoint.h"

int const INTEGER_MATH_SHIFT = 8;
int const PATTERN_MATCH_RESULT_SCALE_FACTOR = 1 << INTEGER_MATH_SHIFT;

@interface ZXOneDReader ()

- (ZXResult *)doDecode:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints;

@end

@implementation ZXOneDReader

- (ZXResult *)decode:(ZXBinaryBitmap *)image {
  return [self decode:image hints:nil];
}

- (ZXResult *)decode:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints {
  @try {
    return [self doDecode:image hints:hints];
  } @catch (ZXNotFoundException * nfe) {
    BOOL tryHarder = hints != nil && hints.tryHarder;
    if (tryHarder && [image rotateSupported]) {
      ZXBinaryBitmap * rotatedImage = [image rotateCounterClockwise];
      ZXResult * result = [self doDecode:rotatedImage hints:hints];
      NSMutableDictionary * metadata = [result resultMetadata];
      int orientation = 270;
      if (metadata != nil && [metadata objectForKey:[NSNumber numberWithInt:kResultMetadataTypeOrientation]]) {
        orientation = (orientation + [((NSNumber *)[metadata objectForKey:[NSNumber numberWithInt:kResultMetadataTypeOrientation]]) intValue]) % 360;
      }
      [result putMetadata:kResultMetadataTypeOrientation value:[NSNumber numberWithInt:orientation]];
      NSMutableArray * points = [result resultPoints];
      int height = [rotatedImage height];

      for (int i = 0; i < [points count]; i++) {
        [points replaceObjectAtIndex:i
                          withObject:[[[ZXResultPoint alloc] initWithX:height - [(ZXResultPoint*)[points objectAtIndex:i] y]             
                                                                     y:[(ZXResultPoint*)[points objectAtIndex:i] x]]
                                      autorelease]];
      }

      return result;
    } else {
      @throw nfe;
    }
  }
}

- (void)reset {
  
}


/**
 * We're going to examine rows from the middle outward, searching alternately above and below the
 * middle, and farther out each time. rowStep is the number of rows between each successive
 * attempt above and below the middle. So we'd scan row middle, then middle - rowStep, then
 * middle + rowStep, then middle - (2 * rowStep), etc.
 * rowStep is bigger as the image is taller, but is always at least 1. We've somewhat arbitrarily
 * decided that moving up and down by about 1/16 of the image is pretty good; we try more of the
 * image if "trying harder".
 */
- (ZXResult *)doDecode:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints {
  int width = image.width;
  int height = image.height;
  ZXBitArray * row = [[[ZXBitArray alloc] initWithSize:width] autorelease];
  int middle = height >> 1;
  BOOL tryHarder = hints != nil && hints.tryHarder;
  int rowStep = MAX(1, height >> (tryHarder ? 8 : 5));
  int maxLines;
  if (tryHarder) {
    maxLines = height;
  } else {
    maxLines = 15;
  }

  for (int x = 0; x < maxLines; x++) {
    int rowStepsAboveOrBelow = (x + 1) >> 1;
    BOOL isAbove = (x & 0x01) == 0;
    int rowNumber = middle + rowStep * (isAbove ? rowStepsAboveOrBelow : -rowStepsAboveOrBelow);
    if (rowNumber < 0 || rowNumber >= height) {
      break;
    }

    @try {
      row = [image blackRow:rowNumber row:row];
    } @catch (ZXNotFoundException * nfe) {
      continue;
    }

    for (int attempt = 0; attempt < 2; attempt++) {
      if (attempt == 1) {
        [row reverse];
        if (hints != nil && hints.resultPointCallback) {
          hints = [[hints copy] autorelease];
          hints.resultPointCallback = nil;
        }
      }

      @try {
        ZXResult * result = [self decodeRow:rowNumber row:row hints:hints];
        if (attempt == 1) {
          [result putMetadata:kResultMetadataTypeOrientation value:[NSNumber numberWithInt:180]];
          NSMutableArray * points = [result resultPoints];
          [points replaceObjectAtIndex:0
                            withObject:[[[ZXResultPoint alloc] initWithX:width - [(ZXResultPoint*)[points objectAtIndex:0] x]
                                                                       y:[(ZXResultPoint*)[points objectAtIndex:0] y]]
                                        autorelease]];
          [points replaceObjectAtIndex:1
                            withObject:[[[ZXResultPoint alloc] initWithX:width - [(ZXResultPoint*)[points objectAtIndex:1] x]
                                                                       y:[(ZXResultPoint*)[points objectAtIndex:1] y]]
                                        autorelease]];
        }
        return result;
      }
      @catch (ZXReaderException * re) {
      }
    }
  }

  @throw [ZXNotFoundException notFoundInstance];
}


/**
 * Records the size of successive runs of white and black pixels in a row, starting at a given point.
 * The values are recorded in the given array, and the number of runs recorded is equal to the size
 * of the array. If the row starts on a white pixel at the given start point, then the first count
 * recorded is the run of white pixels starting from that point; likewise it is the count of a run
 * of black pixels if the row begin on a black pixels at that point.
 */
+ (void)recordPattern:(ZXBitArray *)row start:(int)start counters:(int[])counters countersSize:(int)countersSize {
  int numCounters = countersSize;

  for (int i = 0; i < numCounters; i++) {
    counters[i] = 0;
  }

  int end = row.size;
  if (start >= end) {
    @throw [ZXNotFoundException notFoundInstance];
  }
  BOOL isWhite = ![row get:start];
  int counterPosition = 0;
  int i = start;

  while (i < end) {
    BOOL pixel = [row get:i];
    if (pixel ^ isWhite) {
      counters[counterPosition]++;
    } else {
      counterPosition++;
      if (counterPosition == numCounters) {
        break;
      } else {
        counters[counterPosition] = 1;
        isWhite = !isWhite;
      }
    }
    i++;
  }

  if (!(counterPosition == numCounters || (counterPosition == numCounters - 1 && i == end))) {
    @throw [ZXNotFoundException notFoundInstance];
  }
}

+ (void)recordPatternInReverse:(ZXBitArray *)row start:(int)start counters:(int[])counters countersSize:(int)countersSize {
  int numTransitionsLeft = countersSize;
  BOOL last = [row get:start];

  while (start > 0 && numTransitionsLeft >= 0) {
    if ([row get:--start] != last) {
      numTransitionsLeft--;
      last = !last;
    }
  }

  if (numTransitionsLeft >= 0) {
    @throw [ZXNotFoundException notFoundInstance];
  }
  [self recordPattern:row start:start + 1 counters:counters countersSize:countersSize];
}


/**
 * Determines how closely a set of observed counts of runs of black/white values matches a given
 * target pattern. This is reported as the ratio of the total variance from the expected pattern
 * proportions across all pattern elements, to the length of the pattern.
 * 
 * Returns ratio of total variance between counters and pattern compared to total pattern size,
 * where the ratio has been multiplied by 256. So, 0 means no variance (perfect match); 256 means
 * the total variance between counters and patterns equals the pattern length, higher values mean
 * even more variance
 */
+ (int)patternMatchVariance:(int[])counters countersSize:(int)countersSize pattern:(int[])pattern maxIndividualVariance:(int)maxIndividualVariance {
  int numCounters = countersSize;
  int total = 0;
  int patternLength = 0;

  for (int i = 0; i < numCounters; i++) {
    total += counters[i];
    patternLength += pattern[i];
  }

  if (total < patternLength) {
    return NSIntegerMax;
  }
  int unitBarWidth = (total << INTEGER_MATH_SHIFT) / patternLength;
  maxIndividualVariance = (maxIndividualVariance * unitBarWidth) >> INTEGER_MATH_SHIFT;
  int totalVariance = 0;

  for (int x = 0; x < numCounters; x++) {
    int counter = counters[x] << INTEGER_MATH_SHIFT;
    int scaledPattern = pattern[x] * unitBarWidth;
    int variance = counter > scaledPattern ? counter - scaledPattern : scaledPattern - counter;
    if (variance > maxIndividualVariance) {
      return NSIntegerMax;
    }
    totalVariance += variance;
  }

  return totalVariance / total;
}


/**
 * Attempts to decode a one-dimensional barcode format given a single row of
 * an image.
 */
- (ZXResult *)decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(ZXDecodeHints *)hints {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

@end
