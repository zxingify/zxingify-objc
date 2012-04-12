#import "ZXAI013x0xDecoder.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */

@interface ZXAI013103decoder : ZXAI013x0xDecoder

- (void) addWeightCode:(NSMutableString *)buf weight:(int)weight;
- (int) checkWeight:(int)weight;

@end
