/**
 * <p>Encapsulates a set of error-correction blocks in one symbol version. Most versions will
 * use blocks of differing sizes within one version, so, this encapsulates the parameters for
 * each set of blocks. It also holds the number of error-correction codewords per block since it
 * will be the same across all blocks within one version.</p>
 */

@interface ZXDataMatrixECBlocks : NSObject {
  int ecCodewords;
  NSArray * ecBlocks;
}

@property (nonatomic, readonly) int ecCodewords;
@property (nonatomic, readonly) NSArray * ecBlocks;

@end

/**
 * <p>Encapsualtes the parameters for one error-correction block in one symbol version.
 * This includes the number of data codewords, and the number of times a block with these
 * parameters is used consecutively in the Data Matrix code version's format.</p>
 */

@interface ZXDataMatrixECB : NSObject {
  int count;
  int dataCodewords;
}

@property (nonatomic, readonly) int count;
@property (nonatomic, readonly) int dataCodewords;

@end

/**
 * The Version object encapsulates attributes about a particular
 * size Data Matrix Code.
 * 
 * @author bbrown@google.com (Brian Brown)
 */

@interface ZXDataMatrixVersion : NSObject {
  int versionNumber;
  int symbolSizeRows;
  int symbolSizeColumns;
  int dataRegionSizeRows;
  int dataRegionSizeColumns;
  ZXDataMatrixECBlocks * ecBlocks;
  int totalCodewords;
}

@property(nonatomic, readonly) int versionNumber;
@property(nonatomic, readonly) int symbolSizeRows;
@property(nonatomic, readonly) int symbolSizeColumns;
@property(nonatomic, readonly) int dataRegionSizeRows;
@property(nonatomic, readonly) int dataRegionSizeColumns;
@property(nonatomic, readonly) int totalCodewords;
@property(nonatomic, readonly) ZXDataMatrixECBlocks * ecBlocks;

+ (ZXDataMatrixVersion *) getVersionForDimensions:(int)numRows numColumns:(int)numColumns;

@end
