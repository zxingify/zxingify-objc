#import "ZXUPCEANReader.h"

/**
 * <p>Implements decoding of the EAN-8 format.</p>
 * 
 * @author Sean Owen
 */

@interface ZXEAN8Reader : ZXUPCEANReader {
  int decodeMiddleCounters[4];
}

@end
