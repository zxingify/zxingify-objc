#import "DataCharacter.h"
#import "FinderPattern.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */

@interface ExpandedPair : NSObject {
  BOOL mayBeLast;
  DataCharacter * leftChar;
  DataCharacter * rightChar;
  FinderPattern * finderPattern;
}

- (id) init:(DataCharacter *)leftChar rightChar:(DataCharacter *)rightChar finderPattern:(FinderPattern *)finderPattern mayBeLast:(BOOL)mayBeLast;
- (BOOL) mayBeLast;
- (DataCharacter *) getLeftChar;
- (DataCharacter *) getRightChar;
- (FinderPattern *) getFinderPattern;
- (BOOL) mustBeLast;
@end
