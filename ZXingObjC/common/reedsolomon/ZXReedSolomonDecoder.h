/**
 * <p>Implements Reed-Solomon decoding, as the name implies.</p>
 * 
 * <p>The algorithm will not be explained here, but the following references were helpful
 * in creating this implementation:</p>
 * 
 * <ul>
 * <li>Bruce Maggs.
 * <a href="http://www.cs.cmu.edu/afs/cs.cmu.edu/project/pscico-guyb/realworld/www/rs_decode.ps">
 * "Decoding Reed-Solomon Codes"</a> (see discussion of Forney's Formula)</li>
 * <li>J.I. Hall. <a href="www.mth.msu.edu/~jhall/classes/codenotes/GRS.pdf">
 * "Chapter 5. Generalized Reed-Solomon Codes"</a>
 * (see discussion of Euclidean algorithm)</li>
 * </ul>
 * 
 * <p>Much credit is due to William Rucklidge since portions of this code are an indirect
 * port of his C++ Reed-Solomon implementation.</p>
 * 
 * @author Sean Owen
 * @author William Rucklidge
 * @author sanfordsquires
 */

@class ZXGenericGF;

@interface ZXReedSolomonDecoder : NSObject {
  ZXGenericGF * field;
}

- (id) initWithField:(ZXGenericGF *)field;
- (void) decode:(NSMutableArray *)received twoS:(int)twoS;
@end
