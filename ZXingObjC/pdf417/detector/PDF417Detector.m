#import "BinaryBitmap.h"
#import "NotFoundException.h"
#import "ResultPoint.h"
#import "BitMatrix.h"
#import "DetectorResult.h"
#import "GridSampler.h"
#import "PDF417Detector.h"

int const MAX_AVG_VARIANCE = (int)((1 << 8) * 0.42f);
int const MAX_INDIVIDUAL_VARIANCE = (int)((1 << 8) * 0.8f);
int const SKEW_THRESHOLD = 2;

// B S B S B S B S Bar/Space pattern
// 11111111 0 1 0 1 0 1 000
int const PDF417_START_PATTERN[8] = {8, 1, 1, 1, 1, 1, 1, 3};

// 11111111 0 1 0 1 0 1 000
int const START_PATTERN_REVERSE[8] = {3, 1, 1, 1, 1, 1, 1, 8};

// 1111111 0 1 000 1 0 1 00 1
int const STOP_PATTERN[9] = {7, 1, 1, 3, 1, 1, 1, 2, 1};

// B S B S B S B S B Bar/Space pattern
// 1111111 0 1 000 1 0 1 00 1
int const STOP_PATTERN_REVERSE[9] = {1, 2, 1, 1, 1, 3, 1, 1, 7};

@interface PDF417Detector ()

- (NSMutableArray *) findVertices:(BitMatrix *)matrix;
- (NSMutableArray *) findVertices180:(BitMatrix *)matrix;
- (void) correctCodeWordVertices:(NSMutableArray *)vertices upsideDown:(BOOL)upsideDown;
- (float) computeModuleWidth:(NSArray *)vertices;
- (int) computeDimension:(ResultPoint *)topLeft topRight:(ResultPoint *)topRight bottomLeft:(ResultPoint *)bottomLeft bottomRight:(ResultPoint *)bottomRight moduleWidth:(float)moduleWidth;
- (int) round:(float)d;
- (NSArray *) findGuardPattern:(BitMatrix *)matrix column:(int)column row:(int)row width:(int)width whiteFirst:(BOOL)whiteFirst pattern:(int *)pattern;
- (int) patternMatchVariance:(NSArray *)counters pattern:(int *)pattern maxIndividualVariance:(int)maxIndividualVariance;
- (BitMatrix *) sampleGrid:(BitMatrix *)matrix topLeft:(ResultPoint *)topLeft bottomLeft:(ResultPoint *)bottomLeft topRight:(ResultPoint *)topRight bottomRight:(ResultPoint *)bottomRight dimension:(int)dimension;

@end


@implementation PDF417Detector

- (id) initWithImage:(BinaryBitmap *)anImage {
  if (self = [super init]) {
    image = [anImage retain];
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

  NSMutableArray * vertices = [self findVertices:matrix];
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
  int dimension = [self computeDimension:[vertices objectAtIndex:4] topRight:[vertices objectAtIndex:6] bottomLeft:[vertices objectAtIndex:5] bottomRight:[vertices objectAtIndex:7] moduleWidth:moduleWidth];
  if (dimension < 1) {
    @throw [NotFoundException notFoundInstance];
  }
  BitMatrix * bits = [self sampleGrid:matrix topLeft:[vertices objectAtIndex:4] bottomLeft:[vertices objectAtIndex:5] topRight:[vertices objectAtIndex:6] bottomRight:[vertices objectAtIndex:7] dimension:dimension];
  return [[[DetectorResult alloc] initWithBits:bits points:[NSArray arrayWithObjects:[vertices objectAtIndex:4], [vertices objectAtIndex:5], [vertices objectAtIndex:6], [vertices objectAtIndex:7], nil]] autorelease];
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
- (NSMutableArray *) findVertices:(BitMatrix *)matrix {
  int height = [matrix height];
  int width = [matrix width];

  NSMutableArray * result = [NSMutableArray arrayWithCapacity:8];
  for (int i = 0; i < 8; i++) {
    [result addObject:[NSNull null]];
  }
  BOOL found = NO;

  // Top Left
  for (int i = 0; i < height; i++) {
    NSArray * loc = [self findGuardPattern:matrix column:0 row:i width:width whiteFirst:NO pattern:(int*)PDF417_START_PATTERN];
    if (loc != nil) {
      [result replaceObjectAtIndex:0
                        withObject:[[[ResultPoint alloc] initWithX:[[loc objectAtIndex:0] floatValue] y:i] autorelease]];
      [result replaceObjectAtIndex:4
                        withObject:[[[ResultPoint alloc] initWithX:[[loc objectAtIndex:1] floatValue] y:i] autorelease]];
      found = YES;
      break;
    }
  }
  // Bottom left
  if (found) { // Found the Top Left vertex
    found = NO;
    for (int i = height - 1; i > 0; i--) {
      NSArray * loc = [self findGuardPattern:matrix column:0 row:i width:width whiteFirst:NO pattern:(int*)PDF417_START_PATTERN];
      if (loc != nil) {
        [result replaceObjectAtIndex:1
                          withObject:[[[ResultPoint alloc] initWithX:[[loc objectAtIndex:0] floatValue] y:i] autorelease]];
        [result replaceObjectAtIndex:5
                          withObject:[[[ResultPoint alloc] initWithX:[[loc objectAtIndex:1] floatValue] y:i] autorelease]];
        found = YES;
        break;
      }
    }
  }
  // Top right
  if (found) { // Found the Bottom Left vertex
    found = NO;
    for (int i = 0; i < height; i++) {
      NSArray * loc = [self findGuardPattern:matrix column:0 row:i width:width whiteFirst:NO pattern:(int*)STOP_PATTERN];
      if (loc != nil) {
        [result replaceObjectAtIndex:2
                          withObject:[[[ResultPoint alloc] initWithX:[[loc objectAtIndex:1] floatValue] y:i] autorelease]];
        [result replaceObjectAtIndex:6
                          withObject:[[[ResultPoint alloc] initWithX:[[loc objectAtIndex:0] floatValue] y:i] autorelease]];
        found = YES;
        break;
      }
    }
  }
  // Bottom right
  if (found) { // Found the Top right vertex
    found = NO;
    for (int i = height - 1; i > 0; i--) {
      NSArray * loc = [self findGuardPattern:matrix column:0 row:i width:width whiteFirst:NO pattern:(int*)STOP_PATTERN];
      if (loc != nil) {
        [result replaceObjectAtIndex:3
                          withObject:[[[ResultPoint alloc] initWithX:[[loc objectAtIndex:1] floatValue] y:i] autorelease]];
        [result replaceObjectAtIndex:7
                          withObject:[[[ResultPoint alloc] initWithX:[[loc objectAtIndex:0] floatValue] y:i] autorelease]];
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
- (NSMutableArray *) findVertices180:(BitMatrix *)matrix {
  int height = [matrix height];
  int width = [matrix width];
  int halfWidth = width >> 1;

  NSMutableArray * result = [NSMutableArray arrayWithCapacity:8];
  for (int i = 0; i < 8; i++) {
    [result addObject:[NSNull null]];
  }
  BOOL found = NO;

  // Top Left
  for (int i = height - 1; i > 0; i--) {
    NSArray * loc = [self findGuardPattern:matrix column:halfWidth row:i width:halfWidth whiteFirst:YES pattern:(int*)START_PATTERN_REVERSE];
    if (loc != nil) {
      [result replaceObjectAtIndex:0
                        withObject:[[[ResultPoint alloc] initWithX:[[loc objectAtIndex:1] floatValue] y:i] autorelease]];
      [result replaceObjectAtIndex:4
                        withObject:[[[ResultPoint alloc] initWithX:[[loc objectAtIndex:0] floatValue] y:i] autorelease]];
      found = YES;
      break;
    }
  }
  // Bottom Left
  if (found) { // Found the Top Left vertex
    found = NO;
    for (int i = 0; i < height; i++) {
      NSArray * loc = [self findGuardPattern:matrix column:halfWidth row:i width:halfWidth whiteFirst:YES pattern:(int*)START_PATTERN_REVERSE];
      if (loc != nil) {
        [result replaceObjectAtIndex:1
                          withObject:[[[ResultPoint alloc] initWithX:[[loc objectAtIndex:1] floatValue] y:i] autorelease]];
        [result replaceObjectAtIndex:5
                          withObject:[[[ResultPoint alloc] initWithX:[[loc objectAtIndex:0] floatValue] y:i] autorelease]];
        found = YES;
        break;
      }
    }
  }
  // Top Right
  if (found) { // Found the Bottom Left vertex
    found = NO;
    for (int i = height - 1; i > 0; i--) {
      NSArray * loc = [self findGuardPattern:matrix column:0 row:i width:halfWidth whiteFirst:NO pattern:(int*)STOP_PATTERN_REVERSE];
      if (loc != nil) {
        [result replaceObjectAtIndex:2
                          withObject:[[[ResultPoint alloc] initWithX:[[loc objectAtIndex:0] floatValue] y:i] autorelease]];
        [result replaceObjectAtIndex:6
                          withObject:[[[ResultPoint alloc] initWithX:[[loc objectAtIndex:1] floatValue] y:i] autorelease]];
        found = YES;
        break;
      }
    }
  }
  // Bottom Right
  if (found) { // Found the Top Right vertex
    found = NO;
    for (int i = 0; i < height; i++) {
      NSArray * loc = [self findGuardPattern:matrix column:0 row:i width:halfWidth whiteFirst:NO pattern:(int*)STOP_PATTERN_REVERSE];
      if (loc != nil) {
        [result replaceObjectAtIndex:3
                          withObject:[[[ResultPoint alloc] initWithX:[[loc objectAtIndex:0] floatValue] y:i] autorelease]];
        [result replaceObjectAtIndex:7
                          withObject:[[[ResultPoint alloc] initWithX:[[loc objectAtIndex:1] floatValue] y:i] autorelease]];
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
- (void) correctCodeWordVertices:(NSMutableArray *)vertices upsideDown:(BOOL)upsideDown {
  float skew = [(ResultPoint*)[vertices objectAtIndex:4] y] - [(ResultPoint*)[vertices objectAtIndex:6] y];
  if (upsideDown) {
    skew = -skew;
  }
  if (skew > SKEW_THRESHOLD) {
    // Fix v4
    float length = [(ResultPoint*)[vertices objectAtIndex:4] x] - [(ResultPoint*)[vertices objectAtIndex:0] x];
    float deltax = [(ResultPoint*)[vertices objectAtIndex:6] x] - [(ResultPoint*)[vertices objectAtIndex:0] x];
    float deltay = [(ResultPoint*)[vertices objectAtIndex:6] y] - [(ResultPoint*)[vertices objectAtIndex:0] y];
    float correction = length * deltay / deltax;
    [vertices replaceObjectAtIndex:4
                        withObject:[[[ResultPoint alloc] initWithX:[(ResultPoint*)[vertices objectAtIndex:4] x]
                                                                 y:[(ResultPoint*)[vertices objectAtIndex:4] y] + correction] autorelease]];
  } else if (-skew > SKEW_THRESHOLD) {
    // Fix v6
    float length = [(ResultPoint*)[vertices objectAtIndex:2] x] - [(ResultPoint*)[vertices objectAtIndex:6] x];
    float deltax = [(ResultPoint*)[vertices objectAtIndex:2] x] - [(ResultPoint*)[vertices objectAtIndex:4] x];
    float deltay = [(ResultPoint*)[vertices objectAtIndex:2] y] - [(ResultPoint*)[vertices objectAtIndex:4] y];
    float correction = length * deltay / deltax;
    [vertices replaceObjectAtIndex:6
                        withObject:[[[ResultPoint alloc] initWithX:[(ResultPoint*)[vertices objectAtIndex:6] x]
                                                                 y:[(ResultPoint*)[vertices objectAtIndex:6] y] + correction] autorelease]];
  }
  
  skew = [(ResultPoint*)[vertices objectAtIndex:7] y] - [(ResultPoint*)[vertices objectAtIndex:5] y];
  if (upsideDown) {
    skew = -skew;
  }
  if (skew > SKEW_THRESHOLD) {
    // Fix v5
    float length = [(ResultPoint*)[vertices objectAtIndex:5] x] - [(ResultPoint*)[vertices objectAtIndex:1] x];
    float deltax = [(ResultPoint*)[vertices objectAtIndex:7] x] - [(ResultPoint*)[vertices objectAtIndex:1] x];
    float deltay = [(ResultPoint*)[vertices objectAtIndex:7] y] - [(ResultPoint*)[vertices objectAtIndex:1] y];
    float correction = length * deltay / deltax;
    [vertices replaceObjectAtIndex:5
                        withObject:[[[ResultPoint alloc] initWithX:[(ResultPoint*)[vertices objectAtIndex:5] x]
                                                                 y:[(ResultPoint*)[vertices objectAtIndex:5] y] + correction] autorelease]];
  } else if (-skew > SKEW_THRESHOLD) {
    // Fix v7
    float length = [(ResultPoint*)[vertices objectAtIndex:3] x] - [(ResultPoint*)[vertices objectAtIndex:7] x];
    float deltax = [(ResultPoint*)[vertices objectAtIndex:3] x] - [(ResultPoint*)[vertices objectAtIndex:5] x];
    float deltay = [(ResultPoint*)[vertices objectAtIndex:3] y] - [(ResultPoint*)[vertices objectAtIndex:5] y];
    float correction = length * deltay / deltax;
    [vertices replaceObjectAtIndex:7
                        withObject:[[[ResultPoint alloc] initWithX:[(ResultPoint*)[vertices objectAtIndex:7] x]
                                                                 y:[(ResultPoint*)[vertices objectAtIndex:7] y] + correction] autorelease]];
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
- (float) computeModuleWidth:(NSArray *)vertices {
  float pixels1 = [ResultPoint distance:[vertices objectAtIndex:0] pattern2:[vertices objectAtIndex:4]];
  float pixels2 = [ResultPoint distance:[vertices objectAtIndex:1] pattern2:[vertices objectAtIndex:5]];
  float moduleWidth1 = (pixels1 + pixels2) / (17 * 2.0f);
  float pixels3 = [ResultPoint distance:[vertices objectAtIndex:6] pattern2:[vertices objectAtIndex:2]];
  float pixels4 = [ResultPoint distance:[vertices objectAtIndex:7] pattern2:[vertices objectAtIndex:3]];
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
- (int) computeDimension:(ResultPoint *)topLeft topRight:(ResultPoint *)topRight bottomLeft:(ResultPoint *)bottomLeft bottomRight:(ResultPoint *)bottomRight moduleWidth:(float)moduleWidth {
  int topRowDimension = [self round:[ResultPoint distance:topLeft pattern2:topRight] / moduleWidth];
  int bottomRowDimension = [self round:[ResultPoint distance:bottomLeft pattern2:bottomRight] / moduleWidth];
  return ((((topRowDimension + bottomRowDimension) >> 1) + 8) / 17) * 17;
}

- (BitMatrix *) sampleGrid:(BitMatrix *)matrix topLeft:(ResultPoint *)topLeft bottomLeft:(ResultPoint *)bottomLeft topRight:(ResultPoint *)topRight bottomRight:(ResultPoint *)bottomRight dimension:(int)dimension {
  GridSampler * sampler = [GridSampler instance];
  return [sampler sampleGrid:matrix
                  dimensionX:dimension
                  dimensionY:dimension
                       p1ToX:0.0f
                       p1ToY:0.0f
                       p2ToX:dimension
                       p2ToY:0.0f
                       p3ToX:dimension
                       p3ToY:dimension
                       p4ToX:0.0f
                       p4ToY:dimension
                     p1FromX:[topLeft x]
                     p1FromY:[topLeft y]
                     p2FromX:[topRight x]
                     p2FromY:[topRight y]
                     p3FromX:[bottomRight x]
                     p3FromY:[bottomRight y]
                     p4FromX:[bottomLeft x]
                     p4FromY:[bottomLeft y]];
}


/**
 * Ends up being a bit faster than Math.round(). This merely rounds its
 * argument to the nearest int, where x.5 rounds up.
 */
- (int) round:(float)d {
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
- (NSArray *) findGuardPattern:(BitMatrix *)matrix column:(int)column row:(int)row width:(int)width whiteFirst:(BOOL)whiteFirst pattern:(int *)pattern {
  int patternLength = sizeof(pattern) / sizeof(int*);
  NSMutableArray * counters = [NSMutableArray arrayWithCapacity:patternLength];
  for (int i = 0; i < patternLength; i++) {
    [counters addObject:[NSNumber numberWithInt:0]];
  }
  BOOL isWhite = whiteFirst;

  int counterPosition = 0;
  int patternStart = column;
  for (int x = column; x < column + width; x++) {
    BOOL pixel = [matrix get:x y:row];
    if (pixel ^ isWhite) {
      [counters replaceObjectAtIndex:counterPosition
                          withObject:[NSNumber numberWithInt:[[counters objectAtIndex:counterPosition] intValue] + 1]];
    } else {
      if (counterPosition == patternLength - 1) {
        if ([self patternMatchVariance:counters pattern:pattern maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE] < MAX_AVG_VARIANCE) {
          return [NSArray arrayWithObjects:[NSNumber numberWithInt:patternStart], [NSNumber numberWithInt:x], nil];
        }
        patternStart += [[counters objectAtIndex:0] intValue] + [[counters objectAtIndex:1] intValue];
        for (int y = 2; y < patternLength; y++) {
          [counters replaceObjectAtIndex:y - 2 withObject:[counters objectAtIndex:y]];
        }
        [counters replaceObjectAtIndex:patternLength - 2 withObject:[NSNumber numberWithInt:0]];
        [counters replaceObjectAtIndex:patternLength - 1 withObject:[NSNumber numberWithInt:0]];
        counterPosition--;
      } else {
        counterPosition++;
      }
      [counters replaceObjectAtIndex:counterPosition withObject:[NSNumber numberWithInt:1]];
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
- (int) patternMatchVariance:(NSArray *)counters pattern:(int *)pattern maxIndividualVariance:(int)maxIndividualVariance {
  int numCounters = [counters count];
  int total = 0;
  int patternLength = 0;
  for (int i = 0; i < numCounters; i++) {
    total += [[counters objectAtIndex:i] intValue];
    patternLength += pattern[i];
  }

  if (total < patternLength) {
    return NSIntegerMax;
  }
  int unitBarWidth = (total << 8) / patternLength;
  maxIndividualVariance = (maxIndividualVariance * unitBarWidth) >> 8;

  int totalVariance = 0;
  for (int x = 0; x < numCounters; x++) {
    int counter = [[counters objectAtIndex:x] intValue] << 8;
    int scaledPattern = pattern[x] * unitBarWidth;
    int variance = counter > scaledPattern ? counter - scaledPattern : scaledPattern - counter;
    if (variance > maxIndividualVariance) {
      return NSIntegerMax;
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
