/**
 * Encapsulates a block of data within a QR Code. QR Codes may split their data into
 * multiple blocks, each of which is a unit of data and error-correction codewords. Each
 * is represented by an instance of this class.
 */

@class ZXErrorCorrectionLevel, ZXQRCodeVersion;

@interface ZXQRCodeDataBlock : NSObject

@property (nonatomic, retain, readonly) NSMutableArray * codewords;
@property (nonatomic, assign, readonly) int numDataCodewords;

- (id)initWithNumDataCodewords:(int)numDataCodewords codewords:(NSMutableArray *)codewords;
+ (NSArray *)dataBlocks:(NSArray *)rawCodewords version:(ZXQRCodeVersion *)version ecLevel:(ZXErrorCorrectionLevel *)ecLevel;

@end
