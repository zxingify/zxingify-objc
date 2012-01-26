
/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */

@interface CurrentParsingState : NSObject {
  int position;
  int encoding;
}

- (id) init;
- (BOOL) isAlpha;
- (BOOL) isNumeric;
- (BOOL) isIsoIec646;
- (void) setNumeric;
- (void) setAlpha;
- (void) setIsoIec646;
@end
