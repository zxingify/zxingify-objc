#import "ZXAlignmentPattern.h"
#import "ZXAlignmentPatternFinder.h"
#import "ZXBitMatrix.h"
#import "ZXDecodeHints.h"
#import "ZXDetectorResult.h"
#import "ZXErrors.h"
#import "ZXFinderPatternFinder.h"
#import "ZXFinderPatternInfo.h"
#import "ZXGridSampler.h"
#import "ZXPerspectiveTransform.h"
#import "ZXQRCodeDetector.h"
#import "ZXQRCodeFinderPattern.h"
#import "ZXQRCodeVersion.h"
#import "ZXResultPoint.h"
#import "ZXResultPointCallback.h"

@interface ZXQRCodeDetector ()

@property (nonatomic, retain) ZXBitMatrix * image;
@property (nonatomic, assign) id <ZXResultPointCallback> resultPointCallback;

- (float)calculateModuleSizeOneWay:(ZXResultPoint *)pattern otherPattern:(ZXResultPoint *)otherPattern;
+ (int)round:(float)d;
- (ZXBitMatrix *)sampleGrid:(ZXBitMatrix *)image transform:(ZXPerspectiveTransform *)transform dimension:(int)dimension error:(NSError**)error;
- (float)sizeOfBlackWhiteBlackRun:(int)fromX fromY:(int)fromY toX:(int)toX toY:(int)toY;
- (float)sizeOfBlackWhiteBlackRunBothWays:(int)fromX fromY:(int)fromY toX:(int)toX toY:(int)toY;

@end

@implementation ZXQRCodeDetector

@synthesize image;
@synthesize resultPointCallback;

- (id)initWithImage:(ZXBitMatrix *)anImage {
  if (self = [super init]) {
    self.image = anImage;
  }

  return self;
}

- (void)dealloc {
  [image release];

  [super dealloc];
}


/**
 * Detects a QR Code in an image, simply.
 */
- (ZXDetectorResult *)detectWithError:(NSError **)error {
  return [self detect:nil error:error];
}


/**
 * Detects a QR Code in an image, simply.
 */
- (ZXDetectorResult *)detect:(ZXDecodeHints *)hints error:(NSError **)error {
  self.resultPointCallback = hints == nil ? nil : hints.resultPointCallback;

  ZXFinderPatternFinder * finder = [[[ZXFinderPatternFinder alloc] initWithImage:image resultPointCallback:resultPointCallback] autorelease];
  ZXFinderPatternInfo * info = [finder find:hints error:error];
  if (!info) {
    return nil;
  }

  return [self processFinderPatternInfo:info error:error];
}

- (ZXDetectorResult *)processFinderPatternInfo:(ZXFinderPatternInfo *)info error:(NSError**)error {
  ZXQRCodeFinderPattern * topLeft = info.topLeft;
  ZXQRCodeFinderPattern * topRight = info.topRight;
  ZXQRCodeFinderPattern * bottomLeft = info.bottomLeft;

  float moduleSize = [self calculateModuleSize:topLeft topRight:topRight bottomLeft:bottomLeft];
  if (moduleSize < 1.0f) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }
  int dimension = [ZXQRCodeDetector computeDimension:topLeft topRight:topRight bottomLeft:bottomLeft moduleSize:moduleSize error:error];
  if (dimension == -1) {
    return nil;
  }

  ZXQRCodeVersion * provisionalVersion = [ZXQRCodeVersion provisionalVersionForDimension:dimension];
  if (!provisionalVersion) {
    if (error) *error = FormatErrorInstance();
    return nil;
  }
  int modulesBetweenFPCenters = [provisionalVersion dimensionForVersion] - 7;

  ZXAlignmentPattern * alignmentPattern = nil;
  if ([[provisionalVersion alignmentPatternCenters] count] > 0) {
    float bottomRightX = [topRight x] - [topLeft x] + [bottomLeft x];
    float bottomRightY = [topRight y] - [topLeft y] + [bottomLeft y];

    float correctionToTopLeft = 1.0f - 3.0f / (float)modulesBetweenFPCenters;
    int estAlignmentX = (int)([topLeft x] + correctionToTopLeft * (bottomRightX - [topLeft x]));
    int estAlignmentY = (int)([topLeft y] + correctionToTopLeft * (bottomRightY - [topLeft y]));

    for (int i = 4; i <= 16; i <<= 1) {
      NSError* alignmentError = nil;
      alignmentPattern = [self findAlignmentInRegion:moduleSize estAlignmentX:estAlignmentX estAlignmentY:estAlignmentY allowanceFactor:(float)i error:&alignmentError];
      if (alignmentPattern) {
        break;
      } else if (alignmentError.code != ZXNotFoundError) {
        if (error) *error = alignmentError;
        return nil;
      }
    }
  }

  ZXPerspectiveTransform * transform = [ZXQRCodeDetector createTransform:topLeft topRight:topRight bottomLeft:bottomLeft alignmentPattern:alignmentPattern dimension:dimension];
  ZXBitMatrix * bits = [self sampleGrid:image transform:transform dimension:dimension error:error];
  if (!bits) {
    return nil;
  }
  NSArray * points;
  if (alignmentPattern == nil) {
    points = [NSArray arrayWithObjects:bottomLeft, topLeft, topRight, nil];
  } else {
    points = [NSArray arrayWithObjects:bottomLeft, topLeft, topRight, alignmentPattern, nil];
  }
  return [[[ZXDetectorResult alloc] initWithBits:bits points:points] autorelease];
}

+ (ZXPerspectiveTransform *)createTransform:(ZXResultPoint *)topLeft topRight:(ZXResultPoint *)topRight bottomLeft:(ZXResultPoint *)bottomLeft alignmentPattern:(ZXResultPoint *)alignmentPattern dimension:(int)dimension {
  float dimMinusThree = (float)dimension - 3.5f;
  float bottomRightX;
  float bottomRightY;
  float sourceBottomRightX;
  float sourceBottomRightY;
  if (alignmentPattern != nil) {
    bottomRightX = alignmentPattern.x;
    bottomRightY = alignmentPattern.y;
    sourceBottomRightX = sourceBottomRightY = dimMinusThree - 3.0f;
  } else {
    bottomRightX = (topRight.x - topLeft.x) + bottomLeft.x;
    bottomRightY = (topRight.y - topLeft.y) + bottomLeft.y;
    sourceBottomRightX = sourceBottomRightY = dimMinusThree;
  }
  return [ZXPerspectiveTransform quadrilateralToQuadrilateral:3.5f y0:3.5f
                                                           x1:dimMinusThree y1:3.5f
                                                           x2:sourceBottomRightX y2:sourceBottomRightY
                                                           x3:3.5f y3:dimMinusThree
                                                          x0p:topLeft.x y0p:topLeft.y
                                                          x1p:topRight.x y1p:topRight.y
                                                          x2p:bottomRightX y2p:bottomRightY
                                                          x3p:bottomLeft.x y3p:bottomLeft.y];
}

- (ZXBitMatrix *)sampleGrid:(ZXBitMatrix *)anImage transform:(ZXPerspectiveTransform *)transform dimension:(int)dimension error:(NSError **)error {
  ZXGridSampler * sampler = [ZXGridSampler instance];
  return [sampler sampleGrid:anImage dimensionX:dimension dimensionY:dimension transform:transform error:error];
}


/**
 * Computes the dimension (number of modules on a size) of the QR Code based on the position
 * of the finder patterns and estimated module size. Returns -1 on an error.
 */
+ (int)computeDimension:(ZXResultPoint *)topLeft topRight:(ZXResultPoint *)topRight bottomLeft:(ZXResultPoint *)bottomLeft moduleSize:(float)moduleSize error:(NSError**)error {
  int tltrCentersDimension = [ZXQRCodeDetector round:[ZXResultPoint distance:topLeft pattern2:topRight] / moduleSize];
  int tlblCentersDimension = [ZXQRCodeDetector round:[ZXResultPoint distance:topLeft pattern2:bottomLeft] / moduleSize];
  int dimension = ((tltrCentersDimension + tlblCentersDimension) >> 1) + 7;

  switch (dimension & 0x03) {
  case 0:
    dimension++;
    break;
  case 2:
    dimension--;
    break;
  case 3:
    if (error) *error = NotFoundErrorInstance();
    return -1;
  }
  return dimension;
}


/**
 * Computes an average estimated module size based on estimated derived from the positions
 * of the three finder patterns.
 */
- (float)calculateModuleSize:(ZXResultPoint *)topLeft topRight:(ZXResultPoint *)topRight bottomLeft:(ZXResultPoint *)bottomLeft {
  return ([self calculateModuleSizeOneWay:topLeft otherPattern:topRight] + [self calculateModuleSizeOneWay:topLeft otherPattern:bottomLeft]) / 2.0f;
}


- (float)calculateModuleSizeOneWay:(ZXResultPoint *)pattern otherPattern:(ZXResultPoint *)otherPattern {
  float moduleSizeEst1 = [self sizeOfBlackWhiteBlackRunBothWays:(int)[pattern x] fromY:(int)[pattern y] toX:(int)[otherPattern x] toY:(int)[otherPattern y]];
  float moduleSizeEst2 = [self sizeOfBlackWhiteBlackRunBothWays:(int)[otherPattern x] fromY:(int)[otherPattern y] toX:(int)[pattern x] toY:(int)[pattern y]];
  if (isnan(moduleSizeEst1)) {
    return moduleSizeEst2 / 7.0f;
  }
  if (isnan(moduleSizeEst2)) {
    return moduleSizeEst1 / 7.0f;
  }
  return (moduleSizeEst1 + moduleSizeEst2) / 14.0f;
}


- (float)sizeOfBlackWhiteBlackRunBothWays:(int)fromX fromY:(int)fromY toX:(int)toX toY:(int)toY {
  float result = [self sizeOfBlackWhiteBlackRun:fromX fromY:fromY toX:toX toY:toY];
  float scale = 1.0f;
  int otherToX = fromX - (toX - fromX);
  if (otherToX < 0) {
    scale = (float)fromX / (float)(fromX - otherToX);
    otherToX = 0;
  } else if (otherToX > self.image.width) {
    scale = (float)(self.image.width - fromX) / (float)(otherToX - fromX);
    otherToX = self.image.width;
  }
  int otherToY = (int)(fromY - (toY - fromY) * scale);

  scale = 1.0f;
  if (otherToY < 0) {
    scale = (float)fromY / (float)(fromY - otherToY);
    otherToY = 0;
  }
   else if (otherToY > self.image.height) {
    scale = (float)(self.image.height - fromY) / (float)(otherToY - fromY);
    otherToY = self.image.height;
  }
  otherToX = (int)(fromX + (otherToX - fromX) * scale);

  result += [self sizeOfBlackWhiteBlackRun:fromX fromY:fromY toX:otherToX toY:otherToY];
  return result;
}


/**
 * This method traces a line from a point in the image, in the direction towards another point.
 * It begins in a black region, and keeps going until it finds white, then black, then white again.
 * It reports the distance from the start to this point.
 * 
 * This is used when figuring out how wide a finder pattern is, when the finder pattern
 * may be skewed or rotated.
 */
- (float)sizeOfBlackWhiteBlackRun:(int)fromX fromY:(int)fromY toX:(int)toX toY:(int)toY {
  BOOL steep = abs(toY - fromY) > abs(toX - fromX);
  if (steep) {
    int temp = fromX;
    fromX = fromY;
    fromY = temp;
    temp = toX;
    toX = toY;
    toY = temp;
  }

  int dx = abs(toX - fromX);
  int dy = abs(toY - fromY);
  int error = -dx >> 1;
  int xstep = fromX < toX ? 1 : -1;
  int ystep = fromY < toY ? 1 : -1;

  int state = 0;
  for (int x = fromX, y = fromY; x != toX; x += xstep) {
    int realX = steep ? y : x;
    int realY = steep ? x : y;

    if (state == 1) {
      if ([self.image getX:realX y:realY]) {
        state++;
      }
    } else {
      if (![self.image getX:realX y:realY]) {
        state++;
      }
    }

    if (state == 3) {
      int diffX = x - fromX;
      int diffY = y - fromY;
      if (xstep < 0) {
        diffX++;
      }
      return (float)sqrt((double)(diffX * diffX + diffY * diffY));
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
  return (float)sqrt((double)(diffX * diffX + diffY * diffY));
}


/**
 * Attempts to locate an alignment pattern in a limited region of the image, which is
 * guessed to contain it. This method uses ZXAlignmentPattern.
 */
- (ZXAlignmentPattern *)findAlignmentInRegion:(float)overallEstModuleSize estAlignmentX:(int)estAlignmentX estAlignmentY:(int)estAlignmentY allowanceFactor:(float)allowanceFactor error:(NSError **)error {
  int allowance = (int)(allowanceFactor * overallEstModuleSize);
  int alignmentAreaLeftX = MAX(0, estAlignmentX - allowance);
  int alignmentAreaRightX = MIN(self.image.width - 1, estAlignmentX + allowance);
  if (alignmentAreaRightX - alignmentAreaLeftX < overallEstModuleSize * 3) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  int alignmentAreaTopY = MAX(0, estAlignmentY - allowance);
  int alignmentAreaBottomY = MIN(self.image.height - 1, estAlignmentY + allowance);
  if (alignmentAreaBottomY - alignmentAreaTopY < overallEstModuleSize * 3) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  ZXAlignmentPatternFinder * alignmentFinder = [[[ZXAlignmentPatternFinder alloc] initWithImage:self.image
                                                                                         startX:alignmentAreaLeftX
                                                                                         startY:alignmentAreaTopY
                                                                                          width:alignmentAreaRightX - alignmentAreaLeftX
                                                                                         height:alignmentAreaBottomY - alignmentAreaTopY
                                                                                     moduleSize:overallEstModuleSize
                                                                            resultPointCallback:self.resultPointCallback] autorelease];
  return [alignmentFinder findWithError:error];
}


/**
 * Ends up being a bit faster than Math.round(). This merely rounds its argument to the nearest int,
 * where x.5 rounds up.
 */
+ (int)round:(float)d {
  return (int)(d + 0.5f);
}

@end
