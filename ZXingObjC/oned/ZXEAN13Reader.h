#import "ZXUPCEANReader.h"

/**
 * <p>Implements decoding of the EAN-13 format.</p>
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 * @author alasdair@google.com (Alasdair Mackintosh)
 */

extern int FIRST_DIGIT_ENCODINGS[10];

@interface ZXEAN13Reader : ZXUPCEANReader {
  int* decodeMiddleCounters;
}

- (int) decodeMiddle:(ZXBitArray *)row startRange:(NSArray *)startRange result:(NSMutableString *)resultString;

@end
