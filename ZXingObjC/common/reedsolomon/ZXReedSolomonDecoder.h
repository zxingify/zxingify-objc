/**
 * Implements Reed-Solomon decoding, as the name implies.
 * 
 * The algorithm will not be explained here, but the following references were helpful
 * in creating this implementation:
 * 
 * Bruce Maggs.
 * http://www.cs.cmu.edu/afs/cs.cmu.edu/project/pscico-guyb/realworld/www/rs_decode.ps
 * "Decoding Reed-Solomon Codes" (see discussion of Forney's Formula)
 *
 * J.I. Hall. www.mth.msu.edu/~jhall/classes/codenotes/GRS.pdf
 * "Chapter 5. Generalized Reed-Solomon Codes"
 * (see discussion of Euclidean algorithm)
 * 
 * Much credit is due to William Rucklidge since portions of this code are an indirect
 * port of his C++ Reed-Solomon implementation.
 */

@class ZXGenericGF;

@interface ZXReedSolomonDecoder : NSObject

- (id)initWithField:(ZXGenericGF *)field;
- (BOOL)decode:(int *)received receivedLen:(int)receivedLen twoS:(int)twoS error:(NSError **)error;

@end
