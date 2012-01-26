#import "ErrorCorrectionLevel.h"
#import "Mode.h"

/**
 * @author satorux@google.com (Satoru Takabayashi) - creator
 * @author dswitkin@google.com (Daniel Switkin) - ported from C++
 */

extern int const NUM_MASK_PATTERNS;

@interface QRCode : NSObject {
  Mode * mode;
  ErrorCorrectionLevel * ecLevel;
  int version;
  int matrixWidth;
  int maskPattern;
  int numTotalBytes;
  int numDataBytes;
  int numECBytes;
  int numRSBlocks;
  ByteMatrix * matrix;
}

@property(nonatomic, retain) Mode * mode;
@property(nonatomic, retain) ErrorCorrectionLevel * eCLevel;
@property(nonatomic) int version;
@property(nonatomic) int matrixWidth;
@property(nonatomic) int maskPattern;
@property(nonatomic) int numTotalBytes;
@property(nonatomic) int numDataBytes;
@property(nonatomic) int numECBytes;
@property(nonatomic) int numRSBlocks;
@property(nonatomic, retain) ByteMatrix * matrix;
@property(nonatomic, readonly) BOOL valid;
- (id) init;
- (int) at:(int)x y:(int)y;
- (NSString *) description;
- (void) setMode:(Mode *)value;
- (void) setECLevel:(ErrorCorrectionLevel *)value;
- (void) setVersion:(int)value;
- (void) setMatrixWidth:(int)value;
- (void) setMaskPattern:(int)value;
- (void) setNumTotalBytes:(int)value;
- (void) setNumDataBytes:(int)value;
- (void) setNumECBytes:(int)value;
- (void) setNumRSBlocks:(int)value;
- (void) setMatrix:(ByteMatrix *)value;
+ (BOOL) isValidMaskPattern:(int)maskPattern;
@end
