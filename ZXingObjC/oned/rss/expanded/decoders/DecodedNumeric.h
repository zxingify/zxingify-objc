
/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@interface DecodedNumeric : DecodedObject {
  int firstDigit;
  int secondDigit;
}

- (id) init:(int)newPosition firstDigit:(int)firstDigit secondDigit:(int)secondDigit;
- (int) getFirstDigit;
- (int) getSecondDigit;
- (int) getValue;
- (BOOL) isFirstDigitFNC1;
- (BOOL) isSecondDigitFNC1;
- (BOOL) isAnyFNC1;
@end
