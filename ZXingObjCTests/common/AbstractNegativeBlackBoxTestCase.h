#import "AbstractBlackBoxTestCase.h"

/**
 * This abstract class looks for negative results, i.e. it only allows a certain number of false
 * positives in images which should not decode. This helps ensure that we are not too lenient.
 */
@interface AbstractNegativeBlackBoxTestCase : AbstractBlackBoxTestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation testBasePathSuffix:(NSString *)testBasePathSuffix;
- (void)addTest:(int)falsePositivesAllowed rotation:(float)rotation;
- (void)runTests;

@end
