
/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@interface DecodedInformation : DecodedObject {
  NSString * newString;
  int remainingValue;
  BOOL remaining;
}

- (id) init:(int)newPosition newString:(NSString *)newString;
- (id) init:(int)newPosition newString:(NSString *)newString remainingValue:(int)remainingValue;
- (NSString *) getNewString;
- (BOOL) isRemaining;
- (int) getRemainingValue;
@end
