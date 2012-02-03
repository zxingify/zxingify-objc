#import "Binarizer.h"

/**
 * This Binarizer implementation uses the old ZXing global histogram approach. It is suitable
 * for low-end mobile devices which don't have enough CPU or memory to use a local thresholding
 * algorithm. However, because it picks a global black point, it cannot handle difficult shadows
 * and gradients.
 * 
 * Faster mobile devices and all desktop applications should probably use HybridBinarizer instead.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 */

@class BitMatrix;

@interface GlobalHistogramBinarizer : Binarizer {
  NSArray * luminances;
  NSArray * buckets;
}

- (BitArray *) getBlackRow:(int)y row:(BitArray *)row;
- (Binarizer *) createBinarizer:(LuminanceSource *)source;

@end
