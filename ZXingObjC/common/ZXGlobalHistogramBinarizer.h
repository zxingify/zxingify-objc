#import "ZXBinarizer.h"

/**
 * This Binarizer implementation uses the old ZXing global histogram approach. It is suitable
 * for low-end mobile devices which don't have enough CPU or memory to use a local thresholding
 * algorithm. However, because it picks a global black point, it cannot handle difficult shadows
 * and gradients.
 * 
 * Faster mobile devices and all desktop applications should probably use ZXHybridBinarizer instead.
 */

@class ZXBitArray, ZXBitMatrix, ZXLuminanceSource;

@interface ZXGlobalHistogramBinarizer : ZXBinarizer

- (ZXBitArray *)blackRow:(int)y row:(ZXBitArray *)row error:(NSError**)error;
- (ZXBinarizer *)createBinarizer:(ZXLuminanceSource *)source;

@end
