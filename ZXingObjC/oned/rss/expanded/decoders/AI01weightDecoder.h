#import "BitArray.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */

@interface AI01weightDecoder : AI01decoder {
}

- (id) initWithInformation:(BitArray *)information;
- (void) encodeCompressedWeight:(StringBuffer *)buf currentPos:(int)currentPos weightSize:(int)weightSize;
- (void) addWeightCode:(StringBuffer *)buf weight:(int)weight;
- (int) checkWeight:(int)weight;
@end
