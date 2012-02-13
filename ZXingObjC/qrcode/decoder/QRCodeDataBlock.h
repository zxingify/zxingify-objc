/**
 * <p>Encapsulates a block of data within a QR Code. QR Codes may split their data into
 * multiple blocks, each of which is a unit of data and error-correction codewords. Each
 * is represented by an instance of this class.</p>
 * 
 * @author Sean Owen
 */

@class ErrorCorrectionLevel, QRCodeVersion;

@interface QRCodeDataBlock : NSObject {
  int numDataCodewords;
  NSMutableArray * codewords;
}

@property (nonatomic, readonly) NSMutableArray * codewords;
@property (nonatomic, readonly) int numDataCodewords;

- (id) init:(int)numDataCodewords codewords:(NSMutableArray *)codewords;
+ (NSArray *) getDataBlocks:(NSArray *)rawCodewords version:(QRCodeVersion *)version ecLevel:(ErrorCorrectionLevel *)ecLevel;

@end
