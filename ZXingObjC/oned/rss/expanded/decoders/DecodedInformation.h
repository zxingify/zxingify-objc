#import "DecodedObject.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@interface DecodedInformation : DecodedObject {
  NSString * theNewString;
  int remainingValue;
  BOOL remaining;
}

@property (nonatomic, readonly) NSString * theNewString;
@property (nonatomic, readonly) int remainingValue;
@property (nonatomic, readonly) BOOL remaining;

- (id) init:(int)newPosition newString:(NSString *)newString;
- (id) init:(int)newPosition newString:(NSString *)newString remainingValue:(int)remainingValue;

@end
