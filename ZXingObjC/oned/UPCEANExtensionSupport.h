@class BitArray, Result;

@interface UPCEANExtensionSupport : NSObject

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row rowOffset:(int)rowOffset;
- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange result:(NSMutableString *)result;

@end
