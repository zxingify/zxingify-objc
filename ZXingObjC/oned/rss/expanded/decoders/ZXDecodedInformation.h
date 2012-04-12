#import "ZXDecodedObject.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@interface ZXDecodedInformation : ZXDecodedObject {
  NSString * theNewString;
  int remainingValue;
  BOOL remaining;
}

@property (nonatomic, readonly) NSString * theNewString;
@property (nonatomic, readonly) int remainingValue;
@property (nonatomic, readonly) BOOL remaining;

- (id) initWithNewPosition:(int)newPosition newString:(NSString *)newString;
- (id) initWithNewPosition:(int)newPosition newString:(NSString *)newString remainingValue:(int)remainingValue;

@end
