/**
 * <p>
 * This class parses the BitMatrix image into codewords.
 * </p>
 * 
 * @author SITA Lab (kevin.osullivan@sita.aero)
 */

@class ZXBitMatrix;

@interface ZXPDF417BitMatrixParser : NSObject {
  ZXBitMatrix * bitMatrix;
  int rows;
  int leftColumnECData;
  int rightColumnECData;
  int eraseCount;
  NSMutableArray * erasures;
  int ecLevel;
}

@property(nonatomic, readonly) NSMutableArray * erasures;
@property(nonatomic, readonly) int ecLevel;

- (id) initWithBitMatrix:(ZXBitMatrix *)bitMatrix;
- (NSArray *) readCodewords;
- (int) processRow:(int[])rowCounters rowNumber:(int)rowNumber rowHeight:(int)rowHeight codewords:(NSMutableArray *)codewords next:(int)next;

@end
