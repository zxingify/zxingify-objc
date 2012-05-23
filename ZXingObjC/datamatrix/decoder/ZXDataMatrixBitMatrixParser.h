@class ZXBitMatrix, ZXDataMatrixVersion;

@interface ZXDataMatrixBitMatrixParser : NSObject

@property (nonatomic, retain, readonly) ZXDataMatrixVersion* version;

- (id)initWithBitMatrix:(ZXBitMatrix *)bitMatrix error:(NSError**)error;
- (NSArray *)readCodewords;
- (BOOL)readModule:(int)row column:(int)column numRows:(int)numRows numColumns:(int)numColumns;
- (int)readUtah:(int)row column:(int)column numRows:(int)numRows numColumns:(int)numColumns;
- (int)readCorner1:(int)numRows numColumns:(int)numColumns;
- (int)readCorner2:(int)numRows numColumns:(int)numColumns;
- (int)readCorner3:(int)numRows numColumns:(int)numColumns;
- (int)readCorner4:(int)numRows numColumns:(int)numColumns;
- (ZXBitMatrix *)extractDataRegion:(ZXBitMatrix *)bitMatrix;

@end
