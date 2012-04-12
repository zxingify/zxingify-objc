
/**
 * Callback which is invoked when a possible result point (significant
 * point in the barcode image such as a corner) is found.
 * 
 * @see DecodeHintType#NEED_RESULT_POINT_CALLBACK
 */

@class ZXResultPoint;

@protocol ZXResultPointCallback <NSObject>

- (void) foundPossibleResultPoint:(ZXResultPoint *)point;

@end
