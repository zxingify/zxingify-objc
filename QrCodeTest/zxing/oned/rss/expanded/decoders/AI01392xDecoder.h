#import "NotFoundException.h"
#import "BitArray.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */

@interface AI01392xDecoder : AI01decoder {
}

- (id) initWithInformation:(BitArray *)information;
- (NSString *) parseInformation;
@end
