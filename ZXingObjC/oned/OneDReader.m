#import "OneDReader.h"
#import "BinaryBitmap.h"
#import "ChecksumException.h"
#import "DecodeHintType.h"
#import "FormatException.h"
#import "NotFoundException.h"
#import "ReaderException.h"
#import "Result.h"
#import "ResultMetadataType.h"
#import "ResultPoint.h"
#import "BitArray.h"

@interface OneDReader ()

- (Result *) doDecode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints;

@end

@implementation OneDReader

- (Result *) decode:(BinaryBitmap *)image {
  return [self decode:image hints:nil];
}

- (Result *) decode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints {

  @try {
    return [self doDecode:image hints:hints];
  }
  @catch (NotFoundException * nfe) {
    BOOL tryHarder = hints != nil && [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypeTryHarder]];
    if (tryHarder && [image rotateSupported]) {
      BinaryBitmap * rotatedImage = [image rotateCounterClockwise];
      Result * result = [self doDecode:rotatedImage hints:hints];
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
                          withObject:[[[ResultPoint alloc] initWithX:height - [(ResultPoint*)[points objectAtIndex:i] y]             
                                                                   y:[(ResultPoint*)[points objectAtIndex:i] x]]
                                      autorelease]];
      }

      return result;
    }
     else {
      @throw nfe;
    }
  }
}

- (void) reset {
}


/**
 * We're going to examine rows from the middle outward, searching alternately above and below the
 * middle, and farther out each time. rowStep is the number of rows between each successive
 * attempt above and below the middle. So we'd scan row middle, then middle - rowStep, then
 * middle + rowStep, then middle - (2 * rowStep), etc.
 * rowStep is bigger as the image is taller, but is always at least 1. We've somewhat arbitrarily
 * decided that moving up and down by about 1/16 of the image is pretty good; we try more of the
 * image if "trying harder".
 * 
 * @param image The image to decode
 * @param hints Any hints that were requested
 * @return The contents of the decoded barcode
 * @throws NotFoundException Any spontaneous errors which occur
 */
- (Result *) doDecode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints {
  int width = [image width];
  int height = [image height];
  BitArray * row = [[[BitArray alloc] initWithSize:width] autorelease];
  int middle = height >> 1;
  BOOL tryHarder = hints != nil && [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypeTryHarder]];
  int rowStep = MAX(1, height >> (tryHarder ? 8 : 5));
  int maxLines;
  if (tryHarder) {
    maxLines = height;
  }
   else {
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
      row = [image getBlackRow:rowNumber row:row];
    }
    @catch (NotFoundException * nfe) {
      continue;
    }

    for (int attempt = 0; attempt < 2; attempt++) {
      if (attempt == 1) {
        [row reverse];
        if (hints != nil && [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypeNeedResultPointCallback]]) {
          NSMutableDictionary * newHints = [NSMutableDictionary dictionary];
          for (id key in [hints allKeys]) {
            if ([key intValue] != kDecodeHintTypeNeedResultPointCallback) {
              [newHints setObject:[hints objectForKey:key] forKey:key];
            }
          }

          hints = newHints;
        }
      }

      @try {
        Result * result = [self decodeRow:rowNumber row:row hints:hints];
        if (attempt == 1) {
          [result putMetadata:kResultMetadataTypeOrientation value:[NSNumber numberWithInt:180]];
          NSMutableArray * points = [result resultPoints];
          [points replaceObjectAtIndex:0
                            withObject:[[[ResultPoint alloc] initWithX:width - [(ResultPoint*)[points objectAtIndex:0] x]
                                                                     y:[(ResultPoint*)[points objectAtIndex:0] y]]
                                        autorelease]];
          [points replaceObjectAtIndex:1
                            withObject:[[[ResultPoint alloc] initWithX:width - [(ResultPoint*)[points objectAtIndex:1] x]
                                                                     y:[(ResultPoint*)[points objectAtIndex:1] y]]
                                        autorelease]];
        }
        return result;
      }
      @catch (ReaderException * re) {
      }
    }

  }

  @throw [NotFoundException notFoundInstance];
}


/**
 * Records the size of successive runs of white and black pixels in a row, starting at a given point.
 * The values are recorded in the given array, and the number of runs recorded is equal to the size
 * of the array. If the row starts on a white pixel at the given start point, then the first count
 * recorded is the run of white pixels starting from that point; likewise it is the count of a run
 * of black pixels if the row begin on a black pixels at that point.
 * 
 * @param row row to count from
 * @param start offset into row to start at
 * @param counters array into which to record counts
 * @throws NotFoundException if counters cannot be filled entirely from row before running out
 * of pixels
 */
+ (void) recordPattern:(BitArray *)row start:(int)start counters:(NSMutableArray *)counters {
  int numCounters = [counters count];

  for (int i = 0; i < numCounters; i++) {
    [counters replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
  }

  int end = [row size];
  if (start >= end) {
    @throw [NotFoundException notFoundInstance];
  }
  BOOL isWhite = ![row get:start];
  int counterPosition = 0;
  int i = start;

  while (i < end) {
    BOOL pixel = [row get:i];
    if (pixel ^ isWhite) {
      [counters replaceObjectAtIndex:counterPosition withObject:
       [NSNumber numberWithInt:[[counters objectAtIndex:counterPosition] intValue] + 1]];
    }
     else {
      counterPosition++;
      if (counterPosition == numCounters) {
        break;
      } else {
        [counters replaceObjectAtIndex:counterPosition withObject:[NSNumber numberWithInt:1]];
        isWhite = !isWhite;
      }
    }
    i++;
  }

  if (!(counterPosition == numCounters || (counterPosition == numCounters - 1 && i == end))) {
    @throw [NotFoundException notFoundInstance];
  }
}

+ (void) recordPatternInReverse:(BitArray *)row start:(int)start counters:(NSMutableArray *)counters {
  int numTransitionsLeft = [counters count];
  BOOL last = [row get:start];

  while (start > 0 && numTransitionsLeft >= 0) {
    if ([row get:--start] != last) {
      numTransitionsLeft--;
      last = !last;
    }
  }

  if (numTransitionsLeft >= 0) {
    @throw [NotFoundException notFoundInstance];
  }
  [self recordPattern:row start:start + 1 counters:counters];
}


/**
 * Determines how closely a set of observed counts of runs of black/white values matches a given
 * target pattern. This is reported as the ratio of the total variance from the expected pattern
 * proportions across all pattern elements, to the length of the pattern.
 * 
 * @param counters observed counters
 * @param pattern expected pattern
 * @param maxIndividualVariance The most any counter can differ before we give up
 * @return ratio of total variance between counters and pattern compared to total pattern size,
 * where the ratio has been multiplied by 256. So, 0 means no variance (perfect match); 256 means
 * the total variance between counters and patterns equals the pattern length, higher values mean
 * even more variance
 */
+ (int) patternMatchVariance:(NSArray *)counters pattern:(int[])pattern maxIndividualVariance:(int)maxIndividualVariance {
  int numCounters = [counters count];
  int total = 0;
  int patternLength = 0;

  for (int i = 0; i < numCounters; i++) {
    total += [[counters objectAtIndex:i] intValue];
    patternLength += [[pattern objectAtIndex:i] intValue];
  }

  if (total < patternLength) {
    return NSIntegerMax;
  }
  int unitBarWidth = (total << INTEGER_MATH_SHIFT) / patternLength;
  maxIndividualVariance = (maxIndividualVariance * unitBarWidth) >> INTEGER_MATH_SHIFT;
  int totalVariance = 0;

  for (int x = 0; x < numCounters; x++) {
    int counter = [[counters objectAtIndex:x] intValue] << INTEGER_MATH_SHIFT;
    int scaledPattern = [[pattern objectAtIndex:x] intValue] * unitBarWidth;
    int variance = counter > scaledPattern ? counter - scaledPattern : scaledPattern - counter;
    if (variance > maxIndividualVariance) {
      return NSIntegerMax;
    }
    totalVariance += variance;
  }

  return totalVariance / total;
}


/**
 * <p>Attempts to decode a one-dimensional barcode format given a single row of
 * an image.</p>
 * 
 * @param rowNumber row number from top of the row
 * @param row the black/white pixel data of the row
 * @param hints decode hints
 * @return {@link Result} containing encoded string and start/end of barcode
 * @throws NotFoundException if an error occurs or barcode cannot be found
 */
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

@end
