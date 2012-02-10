#import "AbstractExpandedDecoder.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@class BitArray;

@interface AI01decoder : AbstractExpandedDecoder

- (void) encodeCompressedGtin:(NSMutableString *)buf currentPos:(int)currentPos;
- (void) encodeCompressedGtinWithoutAI:(NSMutableString *)buf currentPos:(int)currentPos initialBufferPosition:(int)initialBufferPosition;

@end
