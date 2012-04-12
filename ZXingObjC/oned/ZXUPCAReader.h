#import "ZXUPCEANReader.h"

/**
 * <p>Implements decoding of the UPC-A format.</p>
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 */

@interface ZXUPCAReader : ZXUPCEANReader {
  ZXUPCEANReader * ean13Reader;
}

@end
