/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@class ZXBitArray, ZXCurrentParsingState, ZXDecodedInformation;

@interface ZXGeneralAppIdDecoder : NSObject {
  ZXBitArray * information;
  ZXCurrentParsingState * current;
  NSMutableString * buffer;
}

- (id) initWithInformation:(ZXBitArray *)information;
- (NSString *) decodeAllCodes:(NSMutableString *)buff initialPosition:(int)initialPosition;
- (int) extractNumericValueFromBitArray:(int)pos bits:(int)bits;
+ (int) extractNumericValueFromBitArray:(ZXBitArray *)information pos:(int)pos bits:(int)bits;
- (ZXDecodedInformation *) decodeGeneralPurposeField:(int)pos remaining:(NSString *)remaining;

@end
