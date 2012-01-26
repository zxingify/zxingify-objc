
/**
 * The purpose of this class hierarchy is to abstract different bitmap implementations across
 * platforms into a standard interface for requesting greyscale luminance values. The interface
 * only provides immutable methods; therefore crop and rotation create copies. This is to ensure
 * that one Reader does not modify the original luminance source and leave it in an unknown state
 * for other Readers in the chain.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */

@interface LuminanceSource : NSObject {
  int width;
  int height;
}

@property(nonatomic, retain, readonly) NSArray * matrix;
@property(nonatomic, readonly) int width;
@property(nonatomic, readonly) int height;
@property(nonatomic, readonly) BOOL cropSupported;
@property(nonatomic, readonly) BOOL rotateSupported;
- (id) init:(int)width height:(int)height;
- (NSArray *) getRow:(int)y row:(NSArray *)row;
- (LuminanceSource *) crop:(int)left top:(int)top width:(int)width height:(int)height;
- (LuminanceSource *) rotateCounterClockwise;
@end
