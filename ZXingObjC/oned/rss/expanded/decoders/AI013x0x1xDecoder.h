#import "NotFoundException.h"
#import "BitArray.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@interface AI013x0x1xDecoder : AI01weightDecoder {
  NSString * dateCode;
  NSString * firstAIdigits;
}

- (id) init:(BitArray *)information firstAIdigits:(NSString *)firstAIdigits dateCode:(NSString *)dateCode;
- (NSString *) parseInformation;
- (void) addWeightCode:(StringBuffer *)buf weight:(int)weight;
- (int) checkWeight:(int)weight;
@end
