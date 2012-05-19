@interface BitSourceBuilder : NSObject

- (void)writeValue:(int)value numBits:(int)numBits;
- (unsigned char*)toByteArray;

@end
