#import "AI01decoder.h"
#import "BitArray.h"
#import "NotFoundException.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */

@interface AI01393xDecoder : AI01decoder

- (id) initWithInformation:(BitArray *)information;
- (NSString *) parseInformation;

@end
