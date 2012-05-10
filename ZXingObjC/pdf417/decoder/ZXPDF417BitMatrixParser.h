/**
 * This class parses the BitMatrix image into codewords.
 */

@class ZXBitMatrix;

@interface ZXPDF417BitMatrixParser : NSObject

@property (nonatomic, retain, readonly) NSMutableArray * erasures;
@property (nonatomic, assign, readonly) int ecLevel;

- (id)initWithBitMatrix:(ZXBitMatrix *)bitMatrix;
- (NSArray *)readCodewords;
- (int)processRow:(int*)rowCounters rowCountersLen:(unsigned int)rowCountersLen rowNumber:(int)rowNumber rowHeight:(int)rowHeight codewords:(NSMutableArray *)codewords next:(int)next;

@end
