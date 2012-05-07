/**
 * Encapsulates a set of error-correction blocks in one symbol version. Most versions will
 * use blocks of differing sizes within one version, so, this encapsulates the parameters for
 * each set of blocks. It also holds the number of error-correction codewords per block since it
 * will be the same across all blocks within one version.
 */

@interface ZXDataMatrixECBlocks : NSObject

@property (nonatomic, retain, readonly) NSArray * ecBlocks;
@property (nonatomic, assign, readonly) int ecCodewords;

@end

/**
 * Encapsualtes the parameters for one error-correction block in one symbol version.
 * This includes the number of data codewords, and the number of times a block with these
 * parameters is used consecutively in the Data Matrix code version's format.
 */

@interface ZXDataMatrixECB : NSObject

@property (nonatomic, assign, readonly) int count;
@property (nonatomic, assign, readonly) int dataCodewords;

@end

/**
 * The Version object encapsulates attributes about a particular
 * size Data Matrix Code.
 */

@interface ZXDataMatrixVersion : NSObject

@property (nonatomic, retain, readonly) ZXDataMatrixECBlocks * ecBlocks;
@property (nonatomic, assign, readonly) int dataRegionSizeColumns;
@property (nonatomic, assign, readonly) int dataRegionSizeRows;
@property (nonatomic, assign, readonly) int symbolSizeColumns;
@property (nonatomic, assign, readonly) int symbolSizeRows;
@property (nonatomic, assign, readonly) int totalCodewords;
@property (nonatomic, assign, readonly) int versionNumber;

+ (ZXDataMatrixVersion *)versionForDimensions:(int)numRows numColumns:(int)numColumns;

@end
