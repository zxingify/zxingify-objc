#import "MonochromeRectangleDetector.h"

int const MAX_MODULES = 32;

@implementation MonochromeRectangleDetector

- (id) initWithImage:(BitMatrix *)image {
  if (self = [super init]) {
    image = image;
  }
  return self;
}


/**
 * <p>Detects a rectangular region of black and white -- mostly black -- with a region of mostly
 * white, in an image.</p>
 * 
 * @return {@link ResultPoint}[] describing the corners of the rectangular region. The first and
 * last points are opposed on the diagonal, as are the second and third. The first point will be
 * the topmost point and the last, the bottommost. The second point will be leftmost and the
 * third, the rightmost
 * @throws NotFoundException if no Data Matrix Code can be found
 */
- (NSArray *) detect {
  int height = [image height];
  int width = [image width];
  int halfHeight = height >> 1;
  int halfWidth = width >> 1;
  int deltaY = [Math max:1 param1:height / (MAX_MODULES << 3)];
  int deltaX = [Math max:1 param1:width / (MAX_MODULES << 3)];
  int top = 0;
  int bottom = height;
  int left = 0;
  int right = width;
  ResultPoint * pointA = [self findCornerFromCenter:halfWidth deltaX:0 left:left right:right centerY:halfHeight deltaY:-deltaY top:top bottom:bottom maxWhiteRun:halfWidth >> 1];
  top = (int)[pointA y] - 1;
  ResultPoint * pointB = [self findCornerFromCenter:halfWidth deltaX:-deltaX left:left right:right centerY:halfHeight deltaY:0 top:top bottom:bottom maxWhiteRun:halfHeight >> 1];
  left = (int)[pointB x] - 1;
  ResultPoint * pointC = [self findCornerFromCenter:halfWidth deltaX:deltaX left:left right:right centerY:halfHeight deltaY:0 top:top bottom:bottom maxWhiteRun:halfHeight >> 1];
  right = (int)[pointC x] + 1;
  ResultPoint * pointD = [self findCornerFromCenter:halfWidth deltaX:0 left:left right:right centerY:halfHeight deltaY:deltaY top:top bottom:bottom maxWhiteRun:halfWidth >> 1];
  bottom = (int)[pointD y] + 1;
  pointA = [self findCornerFromCenter:halfWidth deltaX:0 left:left right:right centerY:halfHeight deltaY:-deltaY top:top bottom:bottom maxWhiteRun:halfWidth >> 2];
  return [NSArray arrayWithObjects:pointA, pointB, pointC, pointD, nil];
}


/**
 * Attempts to locate a corner of the barcode by scanning up, down, left or right from a center
 * point which should be within the barcode.
 * 
 * @param centerX center's x component (horizontal)
 * @param deltaX same as deltaY but change in x per step instead
 * @param left minimum value of x
 * @param right maximum value of x
 * @param centerY center's y component (vertical)
 * @param deltaY change in y per step. If scanning up this is negative; down, positive;
 * left or right, 0
 * @param top minimum value of y to search through (meaningless when di == 0)
 * @param bottom maximum value of y
 * @param maxWhiteRun maximum run of white pixels that can still be considered to be within
 * the barcode
 * @return a {@link com.google.zxing.ResultPoint} encapsulating the corner that was found
 * @throws NotFoundException if such a point cannot be found
 */
- (ResultPoint *) findCornerFromCenter:(int)centerX deltaX:(int)deltaX left:(int)left right:(int)right centerY:(int)centerY deltaY:(int)deltaY top:(int)top bottom:(int)bottom maxWhiteRun:(int)maxWhiteRun {
  NSArray * lastRange = nil;

  for (int y = centerY, x = centerX; y < bottom && y >= top && x < right && x >= left; y += deltaY, x += deltaX) {
    NSArray * range;
    if (deltaX == 0) {
      range = [self blackWhiteRange:y maxWhiteRun:maxWhiteRun minDim:left maxDim:right horizontal:YES];
    }
     else {
      range = [self blackWhiteRange:x maxWhiteRun:maxWhiteRun minDim:top maxDim:bottom horizontal:NO];
    }
    if (range == nil) {
      if (lastRange == nil) {
        @throw [NotFoundException notFoundInstance];
      }
      if (deltaX == 0) {
        int lastY = y - deltaY;
        if (lastRange[0] < centerX) {
          if (lastRange[1] > centerX) {
            return [[[ResultPoint alloc] init:deltaY > 0 ? lastRange[0] : lastRange[1] param1:lastY] autorelease];
          }
          return [[[ResultPoint alloc] init:lastRange[0] param1:lastY] autorelease];
        }
         else {
          return [[[ResultPoint alloc] init:lastRange[1] param1:lastY] autorelease];
        }
      }
       else {
        int lastX = x - deltaX;
        if (lastRange[0] < centerY) {
          if (lastRange[1] > centerY) {
            return [[[ResultPoint alloc] init:lastX param1:deltaX < 0 ? lastRange[0] : lastRange[1]] autorelease];
          }
          return [[[ResultPoint alloc] init:lastX param1:lastRange[0]] autorelease];
        }
         else {
          return [[[ResultPoint alloc] init:lastX param1:lastRange[1]] autorelease];
        }
      }
    }
    lastRange = range;
  }

  @throw [NotFoundException notFoundInstance];
}


/**
 * Computes the start and end of a region of pixels, either horizontally or vertically, that could
 * be part of a Data Matrix barcode.
 * 
 * @param fixedDimension if scanning horizontally, this is the row (the fixed vertical location)
 * where we are scanning. If scanning vertically it's the column, the fixed horizontal location
 * @param maxWhiteRun largest run of white pixels that can still be considered part of the
 * barcode region
 * @param minDim minimum pixel location, horizontally or vertically, to consider
 * @param maxDim maximum pixel location, horizontally or vertically, to consider
 * @param horizontal if true, we're scanning left-right, instead of up-down
 * @return int[] with start and end of found range, or null if no such range is found
 * (e.g. only white was found)
 */
- (NSArray *) blackWhiteRange:(int)fixedDimension maxWhiteRun:(int)maxWhiteRun minDim:(int)minDim maxDim:(int)maxDim horizontal:(BOOL)horizontal {
  int center = (minDim + maxDim) >> 1;
  int start = center;

  while (start >= minDim) {
    if (horizontal ? [image get:start param1:fixedDimension] : [image get:fixedDimension param1:start]) {
      start--;
    }
     else {
      int whiteRunStart = start;

      do {
        start--;
      }
       while (start >= minDim && !(horizontal ? [image get:start param1:fixedDimension] : [image get:fixedDimension param1:start]));
      int whiteRunSize = whiteRunStart - start;
      if (start < minDim || whiteRunSize > maxWhiteRun) {
        start = whiteRunStart;
        break;
      }
    }
  }

  start++;
  int end = center;

  while (end < maxDim) {
    if (horizontal ? [image get:end param1:fixedDimension] : [image get:fixedDimension param1:end]) {
      end++;
    }
     else {
      int whiteRunStart = end;

      do {
        end++;
      }
       while (end < maxDim && !(horizontal ? [image get:end param1:fixedDimension] : [image get:fixedDimension param1:end]));
      int whiteRunSize = end - whiteRunStart;
      if (end >= maxDim || whiteRunSize > maxWhiteRun) {
        end = whiteRunStart;
        break;
      }
    }
  }

  end--;
  return end > start ? [NSArray arrayWithObjects:start, end, nil] : nil;
}

- (void) dealloc {
  [image release];
  [super dealloc];
}

@end
