#import "Detector.h"

@implementation ResultPointsAndTransitions

@synthesize from;
@synthesize to;
@synthesize transitions;

- (id) init:(ResultPoint *)from to:(ResultPoint *)to transitions:(int)transitions {
  if (self = [super init]) {
    from = from;
    to = to;
    transitions = transitions;
  }
  return self;
}

- (NSString *) description {
  return [from stringByAppendingString:@"/"] + to + '/' + transitions;
}

- (void) dealloc {
  [from release];
  [to release];
  [super dealloc];
}

@end

@implementation ResultPointsAndTransitionsComparator

- (int) compare:(NSObject *)o1 o2:(NSObject *)o2 {
  return [((ResultPointsAndTransitions *)o1) transitions] - [((ResultPointsAndTransitions *)o2) transitions];
}

@end

NSArray * const INTEGERS = [NSArray arrayWithObjects:[[[NSNumber alloc] init:0] autorelease], [[[NSNumber alloc] init:1] autorelease], [[[NSNumber alloc] init:2] autorelease], [[[NSNumber alloc] init:3] autorelease], [[[NSNumber alloc] init:4] autorelease], nil];

@implementation Detector

- (id) initWithImage:(BitMatrix *)image {
  if (self = [super init]) {
    image = image;
    rectangleDetector = [[[WhiteRectangleDetector alloc] init:image] autorelease];
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
  ResultPoint * pointA = cornerPoints[0];
  ResultPoint * pointB = cornerPoints[1];
  ResultPoint * pointC = cornerPoints[2];
  ResultPoint * pointD = cornerPoints[3];
  NSMutableArray * transitions = [[[NSMutableArray alloc] init:4] autorelease];
  [transitions addObject:[self transitionsBetween:pointA to:pointB]];
  [transitions addObject:[self transitionsBetween:pointA to:pointC]];
  [transitions addObject:[self transitionsBetween:pointB to:pointD]];
  [transitions addObject:[self transitionsBetween:pointC to:pointD]];
  [Collections insertionSort:transitions param1:[[[ResultPointsAndTransitionsComparator alloc] init] autorelease]];
  ResultPointsAndTransitions * lSideOne = (ResultPointsAndTransitions *)[transitions objectAtIndex:0];
  ResultPointsAndTransitions * lSideTwo = (ResultPointsAndTransitions *)[transitions objectAtIndex:1];
  NSMutableDictionary * pointCount = [[[NSMutableDictionary alloc] init] autorelease];
  [self increment:pointCount key:[lSideOne from]];
  [self increment:pointCount key:[lSideOne to]];
  [self increment:pointCount key:[lSideTwo from]];
  [self increment:pointCount key:[lSideTwo to]];
  ResultPoint * maybeTopLeft = nil;
  ResultPoint * bottomLeft = nil;
  ResultPoint * maybeBottomRight = nil;
  NSEnumerator * points = [pointCount keys];

  while ([points hasMoreElements]) {
    ResultPoint * point = (ResultPoint *)[points nextObject];
    NSNumber * value = (NSNumber *)[pointCount objectForKey:point];
    if ([value intValue] == 2) {
      bottomLeft = point;
    }
     else {
      if (maybeTopLeft == nil) {
        maybeTopLeft = point;
      }
       else {
        maybeBottomRight = point;
      }
    }
  }

  if (maybeTopLeft == nil || bottomLeft == nil || maybeBottomRight == nil) {
    @throw [NotFoundException notFoundInstance];
  }
  NSArray * corners = [NSArray arrayWithObjects:maybeTopLeft, bottomLeft, maybeBottomRight, nil];
  [ResultPoint orderBestPatterns:corners];
  ResultPoint * bottomRight = corners[0];
  bottomLeft = corners[1];
  ResultPoint * topLeft = corners[2];
  ResultPoint * topRight;
  if (![pointCount containsKey:pointA]) {
    topRight = pointA;
  }
   else if (![pointCount containsKey:pointB]) {
    topRight = pointB;
  }
   else if (![pointCount containsKey:pointC]) {
    topRight = pointC;
  }
   else {
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
  }
   else {
    int dimension = [Math min:dimensionRight param1:dimensionTop];
    correctedTopRight = [self correctTopRight:bottomLeft bottomRight:bottomRight topLeft:topLeft topRight:topRight dimension:dimension];
    if (correctedTopRight == nil) {
      correctedTopRight = topRight;
    }
    int dimensionCorrected = [Math max:[[self transitionsBetween:topLeft to:correctedTopRight] transitions] param1:[[self transitionsBetween:bottomRight to:correctedTopRight] transitions]];
    dimensionCorrected++;
    if ((dimensionCorrected & 0x01) == 1) {
      dimensionCorrected++;
    }
    bits = [self sampleGrid:image topLeft:topLeft bottomLeft:bottomLeft bottomRight:bottomRight topRight:correctedTopRight dimensionX:dimensionCorrected dimensionY:dimensionCorrected];
  }
  return [[[DetectorResult alloc] init:bits param1:[NSArray arrayWithObjects:topLeft, bottomLeft, bottomRight, correctedTopRight, nil]] autorelease];
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
  ResultPoint * c1 = [[[ResultPoint alloc] init:[topRight x] + corr * cos param1:[topRight y] + corr * sin] autorelease];
  corr = [self distance:bottomLeft b:topLeft] / (float)dimensionRight;
  norm = [self distance:bottomRight b:topRight];
  cos = ([topRight x] - [bottomRight x]) / norm;
  sin = ([topRight y] - [bottomRight y]) / norm;
  ResultPoint * c2 = [[[ResultPoint alloc] init:[topRight x] + corr * cos param1:[topRight y] + corr * sin] autorelease];
  if (![self isValid:c1]) {
    if ([self isValid:c2]) {
      return c2;
    }
    return nil;
  }
   else if (![self isValid:c2]) {
    return c1;
  }
  int l1 = [Math abs:dimensionTop - [[self transitionsBetween:topLeft to:c1] transitions]] + [Math abs:dimensionRight - [[self transitionsBetween:bottomRight to:c1] transitions]];
  int l2 = [Math abs:dimensionTop - [[self transitionsBetween:topLeft to:c2] transitions]] + [Math abs:dimensionRight - [[self transitionsBetween:bottomRight to:c2] transitions]];
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
  ResultPoint * c1 = [[[ResultPoint alloc] init:[topRight x] + corr * cos param1:[topRight y] + corr * sin] autorelease];
  corr = [self distance:bottomLeft b:bottomRight] / (float)dimension;
  norm = [self distance:bottomRight b:topRight];
  cos = ([topRight x] - [bottomRight x]) / norm;
  sin = ([topRight y] - [bottomRight y]) / norm;
  ResultPoint * c2 = [[[ResultPoint alloc] init:[topRight x] + corr * cos param1:[topRight y] + corr * sin] autorelease];
  if (![self isValid:c1]) {
    if ([self isValid:c2]) {
      return c2;
    }
    return nil;
  }
   else if (![self isValid:c2]) {
    return c1;
  }
  int l1 = [Math abs:[[self transitionsBetween:topLeft to:c1] transitions] - [[self transitionsBetween:bottomRight to:c1] transitions]];
  int l2 = [Math abs:[[self transitionsBetween:topLeft to:c2] transitions] - [[self transitionsBetween:bottomRight to:c2] transitions]];
  return l1 <= l2 ? c1 : c2;
}

- (BOOL) isValid:(ResultPoint *)p {
  return [p x] >= 0 && [p x] < image.width && [p y] > 0 && [p y] < image.height;
}


/**
 * Ends up being a bit faster than Math.round(). This merely rounds its
 * argument to the nearest int, where x.5 rounds up.
 */
+ (int) round:(float)d {
  return (int)(d + 0.5f);
}

+ (int) distance:(ResultPoint *)a b:(ResultPoint *)b {
  return [self round:(float)[Math sqrt:([a x] - [b x]) * ([a x] - [b x]) + ([a y] - [b y]) * ([a y] - [b y])]];
}


/**
 * Increments the Integer associated with a key by one.
 */
+ (void) increment:(NSMutableDictionary *)table key:(ResultPoint *)key {
  NSNumber * value = (NSNumber *)[table objectForKey:key];
  [table setObject:key param1:value == nil ? INTEGERS[1] : INTEGERS[[value intValue] + 1]];
}

+ (BitMatrix *) sampleGrid:(BitMatrix *)image topLeft:(ResultPoint *)topLeft bottomLeft:(ResultPoint *)bottomLeft bottomRight:(ResultPoint *)bottomRight topRight:(ResultPoint *)topRight dimensionX:(int)dimensionX dimensionY:(int)dimensionY {
  GridSampler * sampler = [GridSampler instance];
  return [sampler sampleGrid:image param1:dimensionX param2:dimensionY param3:0.5f param4:0.5f param5:dimensionX - 0.5f param6:0.5f param7:dimensionX - 0.5f param8:dimensionY - 0.5f param9:0.5f param10:dimensionY - 0.5f param11:[topLeft x] param12:[topLeft y] param13:[topRight x] param14:[topRight y] param15:[bottomRight x] param16:[bottomRight y] param17:[bottomLeft x] param18:[bottomLeft y]];
}


/**
 * Counts the number of black/white transitions between two points, using something like Bresenham's algorithm.
 */
- (ResultPointsAndTransitions *) transitionsBetween:(ResultPoint *)from to:(ResultPoint *)to {
  int fromX = (int)[from x];
  int fromY = (int)[from y];
  int toX = (int)[to x];
  int toY = (int)[to y];
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
  int ystep = fromY < toY ? 1 : -1;
  int xstep = fromX < toX ? 1 : -1;
  int transitions = 0;
  BOOL inBlack = [image get:steep ? fromY : fromX param1:steep ? fromX : fromY];

  for (int x = fromX, y = fromY; x != toX; x += xstep) {
    BOOL isBlack = [image get:steep ? y : x param1:steep ? x : y];
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

  return [[[ResultPointsAndTransitions alloc] init:from param1:to param2:transitions] autorelease];
}

- (void) dealloc {
  [image release];
  [rectangleDetector release];
  [super dealloc];
}

@end
