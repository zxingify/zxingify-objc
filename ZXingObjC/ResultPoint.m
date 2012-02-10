#import "ResultPoint.h"

@interface ResultPoint ()

+ (float) crossProductZ:(ResultPoint *)pointA pointB:(ResultPoint *)pointB pointC:(ResultPoint *)pointC;

@end

@implementation ResultPoint

@synthesize x;
@synthesize y;

- (id) initWithX:(float)anX y:(float)aY {
  if (self = [super init]) {
    x = anX;
    y = aY;
  }
  return self;
}

- (BOOL) isEqual:(id)other {
  if ([other isKindOfClass:[ResultPoint class]]) {
    ResultPoint * otherPoint = (ResultPoint *)other;
    return x == otherPoint.x && y == otherPoint.y;
  }
  return NO;
}

- (NSUInteger) hash {
  return 31 * *((int*)(&x)) + *((int*)(&y));
}

- (NSString *) description {
  return [NSString stringWithFormat:@"(%f,%f)", x, y];
}


/**
 * <p>Orders an array of three ResultPoints in an order [A,B,C] such that AB < AC and
 * BC < AC and the angle between BC and BA is less than 180 degrees.
 */
+ (void) orderBestPatterns:(NSMutableArray *)patterns {
  float zeroOneDistance = [self distance:[patterns objectAtIndex:0] pattern2:[patterns objectAtIndex:1]];
  float oneTwoDistance = [self distance:[patterns objectAtIndex:1] pattern2:[patterns objectAtIndex:2]];
  float zeroTwoDistance = [self distance:[patterns objectAtIndex:0] pattern2:[patterns objectAtIndex:2]];
  ResultPoint * pointA;
  ResultPoint * pointB;
  ResultPoint * pointC;
  if (oneTwoDistance >= zeroOneDistance && oneTwoDistance >= zeroTwoDistance) {
    pointB = [patterns objectAtIndex:0];
    pointA = [patterns objectAtIndex:1];
    pointC = [patterns objectAtIndex:2];
  } else if (zeroTwoDistance >= oneTwoDistance && zeroTwoDistance >= zeroOneDistance) {
    pointB = [patterns objectAtIndex:1];
    pointA = [patterns objectAtIndex:0];
    pointC = [patterns objectAtIndex:2];
  } else {
    pointB = [patterns objectAtIndex:2];
    pointA = [patterns objectAtIndex:0];
    pointC = [patterns objectAtIndex:1];
  }

  if ([self crossProductZ:pointA pointB:pointB pointC:pointC] < 0.0f) {
    ResultPoint * temp = pointA;
    pointA = pointC;
    pointC = temp;
  }
  [patterns replaceObjectAtIndex:0 withObject:pointA];
  [patterns replaceObjectAtIndex:1 withObject:pointB];
  [patterns replaceObjectAtIndex:2 withObject:pointC];
}


/**
 * @return distance between two points
 */
+ (float) distance:(ResultPoint *)pattern1 pattern2:(ResultPoint *)pattern2 {
  float xDiff = [pattern1 x] - [pattern2 x];
  float yDiff = [pattern1 y] - [pattern2 y];
  return sqrtf(xDiff * xDiff + yDiff * yDiff);
}


/**
 * Returns the z component of the cross product between vectors BC and BA.
 */
+ (float) crossProductZ:(ResultPoint *)pointA pointB:(ResultPoint *)pointB pointC:(ResultPoint *)pointC {
  float bX = pointB.x;
  float bY = pointB.y;
  return ((pointC.x - bX) * (pointA.y - bY)) - ((pointC.y - bY) * (pointA.x - bX));
}

@end
