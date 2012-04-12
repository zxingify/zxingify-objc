/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@class ZXBitArray, ZXGeneralAppIdDecoder;

@interface ZXAbstractExpandedDecoder : NSObject {
  ZXBitArray * information;
  ZXGeneralAppIdDecoder * generalDecoder;
}

- (id) initWithInformation:(ZXBitArray *)information;
- (NSString *) parseInformation;
+ (ZXAbstractExpandedDecoder *) createDecoder:(ZXBitArray *)information;

@end
