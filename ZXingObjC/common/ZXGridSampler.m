#import "ZXBitMatrix.h"
#import "ZXDefaultGridSampler.h"
#import "ZXGridSampler.h"
#import "ZXNotFoundException.h"
#import "ZXPerspectiveTransform.h"

static ZXGridSampler * gridSampler = nil;

@implementation ZXGridSampler

/**
 * Sets the implementation of GridSampler used by the library. One global
 * instance is stored, which may sound problematic. But, the implementation provided
 * ought to be appropriate for the entire platform, and all uses of this library
 * in the whole lifetime of the JVM. For instance, an Android activity can swap in
 * an implementation that takes advantage of native platform libraries.
 * 
 * @param newGridSampler The platform-specific object to install.
 */
+ (void) setGridSampler:(ZXGridSampler *)newGridSampler {
  if (newGridSampler == nil) {
    [NSException raise:NSInvalidArgumentException format:@"Grid sampler must be non-null."];
  }
  gridSampler = newGridSampler;
}

+ (ZXGridSampler *)instance {
  if (!gridSampler) {
    gridSampler = [[ZXDefaultGridSampler alloc] init];
  }

  return gridSampler;
}

/**
 * Samples an image for a rectangular matrix of bits of the given dimension.
 * @param image image to sample
 * @param dimensionX width of {@link BitMatrix} to sample from image
 * @param dimensionY height of {@link BitMatrix} to sample from image
 * @return {@link BitMatrix} representing a grid of points sampled from the image within a region
 * defined by the "from" parameters
 * @throws NotFoundException if image can't be sampled, for example, if the transformation defined
 * by the given points is invalid or results in sampling outside the image boundaries
 */
- (ZXBitMatrix *) sampleGrid:(ZXBitMatrix *)image dimensionX:(int)dimensionX dimensionY:(int)dimensionY p1ToX:(float)p1ToX p1ToY:(float)p1ToY p2ToX:(float)p2ToX p2ToY:(float)p2ToY p3ToX:(float)p3ToX p3ToY:(float)p3ToY p4ToX:(float)p4ToX p4ToY:(float)p4ToY p1FromX:(float)p1FromX p1FromY:(float)p1FromY p2FromX:(float)p2FromX p2FromY:(float)p2FromY p3FromX:(float)p3FromX p3FromY:(float)p3FromY p4FromX:(float)p4FromX p4FromY:(float)p4FromY {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

- (ZXBitMatrix *) sampleGrid:(ZXBitMatrix *)image dimensionX:(int)dimensionX dimensionY:(int)dimensionY transform:(ZXPerspectiveTransform *)transform {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}


/**
 * <p>Checks a set of points that have been transformed to sample points on an image against
 * the image's dimensions to see if the point are even within the image.</p>
 * 
 * <p>This method will actually "nudge" the endpoints back onto the image if they are found to be
 * barely (less than 1 pixel) off the image. This accounts for imperfect detection of finder
 * patterns in an image where the QR Code runs all the way to the image border.</p>
 * 
 * <p>For efficiency, the method will check points from either end of the line until one is found
 * to be within the image. Because the set of points are assumed to be linear, this is valid.</p>
 * 
 * @param image image into which the points should map
 * @param points actual points in x1,y1,...,xn,yn form
 * @throws NotFoundException if an endpoint is lies outside the image boundaries
 */
+ (void) checkAndNudgePoints:(ZXBitMatrix *)image points:(float *)points pointsLen:(int)pointsLen {
  int width = [image width];
  int height = [image height];

  BOOL nudged = YES;
  for (int offset = 0; offset < pointsLen && nudged; offset += 2) {
    int x = (int) points[offset];
    int y = (int) points[offset + 1];
    if (x < -1 || x > width || y < -1 || y > height) {
      @throw [ZXNotFoundException notFoundInstance];
    }
    nudged = NO;
    if (x == -1) {
      points[offset] = 0.0f;
      nudged = YES;
    } else if (x == width) {
      points[offset] = width - 1;
      nudged = YES;
    }
    if (y == -1) {
      points[offset + 1] = 0.0f;
      nudged = YES;
    } else if (y == height) {
      points[offset + 1] = height - 1;
      nudged = YES;
    }
  }

  nudged = YES;
  for (int offset = pointsLen - 2; offset >= 0 && nudged; offset -= 2) {
    int x = (int) points[offset];
    int y = (int) points[offset + 1];
    if (x < -1 || x > width || y < -1 || y > height) {
      @throw [ZXNotFoundException notFoundInstance];
    }
    nudged = NO;
    if (x == -1) {
      points[offset] = 0.0f;
      nudged = YES;
    } else if (x == width) {
      points[offset] = width - 1;
      nudged = YES;
    }
    if (y == -1) {
      points[offset + 1] = 0.0f;
      nudged = YES;
    } else if (y == height) {
      points[offset + 1] = height - 1;
      nudged = YES;
    }
  }
}

@end
