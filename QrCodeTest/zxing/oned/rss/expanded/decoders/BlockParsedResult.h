
/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@interface BlockParsedResult : NSObject {
  DecodedInformation * decodedInformation;
  BOOL finished;
}

- (id) init;
- (id) initWithFinished:(BOOL)finished;
- (id) init:(DecodedInformation *)information finished:(BOOL)finished;
- (DecodedInformation *) getDecodedInformation;
- (BOOL) isFinished;
@end
