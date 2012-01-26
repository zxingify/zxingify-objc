#import "FormatException.h"
#import "BitSource.h"
#import "CharacterSetECI.h"
#import "DecoderResult.h"
#import "StringUtils.h"
#import "UnsupportedEncodingException.h"
#import "NSMutableDictionary.h"
#import "NSMutableArray.h"

/**
 * <p>QR Codes can encode text as bits in one of several modes, and can use multiple modes
 * in one QR Code. This class decodes the bits back into text.</p>
 * 
 * <p>See ISO 18004:2006, 6.4.3 - 6.4.7</p>
 * 
 * @author Sean Owen
 */

@interface DecodedBitStreamParser : NSObject {
}

+ (DecoderResult *) decode:(NSArray *)bytes version:(Version *)version ecLevel:(ErrorCorrectionLevel *)ecLevel hints:(NSMutableDictionary *)hints;
@end
