/**
 * @author satorux@google.com (Satoru Takabayashi) - creator
 * @author dswitkin@google.com (Daniel Switkin) - ported from C++
 */

extern int const NUM_MASK_PATTERNS;

@class ZXByteMatrix, ZXErrorCorrectionLevel, ZXMode;

@interface ZXQRCode : NSObject {
  ZXMode * mode;
  ZXErrorCorrectionLevel * ecLevel;
  int version;
  int matrixWidth;
  int maskPattern;
  int numTotalBytes;
  int numDataBytes;
  int numECBytes;
  int numRSBlocks;
  ZXByteMatrix * matrix;
}

@property(nonatomic, retain) ZXMode * mode;
@property(nonatomic, retain) ZXErrorCorrectionLevel * ecLevel;
@property(nonatomic) int version;
@property(nonatomic) int matrixWidth;
@property(nonatomic) int maskPattern;
@property(nonatomic) int numTotalBytes;
@property(nonatomic) int numDataBytes;
@property(nonatomic) int numECBytes;
@property(nonatomic) int numRSBlocks;
@property(nonatomic, retain) ZXByteMatrix * matrix;
@property(nonatomic, readonly) BOOL valid;

- (int) at:(int)x y:(int)y;
+ (BOOL) isValidMaskPattern:(int)maskPattern;

@end
