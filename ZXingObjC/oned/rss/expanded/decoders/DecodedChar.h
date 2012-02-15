#import "DecodedObject.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@interface DecodedChar : DecodedObject {
  unichar value;
}

@property (nonatomic, readonly) unichar value;

- (id) initWithNewPosition:(int)newPosition value:(unichar)value;
- (BOOL) isFNC1;

@end
