/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@class DecodedInformation;

@interface BlockParsedResult : NSObject {
  DecodedInformation * decodedInformation;
  BOOL finished;
}

@property (nonatomic, readonly) DecodedInformation * decodedInformation;
@property (nonatomic, readonly) BOOL finished;

- (id) initWithFinished:(BOOL)finished;
- (id) initWithInformation:(DecodedInformation *)information finished:(BOOL)finished;

@end
