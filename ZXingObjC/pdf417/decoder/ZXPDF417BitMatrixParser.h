/**
 * This class parses the BitMatrix image into codewords.
 */

@class ZXBitMatrix;

@interface ZXPDF417BitMatrixParser : NSObject

@property (nonatomic, retain, readonly) NSMutableArray * erasures;
@property (nonatomic, assign, readonly) int ecLevel;

- (id)initWithBitMatrix:(ZXBitMatrix *)bitMatrix;
- (NSArray *)readCodewords;

@end
