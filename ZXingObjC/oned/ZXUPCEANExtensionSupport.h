@class ZXBitArray, ZXResult;

@interface ZXUPCEANExtensionSupport : NSObject

- (ZXResult *)decodeRow:(int)rowNumber row:(ZXBitArray *)row rowOffset:(int)rowOffset error:(NSError**)error;
- (int)decodeMiddle:(ZXBitArray *)row startRange:(NSArray *)startRange result:(NSMutableString *)result error:(NSError**)error;

@end
