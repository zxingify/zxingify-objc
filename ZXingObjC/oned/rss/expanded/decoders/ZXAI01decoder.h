#import "ZXAbstractExpandedDecoder.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

extern const int gtinSize;

@interface ZXAI01decoder : ZXAbstractExpandedDecoder

- (void) encodeCompressedGtin:(NSMutableString *)buf currentPos:(int)currentPos;
- (void) encodeCompressedGtinWithoutAI:(NSMutableString *)buf currentPos:(int)currentPos initialBufferPosition:(int)initialBufferPosition;

@end
