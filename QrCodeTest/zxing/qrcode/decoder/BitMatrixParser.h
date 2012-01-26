#import "FormatException.h"
#import "BitMatrix.h"

/**
 * @author Sean Owen
 */

@interface BitMatrixParser : NSObject {
  BitMatrix * bitMatrix;
  Version * parsedVersion;
  FormatInformation * parsedFormatInfo;
}

- (id) initWithBitMatrix:(BitMatrix *)bitMatrix;
- (FormatInformation *) readFormatInformation;
- (Version *) readVersion;
- (NSArray *) readCodewords;
@end
