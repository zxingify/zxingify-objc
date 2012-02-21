#import "UPCEANReader.h"

/**
 * <p>Implements decoding of the EAN-8 format.</p>
 * 
 * @author Sean Owen
 */

@interface EAN8Reader : UPCEANReader {
  int decodeMiddleCounters[4];
}

@end
