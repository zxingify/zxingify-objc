/**
 * Encapsulates a block of data within a Data Matrix Code. Data Matrix Codes may split their data into
 * multiple blocks, each of which is a unit of data and error-correction codewords. Each
 * is represented by an instance of this class.
 */

@class ZXDataMatrixVersion;

@interface ZXDataMatrixDataBlock : NSObject

@property (nonatomic, assign, readonly) int numDataCodewords;
@property (nonatomic, retain, readonly) NSMutableArray * codewords;

+ (NSArray *)dataBlocks:(NSArray *)rawCodewords version:(ZXDataMatrixVersion *)version;

@end
