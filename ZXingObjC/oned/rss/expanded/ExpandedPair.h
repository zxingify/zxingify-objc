/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */

@class DataCharacter, FinderPattern;

@interface ExpandedPair : NSObject {
  BOOL mayBeLast;
  DataCharacter * leftChar;
  DataCharacter * rightChar;
  FinderPattern * finderPattern;
}

@property (nonatomic, readonly) DataCharacter * leftChar;
@property (nonatomic, readonly) DataCharacter * rightChar;
@property (nonatomic, readonly) FinderPattern * finderPattern;
@property (nonatomic, readonly) BOOL mayBeLast;

- (id) initWithLeftChar:(DataCharacter *)leftChar rightChar:(DataCharacter *)rightChar finderPattern:(FinderPattern *)finderPattern mayBeLast:(BOOL)mayBeLast;
- (BOOL) mustBeLast;

@end
