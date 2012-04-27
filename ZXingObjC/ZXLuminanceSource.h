
/**
 * The purpose of this class hierarchy is to abstract different bitmap implementations across
 * platforms into a standard interface for requesting greyscale luminance values. The interface
 * only provides immutable methods; therefore crop and rotation create copies. This is to ensure
 * that one Reader does not modify the original luminance source and leave it in an unknown state
 * for other Readers in the chain.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */

@interface ZXLuminanceSource : NSObject {
  int width;
  int height;
}

@property(nonatomic, readonly) int width;
@property(nonatomic, readonly) int height;
@property(nonatomic, readonly) BOOL cropSupported;
@property(nonatomic, readonly) BOOL rotateSupported;
- (id) init:(int)width height:(int)height;
- (unsigned char *) getRow:(int)y row:(unsigned char *)row;
- (unsigned char *) matrix;
- (ZXLuminanceSource *) crop:(int)left top:(int)top width:(int)width height:(int)height;
- (ZXLuminanceSource *) rotateCounterClockwise;
@end
