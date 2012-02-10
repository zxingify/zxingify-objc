#import "BitMatrix.h"
#import "Code39Writer.h"
#import "Code128Writer.h"
#import "EAN8Writer.h"
#import "EAN13Writer.h"
#import "ITFWriter.h"
#import "MultiFormatWriter.h"
#import "UPCAWriter.h"
#import "QRCodeWriter.h"

@implementation MultiFormatWriter

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat)format width:(int)width height:(int)height {
  return [self encode:contents format:format width:width height:height hints:nil];
}

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints {
  id<Writer> writer;
  if (format == kBarcodeFormatEan8) {
    writer = [[[EAN8Writer alloc] init] autorelease];
  } else if (format == kBarcodeFormatEan13) {
    writer = [[[EAN13Writer alloc] init] autorelease];
  } else if (format == kBarcodeFormatUPCA) {
    writer = [[[UPCAWriter alloc] init] autorelease];
  } else if (format == kBarcodeFormatQRCode) {
    writer = [[[QRCodeWriter alloc] init] autorelease];
  } else if (format == kBarcodeFormatCode39) {
    writer = [[[Code39Writer alloc] init] autorelease];
  } else if (format == kBarcodeFormatCode128) {
    writer = [[[Code128Writer alloc] init] autorelease];
  } else if (format == kBarcodeFormatITF) {
    writer = [[[ITFWriter alloc] init] autorelease];
  } else {
    [NSException raise:NSInvalidArgumentException 
                format:@"No encoder available for format"];
  }
  return [writer encode:contents format:format width:width height:height hints:hints];
}

@end
