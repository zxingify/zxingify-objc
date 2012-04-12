/**
 * A class which wraps a 2D array of bytes. The default usage is signed. If you want to use it as a
 * unsigned container, it's up to you to do byteValue & 0xff at each location.
 * 
 * JAVAPORT: The original code was a 2D array of ints, but since it only ever gets assigned
 * -1, 0, and 1, I'm going to use less memory and go with bytes.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */

@interface ZXByteMatrix : NSObject {
  unsigned char **bytes;
  int width;
  int height;
}

@property(nonatomic, readonly) int height;
@property(nonatomic, readonly) int width;
@property(nonatomic, readonly) unsigned char** array;

- (id) initWithWidth:(int)width height:(int)height;
- (char) get:(int)x y:(int)y;
- (void) set:(int)x y:(int)y charValue:(char)value;
- (void) set:(int)x y:(int)y intValue:(int)value;
- (void) set:(int)x y:(int)y boolValue:(BOOL)value;
- (void) clear:(char)value;

@end
