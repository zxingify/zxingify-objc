/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@class ZXDecodedInformation;

@interface ZXBlockParsedResult : NSObject {
  ZXDecodedInformation * decodedInformation;
  BOOL finished;
}

@property (nonatomic, readonly) ZXDecodedInformation * decodedInformation;
@property (nonatomic, readonly) BOOL finished;

- (id) initWithFinished:(BOOL)finished;
- (id) initWithInformation:(ZXDecodedInformation *)information finished:(BOOL)finished;

@end
