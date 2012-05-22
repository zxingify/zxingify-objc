@interface BitSourceBuilder : NSObject

- (void)write:(int)value numBits:(int)numBits;
- (unsigned char*)toByteArray;
- (int)byteArrayLength;

@end
