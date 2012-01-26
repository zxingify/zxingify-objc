#import "NotFoundException.h"
#import "BitArray.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */

@interface AI013x0xDecoder : AI01weightDecoder {
}

- (id) initWithInformation:(BitArray *)information;
- (NSString *) parseInformation;
@end
