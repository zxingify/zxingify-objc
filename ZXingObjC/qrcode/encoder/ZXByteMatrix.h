/**
 * A class which wraps a 2D array of bytes. The default usage is signed. If you want to use it as a
 * unsigned container, it's up to you to do byteValue & 0xff at each location.
 */

@interface ZXByteMatrix : NSObject

@property (nonatomic, assign, readonly) int height;
@property (nonatomic, assign, readonly) int width;
@property (nonatomic, assign, readonly) unsigned char** array;

- (id)initWithWidth:(int)width height:(int)height;
- (char)get:(int)x y:(int)y;
- (void)set:(int)x y:(int)y charValue:(char)value;
- (void)set:(int)x y:(int)y intValue:(int)value;
- (void)set:(int)x y:(int)y boolValue:(BOOL)value;
- (void)clear:(char)value;

@end
