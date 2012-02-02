#import "MultiFormatWriter.h"
#import "Writer.h"

@implementation MultiFormatWriter

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height {
  return [self encode:contents format:format width:width height:height hints:nil];
}

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints {
  Writer * writer;
  if (format == BarcodeFormat.EAN_8) {
    writer = [[[EAN8Writer alloc] init] autorelease];
  }
   else if (format == BarcodeFormat.EAN_13) {
    writer = [[[EAN13Writer alloc] init] autorelease];
  }
   else if (format == BarcodeFormat.UPC_A) {
    writer = [[[UPCAWriter alloc] init] autorelease];
  }
   else if (format == BarcodeFormat.QR_CODE) {
    writer = [[[QRCodeWriter alloc] init] autorelease];
  }
   else if (format == BarcodeFormat.CODE_39) {
    writer = [[[Code39Writer alloc] init] autorelease];
  }
   else if (format == BarcodeFormat.CODE_128) {
    writer = [[[Code128Writer alloc] init] autorelease];
  }
   else if (format == BarcodeFormat.ITF) {
    writer = [[[ITFWriter alloc] init] autorelease];
  }
   else {
    @throw [[[IllegalArgumentException alloc] init:[@"No encoder available for format " stringByAppendingString:format]] autorelease];
  }
  return [writer encode:contents param1:format param2:width param3:height param4:hints];
}

@end
