#import "DataMatrixDetector.h"
#import "DetectorResult.h"
#import "GridSampler.h"
#import "NotFoundException.h"
#import "ResultPoint.h"
#import "WhiteRectangleDetector.h"

/**
 * Simply encapsulates two points and a number of transitions between them.
 */

@interface ResultPointsAndTransitions : NSObject {
  ResultPoint * from;
  ResultPoint * to;
  int transitions;
}

@property(nonatomic, retain, readonly) ResultPoint * from;
@property(nonatomic, retain, readonly) ResultPoint * to;
@property(nonatomic, readonly) int transitions;

- (id) init:(ResultPoint *)from to:(ResultPoint *)to transitions:(int)transitions;
- (NSComparisonResult)compare:(ResultPointsAndTransitions *)otherObject;

@end

@implementation ResultPointsAndTransitions

@synthesize from;
@synthesize to;
@synthesize transitions;

- (id) init:(ResultPoint *)aFrom to:(ResultPoint *)aTo transitions:(int)aTransitions {
  if (self = [super init]) {
    from = [aFrom retain];
    to = [aTo retain];
    transitions = aTransitions;
  }
  return self;
}

- (NSString *) description {
  return [NSString stringWithFormat:@"%@/%@/%d", from, to, transitions];
}

- (NSComparisonResult)compare:(ResultPointsAndTransitions *)otherObject {
  return [[NSNumber numberWithInt:transitions] compare:[NSNumber numberWithInt:otherObject.transitions]];
}

- (void) dealloc {
  [from release];
  [to release];
  [super dealloc];
}

@end


@interface DataMatrixDetector ()

- (ResultPoint *) correctTopRight:(ResultPoint *)bottomLeft bottomRight:(ResultPoint *)bottomRight topLeft:(ResultPoint *)topLeft topRight:(ResultPoint *)topRight dimension:(int)dimension;
- (ResultPoint *) correctTopRightRectangular:(ResultPoint *)bottomLeft bottomRight:(ResultPoint *)bottomRight topLeft:(ResultPoint *)topLeft topRight:(ResultPoint *)topRight dimensionTop:(int)dimensionTop dimensionRight:(int)dimensionRight;
- (int) distance:(ResultPoint *)a b:(ResultPoint *)b;
- (void) increment:(NSMutableDictionary *)table key:(ResultPoint *)key;
- (BOOL) isValid:(ResultPoint *)p;
- (int) round:(float)d;
- (BitMatrix *) sampleGrid:(BitMatrix *)image topLeft:(ResultPoint *)topLeft bottomLeft:(ResultPoint *)bottomLeft bottomRight:(ResultPoint *)bottomRight topRight:(ResultPoint *)topRight dimensionX:(int)dimensionX dimensionY:(int)dimensionY;
- (ResultPointsAndTransitions *) transitionsBetween:(ResultPoint *)from to:(ResultPoint *)to;

@end

@implementation DataMatrixDetector

- (id) initWithImage:(BitMatrix *)anImage {
  if (self = [super init]) {
    image = [anImage retain];
    rectangleDetector = [[[WhiteRectangleDetector alloc] initWithImage:anImage] autorelease];
  }
  return self;
}


/**
 * <p>Detects a Data Matrix Code in an image.</p>
 * 
 * @return {@link DetectorResult} encapsulating results of detecting a Data Matrix Code
 * @throws NotFoundException if no Data Matrix Code can be found
 */
- (DetectorResult *) detect {
  NSArray * cornerPoints = [rectangleDetector detect];
  ResultPoint * pointA = [cornerPoints objectAtIndex:0];
  ResultPoint * pointB = [cornerPoints objectAtIndex:1];
  ResultPoint * pointC = [cornerPoints objectAtIndex:2];
  ResultPoint * pointD = [cornerPoints objectAtIndex:3];

  NSMutableArray * transitions = [NSMutableArray arrayWithCapacity:4];
  [transitions addObject:[self transitionsBetween:pointA to:pointB]];
  [transitions addObject:[self transitionsBetween:pointA to:pointC]];
  [transitions addObject:[self transitionsBetween:pointB to:pointD]];
  [transitions addObject:[self transitionsBetween:pointC to:pointD]];
  [transitions sortUsingSelector:@selector(compare:)];

  ResultPointsAndTransitions * lSideOne = (ResultPointsAndTransitions *)[transitions objectAtIndex:0];
  ResultPointsAndTransitions * lSideTwo = (ResultPointsAndTransitions *)[transitions objectAtIndex:1];

  NSMutableDictionary * pointCount = [NSMutableDictionary dictionary];
  [self increment:pointCount key:[lSideOne from]];
  [self increment:pointCount key:[lSideOne to]];
  [self increment:pointCount key:[lSideTwo from]];
  [self increment:pointCount key:[lSideTwo to]];

  ResultPoint * maybeTopLeft = nil;
  ResultPoint * bottomLeft = nil;
  ResultPoint * maybeBottomRight = nil;
  for (ResultPoint * point in [pointCount allKeys]) {
    NSNumber * value = [pointCount objectForKey:point];
    if ([value intValue] == 2) {
      bottomLeft = point;
    } else {
      if (maybeTopLeft == nil) {
        maybeTopLeft = point;
      } else {
        maybeBottomRight = point;
      }
    }
  }

  if (maybeTopLeft == nil || bottomLeft == nil || maybeBottomRight == nil) {
    @throw [NotFoundException notFoundInstance];
  }

  NSMutableArray * corners = [NSMutableArray arrayWithObjects:maybeTopLeft, bottomLeft, maybeBottomRight, nil];
  [ResultPoint orderBestPatterns:corners];

  ResultPoint * bottomRight = [corners objectAtIndex:0];
  bottomLeft = [corners objectAtIndex:1];
  ResultPoint * topLeft = [corners objectAtIndex:2];

  ResultPoint * topRight;
  if (![pointCount objectForKey:pointA]) {
    topRight = pointA;
  } else if (![pointCount objectForKey:pointB]) {
    topRight = pointB;
  } else if (![pointCount objectForKey:pointC]) {
    topRight = pointC;
  } else {
    topRight = pointD;
  }

  int dimensionTop = [[self transitionsBetween:topLeft to:topRight] transitions];
  int dimensionRight = [[self transitionsBetween:bottomRight to:topRight] transitions];

  if ((dimensionTop & 0x01) == 1) {
    dimensionTop++;
  }
  dimensionTop += 2;

  if ((dimensionRight & 0x01) == 1) {
    dimensionRight++;
  }
  dimensionRight += 2;

  BitMatrix * bits;
  ResultPoint * correctedTopRight;

  if (4 * dimensionTop >= 7 * dimensionRight || 4 * dimensionRight >= 7 * dimensionTop) {
    correctedTopRight = [self correctTopRightRectangular:bottomLeft bottomRight:bottomRight topLeft:topLeft topRight:topRight dimensionTop:dimensionTop dimensionRight:dimensionRight];
    if (correctedTopRight == nil) {
      correctedTopRight = topRight;
    }

    dimensionTop = [[self transitionsBetween:topLeft to:correctedTopRight] transitions];
    dimensionRight = [[self transitionsBetween:bottomRight to:correctedTopRight] transitions];

    if ((dimensionTop & 0x01) == 1) {
      dimensionTop++;
    }

    if ((dimensionRight & 0x01) == 1) {
      dimensionRight++;
    }

    bits = [self sampleGrid:image topLeft:topLeft bottomLeft:bottomLeft bottomRight:bottomRight topRight:correctedTopRight dimensionX:dimensionTop dimensionY:dimensionRight];
  } else {
    int dimension = MIN(dimensionRight, dimensionTop);
    correctedTopRight = [self correctTopRight:bottomLeft bottomRight:bottomRight topLeft:topLeft topRight:topRight dimension:dimension];
    if (correctedTopRight == nil) {
      correctedTopRight = topRight;
    }

    int dimensionCorrected = MAX([[self transitionsBetween:topLeft to:correctedTopRight] transitions], [[self transitionsBetween:bottomRight to:correctedTopRight] transitions]);
    dimensionCorrected++;
    if ((dimensionCorrected & 0x01) == 1) {
      dimensionCorrected++;
    }

    bits = [self sampleGrid:image topLeft:topLeft bottomLeft:bottomLeft bottomRight:bottomRight topRight:correctedTopRight dimensionX:dimensionCorrected dimensionY:dimensionCorrected];
  }
  return [[[DetectorResult alloc] initWithBits:bits
                                        points:[NSArray arrayWithObjects:topLeft, bottomLeft, bottomRight, correctedTopRight, nil]] autorelease];
}


/**
 * Calculates the position of the white top right module using the output of the rectangle detector
 * for a rectangular matrix
 */
- (ResultPoint *) correctTopRightRectangular:(ResultPoint *)bottomLeft bottomRight:(ResultPoint *)bottomRight topLeft:(ResultPoint *)topLeft topRight:(ResultPoint *)topRight dimensionTop:(int)dimensionTop dimensionRight:(int)dimensionRight {
  float corr = [self distance:bottomLeft b:bottomRight] / (float)dimensionTop;
  int norm = [self distance:topLeft b:topRight];
  float cos = ([topRight x] - [topLeft x]) / norm;
  float sin = ([topRight y] - [topLeft y]) / norm;

  ResultPoint * c1 = [[[ResultPoint alloc] initWithX:[topRight x] + corr * cos y:[topRight y] + corr * sin] autorelease];

  corr = [self distance:bottomLeft b:topLeft] / (float)dimensionRight;
  norm = [self distance:bottomRight b:topRight];
  cos = ([topRight x] - [bottomRight x]) / norm;
  sin = ([topRight y] - [bottomRight y]) / norm;

  ResultPoint * c2 = [[[ResultPoint alloc] initWithX:[topRight x] + corr * cos y:[topRight y] + corr * sin] autorelease];

  if (![self isValid:c1]) {
    if ([self isValid:c2]) {
      return c2;
    }
    return nil;
  } else if (![self isValid:c2]) {
    return c1;
  }

  int l1 = abs(dimensionTop - [[self transitionsBetween:topLeft to:c1] transitions]) + abs(dimensionRight - [[self transitionsBetween:bottomRight to:c1] transitions]);
  int l2 = abs(dimensionTop - [[self transitionsBetween:topLeft to:c2] transitions]) + abs(dimensionRight - [[self transitionsBetween:bottomRight to:c2] transitions]);

  if (l1 <= l2) {
    return c1;
  }

  return c2;
}


/**
 * Calculates the position of the white top right module using the output of the rectangle detector
 * for a square matrix
 */
- (ResultPoint *) correctTopRight:(ResultPoint *)bottomLeft bottomRight:(ResultPoint *)bottomRight topLeft:(ResultPoint *)topLeft topRight:(ResultPoint *)topRight dimension:(int)dimension {
  float corr = [self distance:bottomLeft b:bottomRight] / (float)dimension;
  int norm = [self distance:topLeft b:topRight];
  float cos = ([topRight x] - [topLeft x]) / norm;
  float sin = ([topRight y] - [topLeft y]) / norm;

  ResultPoint * c1 = [[[ResultPoint alloc] initWithX:[topRight x] + corr * cos y:[topRight y] + corr * sin] autorelease];

  corr = [self distance:bottomLeft b:bottomRight] / (float)dimension;
  norm = [self distance:bottomRight b:topRight];
  cos = ([topRight x] - [bottomRight x]) / norm;
  sin = ([topRight y] - [bottomRight y]) / norm;

  ResultPoint * c2 = [[[ResultPoint alloc] initWithX:[topRight x] + corr * cos y:[topRight y] + corr * sin] autorelease];

  if (![self isValid:c1]) {
    if ([self isValid:c2]) {
      return c2;
    }
    return nil;
  } else if (![self isValid:c2]) {
    return c1;
  }

  int l1 = abs([[self transitionsBetween:topLeft to:c1] transitions] - [[self transitionsBetween:bottomRight to:c1] transitions]);
  int l2 = abs([[self transitionsBetween:topLeft to:c2] transitions] - [[self transitionsBetween:bottomRight to:c2] transitions]);

  return l1 <= l2 ? c1 : c2;
}

- (BOOL) isValid:(ResultPoint *)p {
  return [p x] >= 0 && [p x] < image.width && [p y] > 0 && [p y] < image.height;
}


/**
 * Ends up being a bit faster than Math.round(). This merely rounds its
 * argument to the nearest int, where x.5 rounds up.
 */
- (int) round:(float)d {
  return (int)(d + 0.5f);
}

- (int) distance:(ResultPoint *)a b:(ResultPoint *)b {
  return [self round:(float)sqrt(([a x] - [b x]) * ([a x] - [b x]) + ([a y] - [b y]) * ([a y] - [b y]))];
}


/**
 * Increments the Integer associated with a key by one.
 */
- (void) increment:(NSMutableDictionary *)table key:(ResultPoint *)key {
  NSNumber * value = [table objectForKey:key];
  [table setObject:value == nil ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:[value intValue] + 1] forKey:key];
}

- (BitMatrix *) sampleGrid:(BitMatrix *)anImage topLeft:(ResultPoint *)topLeft bottomLeft:(ResultPoint *)bottomLeft bottomRight:(ResultPoint *)bottomRight topRight:(ResultPoint *)topRight dimensionX:(int)dimensionX dimensionY:(int)dimensionY {
  GridSampler * sampler = [GridSampler instance];
  return [sampler sampleGrid:anImage
                  dimensionX:dimensionX dimensionY:dimensionY
                       p1ToX:0.5f p1ToY:0.5f
                       p2ToX:dimensionX - 0.5f p2ToY:0.5f
                       p3ToX:dimensionX - 0.5f p3ToY:dimensionY - 0.5f
                       p4ToX:0.5f p4ToY:dimensionY - 0.5f
                     p1FromX:[topLeft x] p1FromY:[topLeft y]
                     p2FromX:[topRight x] p2FromY:[topRight y]
                     p3FromX:[bottomRight x] p3FromY:[bottomRight y]
                     p4FromX:[bottomLeft x] p4FromY:[bottomLeft y]];
}


/**
 * Counts the number of black/white transitions between two points, using something like Bresenham's algorithm.
 */
- (ResultPointsAndTransitions *) transitionsBetween:(ResultPoint *)from to:(ResultPoint *)to {
  int fromX = (int)[from x];
  int fromY = (int)[from y];
  int toX = (int)[to x];
  int toY = (int)[to y];
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
  int ystep = fromY < toY ? 1 : -1;
  int xstep = fromX < toX ? 1 : -1;
  int transitions = 0;
  BOOL inBlack = [image get:steep ? fromY : fromX y:steep ? fromX : fromY];
  for (int x = fromX, y = fromY; x != toX; x += xstep) {
    BOOL isBlack = [image get:steep ? y : x y:steep ? x : y];
    if (isBlack != inBlack) {
      transitions++;
      inBlack = isBlack;
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
  return [[[ResultPointsAndTransitions alloc] init:from to:to transitions:transitions] autorelease];
}

- (void) dealloc {
  [image release];
  [rectangleDetector release];
  [super dealloc];
}

@end
