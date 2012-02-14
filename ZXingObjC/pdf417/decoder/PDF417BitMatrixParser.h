#import "FormatException.h"
#import "NotFoundException.h"
#import "BitMatrix.h"

/**
 * <p>
 * This class parses the BitMatrix image into codewords.
 * </p>
 * 
 * @author SITA Lab (kevin.osullivan@sita.aero)
 */

@interface PDF417BitMatrixParser : NSObject {
  BitMatrix * bitMatrix;
  int rows;
  int leftColumnECData;
  int rightColumnECData;
  int eraseCount;
  NSArray * erasures;
  int ecLevel;
}

@property(nonatomic, retain, readonly) NSArray * erasures;
@property(nonatomic, readonly) int eCLevel;
- (id) initWithBitMatrix:(BitMatrix *)bitMatrix;
- (NSArray *) readCodewords;
- (int) processRow:(NSArray *)rowCounters rowNumber:(int)rowNumber rowHeight:(int)rowHeight codewords:(NSArray *)codewords next:(int)next;
@end
