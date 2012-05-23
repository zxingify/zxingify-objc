/**
 * The main class which implements Aztec Code decoding -- as opposed to locating and extracting
 * the Aztec Code from an image.
 */

@class ZXAztecDetectorResult, ZXDecoderResult;

@interface ZXAztecDecoder : NSObject

- (ZXDecoderResult *)decode:(ZXAztecDetectorResult *)detectorResult error:(NSError**)error;

@end
