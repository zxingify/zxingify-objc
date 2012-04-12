/**
 * <p>The main class which implements Aztec Code decoding -- as opposed to locating and extracting
 * the Aztec Code from an image.</p>
 * 
 * @author David Olivier
 */

@class ZXAztecDetectorResult, ZXDecoderResult;

@interface ZXAztecDecoder : NSObject {
  int numCodewords;
  int codewordSize;
  ZXAztecDetectorResult * ddata;
  int invertedBitCount;
}

- (ZXDecoderResult*) decode:(ZXAztecDetectorResult*)detectorResult;

@end
