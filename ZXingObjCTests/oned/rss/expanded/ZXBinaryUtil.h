@class ZXBitArray;

@interface ZXBinaryUtil : NSObject

+ (ZXBitArray*)buildBitArrayFromString:(NSString*)data;
+ (ZXBitArray*)buildBitArrayFromStringWithoutSpaces:(NSString*)data;

@end
