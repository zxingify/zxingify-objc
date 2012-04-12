/**
 * @author bbrown@google.com (Brian Brown)
 */

@class ZXBitMatrix, ZXDataMatrixVersion;

@interface ZXDataMatrixBitMatrixParser : NSObject {
  ZXBitMatrix * mappingBitMatrix;
  ZXBitMatrix * readMappingMatrix;
  ZXDataMatrixVersion * version;
}

@property (nonatomic, readonly) ZXDataMatrixVersion* version;

- (id) initWithBitMatrix:(ZXBitMatrix *)bitMatrix;
- (NSArray *) readCodewords;
- (BOOL) readModule:(int)row column:(int)column numRows:(int)numRows numColumns:(int)numColumns;
- (int) readUtah:(int)row column:(int)column numRows:(int)numRows numColumns:(int)numColumns;
- (int) readCorner1:(int)numRows numColumns:(int)numColumns;
- (int) readCorner2:(int)numRows numColumns:(int)numColumns;
- (int) readCorner3:(int)numRows numColumns:(int)numColumns;
- (int) readCorner4:(int)numRows numColumns:(int)numColumns;
- (ZXBitMatrix *) extractDataRegion:(ZXBitMatrix *)bitMatrix;

@end
