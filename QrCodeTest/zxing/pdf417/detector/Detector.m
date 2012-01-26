#import "Detector.h"

int const MAX_AVG_VARIANCE = (int)((1 << 8) * 0.42f);
int const MAX_INDIVIDUAL_VARIANCE = (int)((1 << 8) * 0.8f);
int const SKEW_THRESHOLD = 2;
NSArray * const START_PATTERN = [NSArray arrayWithObjects:8, 1, 1, 1, 1, 1, 1, 3, nil];
NSArray * const START_PATTERN_REVERSE = [NSArray arrayWithObjects:3, 1, 1, 1, 1, 1, 1, 8, nil];
NSArray * const STOP_PATTERN = [NSArray arrayWithObjects:7, 1, 1, 3, 1, 1, 1, 2, 1, nil];
NSArray * const STOP_PATTERN_REVERSE = [NSArray arrayWithObjects:1, 2, 1, 1, 1, 3, 1, 1, 7, nil];

@implementation Detector

- (id) initWithImage:(BinaryBitmap *)image {
  if (self = [super init]) {
    image = image;
  }
  return self;
}


/**
 * <p>Detects a PDF417 Code in an image, simply.</p>
 * 
 * @return {@link DetectorResult} encapsulating results of detecting a PDF417 Code
 * @throws NotFoundException if no QR Code can be found
 */
- (DetectorResult *) detect {
  return [self detect:nil];
}


/**
 * <p>Detects a PDF417 Code in an image. Only checks 0 and 180 degree rotations.</p>
 * 
 * @param hints optional hints to detector
 * @return {@link DetectorResult} encapsulating results of detecting a PDF417 Code
 * @throws NotFoundException if no PDF417 Code can be found
 */
- (DetectorResult *) detect:(NSMutableDictionary *)hints {
  BitMatrix * matrix = [image blackMatrix];
  NSArray * vertices = [self findVertices:matrix];
  if (vertices == nil) {
    vertices = [self findVertices180:matrix];
    if (vertices != nil) {
      [self correctCodeWordVertices:vertices upsideDown:YES];
    }
  }
   else {
    [self correctCodeWordVertices:vertices upsideDown:NO];
  }
  if (vertices == nil) {
    @throw [NotFoundException notFoundInstance];
  }
  float moduleWidth = [self computeModuleWidth:vertices];
  if (moduleWidth < 1.0f) {
    @throw [NotFoundException notFoundInstance];
  }
  int dimension = [self computeDimension:vertices[4] topRight:vertices[6] bottomLeft:vertices[5] bottomRight:vertices[7] moduleWidth:moduleWidth];
  if (dimension < 1) {
    @throw [NotFoundException notFoundInstance];
  }
  BitMatrix * bits = [self sampleGrid:matrix topLeft:vertices[4] bottomLeft:vertices[5] topRight:vertices[6] bottomRight:vertices[7] dimension:dimension];
  return [[[DetectorResult alloc] init:bits param1:[NSArray arrayWithObjects:vertices[4], vertices[5], vertices[6], vertices[7], nil]] autorelease];
}


/**
 * Locate the vertices and the codewords area of a black blob using the Start
 * and Stop patterns as locators.
 * TODO: Scanning every row is very expensive. We should only do this for TRY_HARDER.
 * 
 * @param matrix the scanned barcode image.
 * @return an array containing the vertices:
 * vertices[0] x, y top left barcode
 * vertices[1] x, y bottom left barcode
 * vertices[2] x, y top right barcode
 * vertices[3] x, y bottom right barcode
 * vertices[4] x, y top left codeword area
 * vertices[5] x, y bottom left codeword area
 * vertices[6] x, y top right codeword area
 * vertices[7] x, y bottom right codeword area
 */
+ (NSArray *) findVertices:(BitMatrix *)matrix {
  int height = [matrix height];
  int width = [matrix width];
  NSArray * result = [NSArray array];
  BOOL found = NO;

  for (int i = 0; i < height; i++) {
    NSArray * loc = [self findGuardPattern:matrix column:0 row:i width:width whiteFirst:NO pattern:START_PATTERN];
    if (loc != nil) {
      result[0] = [[[ResultPoint alloc] init:loc[0] param1:i] autorelease];
      result[4] = [[[ResultPoint alloc] init:loc[1] param1:i] autorelease];
      found = YES;
      break;
    }
  }

  if (found) {
    found = NO;

    for (int i = height - 1; i > 0; i--) {
      NSArray * loc = [self findGuardPattern:matrix column:0 row:i width:width whiteFirst:NO pattern:START_PATTERN];
      if (loc != nil) {
        result[1] = [[[ResultPoint alloc] init:loc[0] param1:i] autorelease];
        result[5] = [[[ResultPoint alloc] init:loc[1] param1:i] autorelease];
        found = YES;
        break;
      }
    }

  }
  if (found) {
    found = NO;

    for (int i = 0; i < height; i++) {
      NSArray * loc = [self findGuardPattern:matrix column:0 row:i width:width whiteFirst:NO pattern:STOP_PATTERN];
      if (loc != nil) {
        result[2] = [[[ResultPoint alloc] init:loc[1] param1:i] autorelease];
        result[6] = [[[ResultPoint alloc] init:loc[0] param1:i] autorelease];
        found = YES;
        break;
      }
    }

  }
  if (found) {
    found = NO;

    for (int i = height - 1; i > 0; i--) {
      NSArray * loc = [self findGuardPattern:matrix column:0 row:i width:width whiteFirst:NO pattern:STOP_PATTERN];
      if (loc != nil) {
        result[3] = [[[ResultPoint alloc] init:loc[1] param1:i] autorelease];
        result[7] = [[[ResultPoint alloc] init:loc[0] param1:i] autorelease];
        found = YES;
        break;
      }
    }

  }
  return found ? result : nil;
}


/**
 * Locate the vertices and the codewords area of a black blob using the Start
 * and Stop patterns as locators. This assumes that the image is rotated 180
 * degrees and if it locates the start and stop patterns at it will re-map
 * the vertices for a 0 degree rotation.
 * TODO: Change assumption about barcode location.
 * TODO: Scanning every row is very expensive. We should only do this for TRY_HARDER.
 * 
 * @param matrix the scanned barcode image.
 * @return an array containing the vertices:
 * vertices[0] x, y top left barcode
 * vertices[1] x, y bottom left barcode
 * vertices[2] x, y top right barcode
 * vertices[3] x, y bottom right barcode
 * vertices[4] x, y top left codeword area
 * vertices[5] x, y bottom left codeword area
 * vertices[6] x, y top right codeword area
 * vertices[7] x, y bottom right codeword area
 */
+ (NSArray *) findVertices180:(BitMatrix *)matrix {
  int height = [matrix height];
  int width = [matrix width];
  int halfWidth = width >> 1;
  NSArray * result = [NSArray array];
  BOOL found = NO;

  for (int i = height - 1; i > 0; i--) {
    NSArray * loc = [self findGuardPattern:matrix column:halfWidth row:i width:halfWidth whiteFirst:YES pattern:START_PATTERN_REVERSE];
    if (loc != nil) {
      result[0] = [[[ResultPoint alloc] init:loc[1] param1:i] autorelease];
      result[4] = [[[ResultPoint alloc] init:loc[0] param1:i] autorelease];
      found = YES;
      break;
    }
  }

  if (found) {
    found = NO;

    for (int i = 0; i < height; i++) {
      NSArray * loc = [self findGuardPattern:matrix column:halfWidth row:i width:halfWidth whiteFirst:YES pattern:START_PATTERN_REVERSE];
      if (loc != nil) {
        result[1] = [[[ResultPoint alloc] init:loc[1] param1:i] autorelease];
        result[5] = [[[ResultPoint alloc] init:loc[0] param1:i] autorelease];
        found = YES;
        break;
      }
    }

  }
  if (found) {
    found = NO;

    for (int i = height - 1; i > 0; i--) {
      NSArray * loc = [self findGuardPattern:matrix column:0 row:i width:halfWidth whiteFirst:NO pattern:STOP_PATTERN_REVERSE];
      if (loc != nil) {
        result[2] = [[[ResultPoint alloc] init:loc[0] param1:i] autorelease];
        result[6] = [[[ResultPoint alloc] init:loc[1] param1:i] autorelease];
        found = YES;
        break;
      }
    }

  }
  if (found) {
    found = NO;

    for (int i = 0; i < height; i++) {
      NSArray * loc = [self findGuardPattern:matrix column:0 row:i width:halfWidth whiteFirst:NO pattern:STOP_PATTERN_REVERSE];
      if (loc != nil) {
        result[3] = [[[ResultPoint alloc] init:loc[0] param1:i] autorelease];
        result[7] = [[[ResultPoint alloc] init:loc[1] param1:i] autorelease];
        found = YES;
        break;
      }
    }

  }
  return found ? result : nil;
}


/**
 * Because we scan horizontally to detect the start and stop patterns, the vertical component of
 * the codeword coordinates will be slightly wrong if there is any skew or rotation in the image.
 * This method moves those points back onto the edges of the theoretically perfect bounding
 * quadrilateral if needed.
 * 
 * @param vertices The eight vertices located by findVertices().
 */
+ (void) correctCodeWordVertices:(NSArray *)vertices upsideDown:(BOOL)upsideDown {
  float skew = [vertices[4] y] - [vertices[6] y];
  if (upsideDown) {
    skew = -skew;
  }
  if (skew > SKEW_THRESHOLD) {
    float length = [vertices[4] x] - [vertices[0] x];
    float deltax = [vertices[6] x] - [vertices[0] x];
    float deltay = [vertices[6] y] - [vertices[0] y];
    float correction = length * deltay / deltax;
    vertices[4] = [[[ResultPoint alloc] init:[vertices[4] x] param1:[vertices[4] y] + correction] autorelease];
  }
   else if (-skew > SKEW_THRESHOLD) {
    float length = [vertices[2] x] - [vertices[6] x];
    float deltax = [vertices[2] x] - [vertices[4] x];
    float deltay = [vertices[2] y] - [vertices[4] y];
    float correction = length * deltay / deltax;
    vertices[6] = [[[ResultPoint alloc] init:[vertices[6] x] param1:[vertices[6] y] - correction] autorelease];
  }
  skew = [vertices[7] y] - [vertices[5] y];
  if (upsideDown) {
    skew = -skew;
  }
  if (skew > SKEW_THRESHOLD) {
    float length = [vertices[5] x] - [vertices[1] x];
    float deltax = [vertices[7] x] - [vertices[1] x];
    float deltay = [vertices[7] y] - [vertices[1] y];
    float correction = length * deltay / deltax;
    vertices[5] = [[[ResultPoint alloc] init:[vertices[5] x] param1:[vertices[5] y] + correction] autorelease];
  }
   else if (-skew > SKEW_THRESHOLD) {
    float length = [vertices[3] x] - [vertices[7] x];
    float deltax = [vertices[3] x] - [vertices[5] x];
    float deltay = [vertices[3] y] - [vertices[5] y];
    float correction = length * deltay / deltax;
    vertices[7] = [[[ResultPoint alloc] init:[vertices[7] x] param1:[vertices[7] y] - correction] autorelease];
  }
}


/**
 * <p>Estimates module size (pixels in a module) based on the Start and End
 * finder patterns.</p>
 * 
 * @param vertices an array of vertices:
 * vertices[0] x, y top left barcode
 * vertices[1] x, y bottom left barcode
 * vertices[2] x, y top right barcode
 * vertices[3] x, y bottom right barcode
 * vertices[4] x, y top left codeword area
 * vertices[5] x, y bottom left codeword area
 * vertices[6] x, y top right codeword area
 * vertices[7] x, y bottom right codeword area
 * @return the module size.
 */
+ (float) computeModuleWidth:(NSArray *)vertices {
  float pixels1 = [ResultPoint distance:vertices[0] param1:vertices[4]];
  float pixels2 = [ResultPoint distance:vertices[1] param1:vertices[5]];
  float moduleWidth1 = (pixels1 + pixels2) / (17 * 2.0f);
  float pixels3 = [ResultPoint distance:vertices[6] param1:vertices[2]];
  float pixels4 = [ResultPoint distance:vertices[7] param1:vertices[3]];
  float moduleWidth2 = (pixels3 + pixels4) / (18 * 2.0f);
  return (moduleWidth1 + moduleWidth2) / 2.0f;
}


/**
 * Computes the dimension (number of modules in a row) of the PDF417 Code
 * based on vertices of the codeword area and estimated module size.
 * 
 * @param topLeft     of codeword area
 * @param topRight    of codeword area
 * @param bottomLeft  of codeword area
 * @param bottomRight of codeword are
 * @param moduleWidth estimated module size
 * @return the number of modules in a row.
 */
+ (int) computeDimension:(ResultPoint *)topLeft topRight:(ResultPoint *)topRight bottomLeft:(ResultPoint *)bottomLeft bottomRight:(ResultPoint *)bottomRight moduleWidth:(float)moduleWidth {
  int topRowDimension = [self round:[ResultPoint distance:topLeft param1:topRight] / moduleWidth];
  int bottomRowDimension = [self round:[ResultPoint distance:bottomLeft param1:bottomRight] / moduleWidth];
  return ((((topRowDimension + bottomRowDimension) >> 1) + 8) / 17) * 17;
}

+ (BitMatrix *) sampleGrid:(BitMatrix *)matrix topLeft:(ResultPoint *)topLeft bottomLeft:(ResultPoint *)bottomLeft topRight:(ResultPoint *)topRight bottomRight:(ResultPoint *)bottomRight dimension:(int)dimension {
  GridSampler * sampler = [GridSampler instance];
  return [sampler sampleGrid:matrix param1:dimension param2:dimension param3:0.0f param4:0.0f param5:dimension param6:0.0f param7:dimension param8:dimension param9:0.0f param10:dimension param11:[topLeft x] param12:[topLeft y] param13:[topRight x] param14:[topRight y] param15:[bottomRight x] param16:[bottomRight y] param17:[bottomLeft x] param18:[bottomLeft y]];
}


/**
 * Ends up being a bit faster than Math.round(). This merely rounds its
 * argument to the nearest int, where x.5 rounds up.
 */
+ (int) round:(float)d {
  return (int)(d + 0.5f);
}


/**
 * @param matrix row of black/white values to search
 * @param column x position to start search
 * @param row y position to start search
 * @param width the number of pixels to search on this row
 * @param pattern pattern of counts of number of black and white pixels that are
 * being searched for as a pattern
 * @return start/end horizontal offset of guard pattern, as an array of two ints.
 */
+ (NSArray *) findGuardPattern:(BitMatrix *)matrix column:(int)column row:(int)row width:(int)width whiteFirst:(BOOL)whiteFirst pattern:(NSArray *)pattern {
  int patternLength = pattern.length;
  NSArray * counters = [NSArray array];
  BOOL isWhite = whiteFirst;
  int counterPosition = 0;
  int patternStart = column;

  for (int x = column; x < column + width; x++) {
    BOOL pixel = [matrix get:x param1:row];
    if (pixel ^ isWhite) {
      counters[counterPosition]++;
    }
     else {
      if (counterPosition == patternLength - 1) {
        if ([self patternMatchVariance:counters pattern:pattern maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE] < MAX_AVG_VARIANCE) {
          return [NSArray arrayWithObjects:patternStart, x, nil];
        }
        patternStart += counters[0] + counters[1];

        for (int y = 2; y < patternLength; y++) {
          counters[y - 2] = counters[y];
        }

        counters[patternLength - 2] = 0;
        counters[patternLength - 1] = 0;
        counterPosition--;
      }
       else {
        counterPosition++;
      }
      counters[counterPosition] = 1;
      isWhite = !isWhite;
    }
  }

  return nil;
}


/**
 * Determines how closely a set of observed counts of runs of black/white
 * values matches a given target pattern. This is reported as the ratio of
 * the total variance from the expected pattern proportions across all
 * pattern elements, to the length of the pattern.
 * 
 * @param counters observed counters
 * @param pattern expected pattern
 * @param maxIndividualVariance The most any counter can differ before we give up
 * @return ratio of total variance between counters and pattern compared to
 * total pattern size, where the ratio has been multiplied by 256.
 * So, 0 means no variance (perfect match); 256 means the total
 * variance between counters and patterns equals the pattern length,
 * higher values mean even more variance
 */
+ (int) patternMatchVariance:(NSArray *)counters pattern:(NSArray *)pattern maxIndividualVariance:(int)maxIndividualVariance {
  int numCounters = counters.length;
  int total = 0;
  int patternLength = 0;

  for (int i = 0; i < numCounters; i++) {
    total += counters[i];
    patternLength += pattern[i];
  }

  if (total < patternLength) {
    return Integer.MAX_VALUE;
  }
  int unitBarWidth = (total << 8) / patternLength;
  maxIndividualVariance = (maxIndividualVariance * unitBarWidth) >> 8;
  int totalVariance = 0;

  for (int x = 0; x < numCounters; x++) {
    int counter = counters[x] << 8;
    int scaledPattern = pattern[x] * unitBarWidth;
    int variance = counter > scaledPattern ? counter - scaledPattern : scaledPattern - counter;
    if (variance > maxIndividualVariance) {
      return Integer.MAX_VALUE;
    }
    totalVariance += variance;
  }

  return totalVariance / total;
}

- (void) dealloc {
  [image release];
  [super dealloc];
}

@end
