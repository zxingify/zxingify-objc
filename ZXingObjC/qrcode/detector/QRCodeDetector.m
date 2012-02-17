#import "QRCodeDetector.h"

@implementation QRCodeDetector

- (id) initWithImage:(BitMatrix *)image {
  if (self = [super init]) {
    image = image;
  }
  return self;
}

- (BitMatrix *) getImage {
  return image;
}

- (ResultPointCallback *) getResultPointCallback {
  return resultPointCallback;
}


/**
 * <p>Detects a QR Code in an image, simply.</p>
 * 
 * @return {@link DetectorResult} encapsulating results of detecting a QR Code
 * @throws NotFoundException if no QR Code can be found
 */
- (DetectorResult *) detect {
  return [self detect:nil];
}


/**
 * <p>Detects a QR Code in an image, simply.</p>
 * 
 * @param hints optional hints to detector
 * @return {@link NotFoundException} encapsulating results of detecting a QR Code
 * @throws NotFoundException if QR Code cannot be found
 * @throws FormatException if a QR Code cannot be decoded
 */
- (DetectorResult *) detect:(NSMutableDictionary *)hints {
  resultPointCallback = hints == nil ? nil : (ResultPointCallback *)[hints objectForKey:DecodeHintType.NEED_RESULT_POINT_CALLBACK];
  FinderPatternFinder * finder = [[[FinderPatternFinder alloc] init:image param1:resultPointCallback] autorelease];
  FinderPatternInfo * info = [finder find:hints];
  return [self processFinderPatternInfo:info];
}

- (DetectorResult *) processFinderPatternInfo:(FinderPatternInfo *)info {
  FinderPattern * topLeft = [info topLeft];
  FinderPattern * topRight = [info topRight];
  FinderPattern * bottomLeft = [info bottomLeft];
  float moduleSize = [self calculateModuleSize:topLeft topRight:topRight bottomLeft:bottomLeft];
  if (moduleSize < 1.0f) {
    @throw [NotFoundException notFoundInstance];
  }
  int dimension = [self computeDimension:topLeft topRight:topRight bottomLeft:bottomLeft moduleSize:moduleSize];
  Version * provisionalVersion = [Version getProvisionalVersionForDimension:dimension];
  int modulesBetweenFPCenters = [provisionalVersion dimensionForVersion] - 7;
  AlignmentPattern * alignmentPattern = nil;
  if ([provisionalVersion alignmentPatternCenters].length > 0) {
    float bottomRightX = [topRight x] - [topLeft x] + [bottomLeft x];
    float bottomRightY = [topRight y] - [topLeft y] + [bottomLeft y];
    float correctionToTopLeft = 1.0f - 3.0f / (float)modulesBetweenFPCenters;
    int estAlignmentX = (int)([topLeft x] + correctionToTopLeft * (bottomRightX - [topLeft x]));
    int estAlignmentY = (int)([topLeft y] + correctionToTopLeft * (bottomRightY - [topLeft y]));

    for (int i = 4; i <= 16; i <<= 1) {

      @try {
        alignmentPattern = [self findAlignmentInRegion:moduleSize estAlignmentX:estAlignmentX estAlignmentY:estAlignmentY allowanceFactor:(float)i];
        break;
      }
      @catch (NotFoundException * re) {
      }
    }

  }
  PerspectiveTransform * transform = [self createTransform:topLeft topRight:topRight bottomLeft:bottomLeft alignmentPattern:alignmentPattern dimension:dimension];
  BitMatrix * bits = [self sampleGrid:image transform:transform dimension:dimension];
  NSArray * points;
  if (alignmentPattern == nil) {
    points = [NSArray arrayWithObjects:bottomLeft, topLeft, topRight, nil];
  }
   else {
    points = [NSArray arrayWithObjects:bottomLeft, topLeft, topRight, alignmentPattern, nil];
  }
  return [[[DetectorResult alloc] init:bits param1:points] autorelease];
}

+ (PerspectiveTransform *) createTransform:(ResultPoint *)topLeft topRight:(ResultPoint *)topRight bottomLeft:(ResultPoint *)bottomLeft alignmentPattern:(ResultPoint *)alignmentPattern dimension:(int)dimension {
  float dimMinusThree = (float)dimension - 3.5f;
  float bottomRightX;
  float bottomRightY;
  float sourceBottomRightX;
  float sourceBottomRightY;
  if (alignmentPattern != nil) {
    bottomRightX = [alignmentPattern x];
    bottomRightY = [alignmentPattern y];
    sourceBottomRightX = sourceBottomRightY = dimMinusThree - 3.0f;
  }
   else {
    bottomRightX = ([topRight x] - [topLeft x]) + [bottomLeft x];
    bottomRightY = ([topRight y] - [topLeft y]) + [bottomLeft y];
    sourceBottomRightX = sourceBottomRightY = dimMinusThree;
  }
  return [PerspectiveTransform quadrilateralToQuadrilateral:3.5f param1:3.5f param2:dimMinusThree param3:3.5f param4:sourceBottomRightX param5:sourceBottomRightY param6:3.5f param7:dimMinusThree param8:[topLeft x] param9:[topLeft y] param10:[topRight x] param11:[topRight y] param12:bottomRightX param13:bottomRightY param14:[bottomLeft x] param15:[bottomLeft y]];
}

+ (BitMatrix *) sampleGrid:(BitMatrix *)image transform:(PerspectiveTransform *)transform dimension:(int)dimension {
  GridSampler * sampler = [GridSampler instance];
  return [sampler sampleGrid:image param1:dimension param2:dimension param3:transform];
}


/**
 * <p>Computes the dimension (number of modules on a size) of the QR Code based on the position
 * of the finder patterns and estimated module size.</p>
 */
+ (int) computeDimension:(ResultPoint *)topLeft topRight:(ResultPoint *)topRight bottomLeft:(ResultPoint *)bottomLeft moduleSize:(float)moduleSize {
  int tltrCentersDimension = [self round:[ResultPoint distance:topLeft param1:topRight] / moduleSize];
  int tlblCentersDimension = [self round:[ResultPoint distance:topLeft param1:bottomLeft] / moduleSize];
  int dimension = ((tltrCentersDimension + tlblCentersDimension) >> 1) + 7;

  switch (dimension & 0x03) {
  case 0:
    dimension++;
    break;
  case 2:
    dimension--;
    break;
  case 3:
    @throw [NotFoundException notFoundInstance];
  }
  return dimension;
}


/**
 * <p>Computes an average estimated module size based on estimated derived from the positions
 * of the three finder patterns.</p>
 */
- (float) calculateModuleSize:(ResultPoint *)topLeft topRight:(ResultPoint *)topRight bottomLeft:(ResultPoint *)bottomLeft {
  return ([self calculateModuleSizeOneWay:topLeft otherPattern:topRight] + [self calculateModuleSizeOneWay:topLeft otherPattern:bottomLeft]) / 2.0f;
}


/**
 * <p>Estimates module size based on two finder patterns -- it uses
 * {@link #sizeOfBlackWhiteBlackRunBothWays(int, int, int, int)} to figure the
 * width of each, measuring along the axis between their centers.</p>
 */
- (float) calculateModuleSizeOneWay:(ResultPoint *)pattern otherPattern:(ResultPoint *)otherPattern {
  float moduleSizeEst1 = [self sizeOfBlackWhiteBlackRunBothWays:(int)[pattern x] fromY:(int)[pattern y] toX:(int)[otherPattern x] toY:(int)[otherPattern y]];
  float moduleSizeEst2 = [self sizeOfBlackWhiteBlackRunBothWays:(int)[otherPattern x] fromY:(int)[otherPattern y] toX:(int)[pattern x] toY:(int)[pattern y]];
  if ([Float isNaN:moduleSizeEst1]) {
    return moduleSizeEst2 / 7.0f;
  }
  if ([Float isNaN:moduleSizeEst2]) {
    return moduleSizeEst1 / 7.0f;
  }
  return (moduleSizeEst1 + moduleSizeEst2) / 14.0f;
}


/**
 * See {@link #sizeOfBlackWhiteBlackRun(int, int, int, int)}; computes the total width of
 * a finder pattern by looking for a black-white-black run from the center in the direction
 * of another point (another finder pattern center), and in the opposite direction too.</p>
 */
- (float) sizeOfBlackWhiteBlackRunBothWays:(int)fromX fromY:(int)fromY toX:(int)toX toY:(int)toY {
  float result = [self sizeOfBlackWhiteBlackRun:fromX fromY:fromY toX:toX toY:toY];
  float scale = 1.0f;
  int otherToX = fromX - (toX - fromX);
  if (otherToX < 0) {
    scale = (float)fromX / (float)(fromX - otherToX);
    otherToX = 0;
  }
   else if (otherToX > [image width]) {
    scale = (float)([image width] - fromX) / (float)(otherToX - fromX);
    otherToX = [image width];
  }
  int otherToY = (int)(fromY - (toY - fromY) * scale);
  scale = 1.0f;
  if (otherToY < 0) {
    scale = (float)fromY / (float)(fromY - otherToY);
    otherToY = 0;
  }
   else if (otherToY > [image height]) {
    scale = (float)([image height] - fromY) / (float)(otherToY - fromY);
    otherToY = [image height];
  }
  otherToX = (int)(fromX + (otherToX - fromX) * scale);
  result += [self sizeOfBlackWhiteBlackRun:fromX fromY:fromY toX:otherToX toY:otherToY];
  return result;
}


/**
 * <p>This method traces a line from a point in the image, in the direction towards another point.
 * It begins in a black region, and keeps going until it finds white, then black, then white again.
 * It reports the distance from the start to this point.</p>
 * 
 * <p>This is used when figuring out how wide a finder pattern is, when the finder pattern
 * may be skewed or rotated.</p>
 */
- (float) sizeOfBlackWhiteBlackRun:(int)fromX fromY:(int)fromY toX:(int)toX toY:(int)toY {
  BOOL steep = [Math abs:toY - fromY] > [Math abs:toX - fromX];
  if (steep) {
    int temp = fromX;
    fromX = fromY;
    fromY = temp;
    temp = toX;
    toX = toY;
    toY = temp;
  }
  int dx = [Math abs:toX - fromX];
  int dy = [Math abs:toY - fromY];
  int error = -dx >> 1;
  int xstep = fromX < toX ? 1 : -1;
  int ystep = fromY < toY ? 1 : -1;
  int state = 0;

  for (int x = fromX, y = fromY; x != toX; x += xstep) {
    int realX = steep ? y : x;
    int realY = steep ? x : y;
    if (state == 1) {
      if ([image get:realX param1:realY]) {
        state++;
      }
    }
     else {
      if (![image get:realX param1:realY]) {
        state++;
      }
    }
    if (state == 3) {
      int diffX = x - fromX;
      int diffY = y - fromY;
      if (xstep < 0) {
        diffX++;
      }
      return (float)[Math sqrt:(double)(diffX * diffX + diffY * diffY)];
    }
    error += dy;
    if (error > 0) {
      if (y == toY) {
        break;
      }
      y += ystep;
      error -= dx;
    }
  }

  int diffX = toX - fromX;
  int diffY = toY - fromY;
  return (float)[Math sqrt:(double)(diffX * diffX + diffY * diffY)];
}


/**
 * <p>Attempts to locate an alignment pattern in a limited region of the image, which is
 * guessed to contain it. This method uses {@link AlignmentPattern}.</p>
 * 
 * @param overallEstModuleSize estimated module size so far
 * @param estAlignmentX x coordinate of center of area probably containing alignment pattern
 * @param estAlignmentY y coordinate of above
 * @param allowanceFactor number of pixels in all directions to search from the center
 * @return {@link AlignmentPattern} if found, or null otherwise
 * @throws NotFoundException if an unexpected error occurs during detection
 */
- (AlignmentPattern *) findAlignmentInRegion:(float)overallEstModuleSize estAlignmentX:(int)estAlignmentX estAlignmentY:(int)estAlignmentY allowanceFactor:(float)allowanceFactor {
  int allowance = (int)(allowanceFactor * overallEstModuleSize);
  int alignmentAreaLeftX = [Math max:0 param1:estAlignmentX - allowance];
  int alignmentAreaRightX = [Math min:[image width] - 1 param1:estAlignmentX + allowance];
  if (alignmentAreaRightX - alignmentAreaLeftX < overallEstModuleSize * 3) {
    @throw [NotFoundException notFoundInstance];
  }
  int alignmentAreaTopY = [Math max:0 param1:estAlignmentY - allowance];
  int alignmentAreaBottomY = [Math min:[image height] - 1 param1:estAlignmentY + allowance];
  if (alignmentAreaBottomY - alignmentAreaTopY < overallEstModuleSize * 3) {
    @throw [NotFoundException notFoundInstance];
  }
  AlignmentPatternFinder * alignmentFinder = [[[AlignmentPatternFinder alloc] init:image param1:alignmentAreaLeftX param2:alignmentAreaTopY param3:alignmentAreaRightX - alignmentAreaLeftX param4:alignmentAreaBottomY - alignmentAreaTopY param5:overallEstModuleSize param6:resultPointCallback] autorelease];
  return [alignmentFinder find];
}


/**
 * Ends up being a bit faster than Math.round(). This merely rounds its argument to the nearest int,
 * where x.5 rounds up.
 */
+ (int) round:(float)d {
  return (int)(d + 0.5f);
}

- (void) dealloc {
  [image release];
  [resultPointCallback release];
  [super dealloc];
}

@end
