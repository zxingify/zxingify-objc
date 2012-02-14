/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */

@class DataCharacter, RSSFinderPattern;

@interface ExpandedPair : NSObject {
  BOOL mayBeLast;
  DataCharacter * leftChar;
  DataCharacter * rightChar;
  RSSFinderPattern * finderPattern;
}

@property (nonatomic, readonly) DataCharacter * leftChar;
@property (nonatomic, readonly) DataCharacter * rightChar;
@property (nonatomic, readonly) RSSFinderPattern * finderPattern;
@property (nonatomic, readonly) BOOL mayBeLast;

- (id) initWithLeftChar:(DataCharacter *)leftChar rightChar:(DataCharacter *)rightChar finderPattern:(RSSFinderPattern *)finderPattern mayBeLast:(BOOL)mayBeLast;
- (BOOL) mustBeLast;

@end
