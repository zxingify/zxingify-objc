#import "NotFoundException.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@interface FieldParser : NSObject

+ (NSString *) parseFieldsInGeneralPurpose:(NSString *)rawInformation;

@end
