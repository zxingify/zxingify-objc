/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@class BitArray, CurrentParsingState, DecodedInformation;

@interface GeneralAppIdDecoder : NSObject {
  BitArray * information;
  CurrentParsingState * current;
  NSMutableString * buffer;
}

- (id) initWithInformation:(BitArray *)information;
- (NSString *) decodeAllCodes:(NSMutableString *)buff initialPosition:(int)initialPosition;
- (int) extractNumericValueFromBitArray:(int)pos bits:(int)bits;
- (int) extractNumericValueFromBitArray:(BitArray *)information pos:(int)pos bits:(int)bits;
- (DecodedInformation *) decodeGeneralPurposeField:(int)pos remaining:(NSString *)remaining;

@end
