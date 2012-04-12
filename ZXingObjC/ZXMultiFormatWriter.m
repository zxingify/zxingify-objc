#import "ZXBitMatrix.h"
#import "ZXCode39Writer.h"
#import "ZXCode128Writer.h"
#import "ZXEAN8Writer.h"
#import "ZXEAN13Writer.h"
#import "ZXITFWriter.h"
#import "ZXMultiFormatWriter.h"
#import "ZXUPCAWriter.h"
#import "ZXQRCodeWriter.h"

@implementation ZXMultiFormatWriter

- (ZXBitMatrix *) encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height {
  return [self encode:contents format:format width:width height:height hints:nil];
}

- (ZXBitMatrix *) encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints {
  id<ZXWriter> writer;
  if (format == kBarcodeFormatEan8) {
    writer = [[[ZXEAN8Writer alloc] init] autorelease];
  } else if (format == kBarcodeFormatEan13) {
    writer = [[[ZXEAN13Writer alloc] init] autorelease];
  } else if (format == kBarcodeFormatUPCA) {
    writer = [[[ZXUPCAWriter alloc] init] autorelease];
  } else if (format == kBarcodeFormatQRCode) {
    writer = [[[ZXQRCodeWriter alloc] init] autorelease];
  } else if (format == kBarcodeFormatCode39) {
    writer = [[[ZXCode39Writer alloc] init] autorelease];
  } else if (format == kBarcodeFormatCode128) {
    writer = [[[ZXCode128Writer alloc] init] autorelease];
  } else if (format == kBarcodeFormatITF) {
    writer = [[[ZXITFWriter alloc] init] autorelease];
  } else {
    [NSException raise:NSInvalidArgumentException 
                format:@"No encoder available for format"];
  }
  return [writer encode:contents format:format width:width height:height hints:hints];
}

@end
