@class ZXBitArray;

@interface BinaryUtil : NSObject

+ (ZXBitArray*)buildBitArrayFromString:(NSString*)data;
+ (ZXBitArray*)buildBitArrayFromStringWithoutSpaces:(NSString*)data;

@end
