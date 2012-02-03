#import "AI01weightDecoder.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@class BitArray;

@interface AI013x0x1xDecoder : AI01weightDecoder {
  NSString * dateCode;
  NSString * firstAIdigits;
}

- (id) initWithInformation:(BitArray *)information firstAIdigits:(NSString *)firstAIdigits dateCode:(NSString *)dateCode;
- (NSString *) parseInformation;
- (void) addWeightCode:(NSMutableString *)buf weight:(int)weight;
- (int) checkWeight:(int)weight;
@end
