/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@class BitArray, GeneralAppIdDecoder;

@interface AbstractExpandedDecoder : NSObject {
  BitArray * information;
  GeneralAppIdDecoder * generalDecoder;
}

- (id) initWithInformation:(BitArray *)information;
- (NSString *) parseInformation;
+ (AbstractExpandedDecoder *) createDecoder:(BitArray *)information;

@end
