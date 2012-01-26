#import "PerspectiveTransform.h"

@implementation PerspectiveTransform

- (id) init:(float)a11 a21:(float)a21 a31:(float)a31 a12:(float)a12 a22:(float)a22 a32:(float)a32 a13:(float)a13 a23:(float)a23 a33:(float)a33 {
  if (self = [super init]) {
    a11 = a11;
    a12 = a12;
    a13 = a13;
    a21 = a21;
    a22 = a22;
    a23 = a23;
    a31 = a31;
    a32 = a32;
    a33 = a33;
  }
  return self;
}

+ (PerspectiveTransform *) quadrilateralToQuadrilateral:(float)x0 y0:(float)y0 x1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 x3:(float)x3 y3:(float)y3 x0p:(float)x0p y0p:(float)y0p x1p:(float)x1p y1p:(float)y1p x2p:(float)x2p y2p:(float)y2p x3p:(float)x3p y3p:(float)y3p {
  PerspectiveTransform * qToS = [self quadrilateralToSquare:x0 y0:y0 x1:x1 y1:y1 x2:x2 y2:y2 x3:x3 y3:y3];
  PerspectiveTransform * sToQ = [self squareToQuadrilateral:x0p y0:y0p x1:x1p y1:y1p x2:x2p y2:y2p x3:x3p y3:y3p];
  return [sToQ times:qToS];
}

- (void) transformPoints:(NSArray *)points {
  int max = points.length;
  float a11 = a11;
  float a12 = a12;
  float a13 = a13;
  float a21 = a21;
  float a22 = a22;
  float a23 = a23;
  float a31 = a31;
  float a32 = a32;
  float a33 = a33;

  for (int i = 0; i < max; i += 2) {
    float x = points[i];
    float y = points[i + 1];
    float denominator = a13 * x + a23 * y + a33;
    points[i] = (a11 * x + a21 * y + a31) / denominator;
    points[i + 1] = (a12 * x + a22 * y + a32) / denominator;
  }

}


/**
 * Convenience method, not optimized for performance.
 */
- (void) transformPoints:(NSArray *)xValues yValues:(NSArray *)yValues {
  int n = xValues.length;

  for (int i = 0; i < n; i++) {
    float x = xValues[i];
    float y = yValues[i];
    float denominator = a13 * x + a23 * y + a33;
    xValues[i] = (a11 * x + a21 * y + a31) / denominator;
    yValues[i] = (a12 * x + a22 * y + a32) / denominator;
  }

}

+ (PerspectiveTransform *) squareToQuadrilateral:(float)x0 y0:(float)y0 x1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 x3:(float)x3 y3:(float)y3 {
  float dy2 = y3 - y2;
  float dy3 = y0 - y1 + y2 - y3;
  if (dy2 == 0.0f && dy3 == 0.0f) {
    return [[[PerspectiveTransform alloc] init:x1 - x0 param1:x2 - x1 param2:x0 param3:y1 - y0 param4:y2 - y1 param5:y0 param6:0.0f param7:0.0f param8:1.0f] autorelease];
  }
   else {
    float dx1 = x1 - x2;
    float dx2 = x3 - x2;
    float dx3 = x0 - x1 + x2 - x3;
    float dy1 = y1 - y2;
    float denominator = dx1 * dy2 - dx2 * dy1;
    float a13 = (dx3 * dy2 - dx2 * dy3) / denominator;
    float a23 = (dx1 * dy3 - dx3 * dy1) / denominator;
    return [[[PerspectiveTransform alloc] init:x1 - x0 + a13 * x1 param1:x3 - x0 + a23 * x3 param2:x0 param3:y1 - y0 + a13 * y1 param4:y3 - y0 + a23 * y3 param5:y0 param6:a13 param7:a23 param8:1.0f] autorelease];
  }
}

+ (PerspectiveTransform *) quadrilateralToSquare:(float)x0 y0:(float)y0 x1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 x3:(float)x3 y3:(float)y3 {
  return [[self squareToQuadrilateral:x0 y0:y0 x1:x1 y1:y1 x2:x2 y2:y2 x3:x3 y3:y3] buildAdjoint];
}

- (PerspectiveTransform *) buildAdjoint {
  return [[[PerspectiveTransform alloc] init:a22 * a33 - a23 * a32 param1:a23 * a31 - a21 * a33 param2:a21 * a32 - a22 * a31 param3:a13 * a32 - a12 * a33 param4:a11 * a33 - a13 * a31 param5:a12 * a31 - a11 * a32 param6:a12 * a23 - a13 * a22 param7:a13 * a21 - a11 * a23 param8:a11 * a22 - a12 * a21] autorelease];
}

- (PerspectiveTransform *) times:(PerspectiveTransform *)other {
  return [[[PerspectiveTransform alloc] init:a11 * other.a11 + a21 * other.a12 + a31 * other.a13 param1:a11 * other.a21 + a21 * other.a22 + a31 * other.a23 param2:a11 * other.a31 + a21 * other.a32 + a31 * other.a33 param3:a12 * other.a11 + a22 * other.a12 + a32 * other.a13 param4:a12 * other.a21 + a22 * other.a22 + a32 * other.a23 param5:a12 * other.a31 + a22 * other.a32 + a32 * other.a33 param6:a13 * other.a11 + a23 * other.a12 + a33 * other.a13 param7:a13 * other.a21 + a23 * other.a22 + a33 * other.a23 param8:a13 * other.a31 + a23 * other.a32 + a33 * other.a33] autorelease];
}

@end
