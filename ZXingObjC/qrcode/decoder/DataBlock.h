
/**
 * <p>Encapsulates a block of data within a QR Code. QR Codes may split their data into
 * multiple blocks, each of which is a unit of data and error-correction codewords. Each
 * is represented by an instance of this class.</p>
 * 
 * @author Sean Owen
 */

@interface DataBlock : NSObject {
  int numDataCodewords;
  NSArray * codewords;
}

+ (NSArray *) getDataBlocks:(NSArray *)rawCodewords version:(Version *)version ecLevel:(ErrorCorrectionLevel *)ecLevel;
- (int) getNumDataCodewords;
- (NSArray *) getCodewords;
@end
