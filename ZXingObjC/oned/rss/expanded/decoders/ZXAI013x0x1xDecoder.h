#import "ZXAI01weightDecoder.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@interface ZXAI013x0x1xDecoder : ZXAI01weightDecoder {
  NSString * dateCode;
  NSString * firstAIdigits;
}

- (id) initWithInformation:(ZXBitArray *)information firstAIdigits:(NSString *)firstAIdigits dateCode:(NSString *)dateCode;
- (NSString *) parseInformation;
- (void) addWeightCode:(NSMutableString *)buf weight:(int)weight;
- (int) checkWeight:(int)weight;

@end
