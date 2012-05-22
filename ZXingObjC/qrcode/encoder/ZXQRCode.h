extern int const NUM_MASK_PATTERNS;

@class ZXByteMatrix, ZXErrorCorrectionLevel, ZXMode;

@interface ZXQRCode : NSObject

@property (nonatomic, retain) ZXMode * mode;
@property (nonatomic, retain) ZXErrorCorrectionLevel * ecLevel;
@property (nonatomic, assign) int version;
@property (nonatomic, assign) int matrixWidth;
@property (nonatomic, assign) int maskPattern;
@property (nonatomic, assign) int numTotalBytes;
@property (nonatomic, assign) int numDataBytes;
@property (nonatomic, assign) int numECBytes;
@property (nonatomic, assign) int numRSBlocks;
@property (nonatomic, retain) ZXByteMatrix * matrix;

- (int)atX:(int)x y:(int)y;
- (BOOL)isValid;
+ (BOOL)isValidMaskPattern:(int)maskPattern;

@end
