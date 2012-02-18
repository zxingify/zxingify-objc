#import "UPCEANReader.h"

/**
 * <p>Implements decoding of the UPC-A format.</p>
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 */

@interface UPCAReader : UPCEANReader {
  UPCEANReader * ean13Reader;
}

@end
