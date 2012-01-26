#import "FormatException.h"
#import "AztecDetectorResult.h"
#import "BitMatrix.h"
#import "DecoderResult.h"
#import "GenericGF.h"
#import "ReedSolomonDecoder.h"
#import "ReedSolomonException.h"

/**
 * <p>The main class which implements Aztec Code decoding -- as opposed to locating and extracting
 * the Aztec Code from an image.</p>
 * 
 * @author David Olivier
 */

@interface Decoder : NSObject {
  int numCodewords;
  int codewordSize;
  AztecDetectorResult * ddata;
  int invertedBitCount;
}

- (DecoderResult *) decode:(AztecDetectorResult *)detectorResult;
@end
