#import "NotFoundException.h"
#import "BitArray.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@interface AnyAIDecoder : AbstractExpandedDecoder {
}

- (id) initWithInformation:(BitArray *)information;
- (NSString *) parseInformation;
@end
