/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */

@class ZXDataCharacter, ZXRSSFinderPattern;

@interface ZXExpandedPair : NSObject {
  BOOL mayBeLast;
  ZXDataCharacter * leftChar;
  ZXDataCharacter * rightChar;
  ZXRSSFinderPattern * finderPattern;
}

@property (nonatomic, readonly) ZXDataCharacter * leftChar;
@property (nonatomic, readonly) ZXDataCharacter * rightChar;
@property (nonatomic, readonly) ZXRSSFinderPattern * finderPattern;
@property (nonatomic, readonly) BOOL mayBeLast;

- (id) initWithLeftChar:(ZXDataCharacter *)leftChar rightChar:(ZXDataCharacter *)rightChar finderPattern:(ZXRSSFinderPattern *)finderPattern mayBeLast:(BOOL)mayBeLast;
- (BOOL) mustBeLast;

@end
