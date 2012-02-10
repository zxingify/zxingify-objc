/**
 * <p>Encapsulates a block of data within a Data Matrix Code. Data Matrix Codes may split their data into
 * multiple blocks, each of which is a unit of data and error-correction codewords. Each
 * is represented by an instance of this class.</p>
 * 
 * @author bbrown@google.com (Brian Brown)
 */

@class DataMatrixVersion;

@interface DataMatrixDataBlock : NSObject {
  int numDataCodewords;
  NSMutableArray * codewords;
}

@property (nonatomic, readonly) int numDataCodewords;
@property (nonatomic, readonly) NSMutableArray * codewords;

+ (NSArray *) getDataBlocks:(NSArray *)rawCodewords version:(DataMatrixVersion *)version;

@end
