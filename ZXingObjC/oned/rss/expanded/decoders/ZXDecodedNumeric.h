#import "ZXDecodedObject.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

extern const int FNC1;

@interface ZXDecodedNumeric : ZXDecodedObject {
  int firstDigit;
  int secondDigit;
}

@property (nonatomic, readonly) int firstDigit;
@property (nonatomic, readonly) int secondDigit;
@property (nonatomic, readonly) int value;

- (id) initWithNewPosition:(int)newPosition firstDigit:(int)firstDigit secondDigit:(int)secondDigit;
- (BOOL) firstDigitFNC1;
- (BOOL) secondDigitFNC1;
- (BOOL) anyFNC1;

@end
