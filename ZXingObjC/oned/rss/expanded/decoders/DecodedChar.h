#import "DecodedObject.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@interface DecodedChar : DecodedObject {
  unichar value;
}

- (id) init:(int)newPosition value:(unichar)value;
- (unichar) getValue;
- (BOOL) isFNC1;
@end
