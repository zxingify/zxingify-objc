#import "BitArray.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@interface AI01decoder : AbstractExpandedDecoder {
}

- (id) initWithInformation:(BitArray *)information;
- (void) encodeCompressedGtin:(StringBuffer *)buf currentPos:(int)currentPos;
- (void) encodeCompressedGtinWithoutAI:(StringBuffer *)buf currentPos:(int)currentPos initialBufferPosition:(int)initialBufferPosition;
@end
