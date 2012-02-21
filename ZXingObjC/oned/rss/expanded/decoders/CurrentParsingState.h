
/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */

@interface CurrentParsingState : NSObject {
  int position;
  int encoding;
}

@property (nonatomic, assign) int position;

- (BOOL) alpha;
- (BOOL) numeric;
- (BOOL) isoIec646;
- (void) setNumeric;
- (void) setAlpha;
- (void) setIsoIec646;

@end
