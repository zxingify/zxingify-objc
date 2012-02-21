/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@class BitArray;

@interface BitArrayBuilder : NSObject

+ (BitArray *) buildBitArray:(NSMutableArray *)pairs;

@end
