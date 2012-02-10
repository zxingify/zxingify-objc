#import "ResultPoint.h"

@implementation ResultPoint

@synthesize x;
@synthesize y;

- (id) initWithX:(float)x y:(float)y {
  if (self = [super init]) {
    x = x;
    y = y;
  }
  return self;
}

- (BOOL) isEqualTo:(NSObject *)other {
  if ([other conformsToProtocol:@protocol(ResultPoint)]) {
    ResultPoint * otherPoint = (ResultPoint *)other;
    return x == otherPoint.x && y == otherPoint.y;
  }
  return NO;
}

- (int) hash {
  return 31 * [Float floatToIntBits:x] + [Float floatToIntBits:y];
}

- (NSString *) description {
  NSMutableString * result = [[[NSMutableString alloc] init:25] autorelease];
  [result append:'('];
  [result append:x];
  [result append:','];
  [result append:y];
  [result append:')'];
  return [result description];
}


/**
 * <p>Orders an array of three ResultPoints in an order [A,B,C] such that AB < AC and
 * BC < AC and the angle between BC and BA is less than 180 degrees.
 */
+ (void) orderBestPatterns:(NSArray *)patterns {
  float zeroOneDistance = [self distance:patterns[0] pattern2:patterns[1]];
  float oneTwoDistance = [self distance:patterns[1] pattern2:patterns[2]];
  float zeroTwoDistance = [self distance:patterns[0] pattern2:patterns[2]];
  ResultPoint * pointA;
  ResultPoint * pointB;
  ResultPoint * pointC;
  if (oneTwoDistance >= zeroOneDistance && oneTwoDistance >= zeroTwoDistance) {
    pointB = patterns[0];
    pointA = patterns[1];
    pointC = patterns[2];
  }
   else if (zeroTwoDistance >= oneTwoDistance && zeroTwoDistance >= zeroOneDistance) {
    pointB = patterns[1];
    pointA = patterns[0];
    pointC = patterns[2];
  }
   else {
    pointB = patterns[2];
    pointA = patterns[0];
    pointC = patterns[1];
  }
  if ([self crossProductZ:pointA pointB:pointB pointC:pointC] < 0.0f) {
    ResultPoint * temp = pointA;
    pointA = pointC;
    pointC = temp;
  }
  patterns[0] = pointA;
  patterns[1] = pointB;
  patterns[2] = pointC;
}


/**
 * @return distance between two points
 */
+ (float) distance:(ResultPoint *)pattern1 pattern2:(ResultPoint *)pattern2 {
  float xDiff = [pattern1 x] - [pattern2 x];
  float yDiff = [pattern1 y] - [pattern2 y];
  return (float)[Math sqrt:(double)(xDiff * xDiff + yDiff * yDiff)];
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
