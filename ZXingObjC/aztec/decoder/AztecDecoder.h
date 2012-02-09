/**
 * <p>The main class which implements Aztec Code decoding -- as opposed to locating and extracting
 * the Aztec Code from an image.</p>
 * 
 * @author David Olivier
 */

@class AztecDetectorResult, DecoderResult;

@interface AztecDecoder : NSObject {
  int numCodewords;
  int codewordSize;
  AztecDetectorResult * ddata;
  int invertedBitCount;
}

- (DecoderResult*) decode:(AztecDetectorResult*)detectorResult;

@end
