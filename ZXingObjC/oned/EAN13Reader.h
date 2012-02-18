#import "UPCEANReader.h"

/**
 * <p>Implements decoding of the EAN-13 format.</p>
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 * @author alasdair@google.com (Alasdair Mackintosh)
 */

@interface EAN13Reader : UPCEANReader {
  int* decodeMiddleCounters;
}

@end
