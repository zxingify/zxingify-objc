@class ZXBitArray, ZXDecodedInformation;

@interface ZXGeneralAppIdDecoder : NSObject

- (id)initWithInformation:(ZXBitArray *)information;
- (NSString *)decodeAllCodes:(NSMutableString *)buff initialPosition:(int)initialPosition error:(NSError**)error;
- (int)extractNumericValueFromBitArray:(int)pos bits:(int)bits;
+ (int)extractNumericValueFromBitArray:(ZXBitArray *)information pos:(int)pos bits:(int)bits;
- (ZXDecodedInformation *)decodeGeneralPurposeField:(int)pos remaining:(NSString *)remaining;

@end
