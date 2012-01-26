#import "NotFoundException.h"
#import "BitArray.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@interface GeneralAppIdDecoder : NSObject {
  BitArray * information;
  CurrentParsingState * current;
  StringBuffer * buffer;
}

- (id) initWithInformation:(BitArray *)information;
- (NSString *) decodeAllCodes:(StringBuffer *)buff initialPosition:(int)initialPosition;
- (int) extractNumericValueFromBitArray:(int)pos bits:(int)bits;
+ (int) extractNumericValueFromBitArray:(BitArray *)information pos:(int)pos bits:(int)bits;
- (DecodedInformation *) decodeGeneralPurposeField:(int)pos remaining:(NSString *)remaining;
@end
