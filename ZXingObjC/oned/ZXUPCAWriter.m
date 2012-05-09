#import "ZXEAN13Writer.h"
#import "ZXUPCAWriter.h"

@interface ZXUPCAWriter ()

- (ZXEAN13Writer *)subWriter;
- (NSString *)preencode:(NSString *)contents;

@end

@implementation ZXUPCAWriter

static ZXEAN13Writer* subWriter = nil;

- (ZXEAN13Writer *)subWriter {
  static ZXEAN13Writer* subWriter = nil;
  if (!subWriter) {
    subWriter = [[ZXEAN13Writer alloc] init];
  }

  return subWriter;
}

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height {
  return [self encode:contents format:format width:width height:height hints:nil];
}

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height hints:(ZXEncodeHints *)hints {
  if (format != kBarcodeFormatUPCA) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"Can only encode UPC-A, but got %d", format]
                                 userInfo:nil];
  }
  return [subWriter encode:[self preencode:contents] format:kBarcodeFormatEan13 width:width height:height hints:hints];
}

/**
 * Transform a UPC-A code into the equivalent EAN-13 code, and add a check digit if it is not
 * already present.
 */
- (NSString *)preencode:(NSString *)contents {
  int length = [contents length];
  if (length == 11) {
    int sum = 0;

    for (int i = 0; i < 11; ++i) {
      sum += ([contents characterAtIndex:i] - '0') * (i % 2 == 0 ? 3 : 1);
    }

    contents = [contents stringByAppendingFormat:@"%", (1000 - sum) % 10];
  } else if (length != 12) {
     @throw [NSException exceptionWithName:NSInvalidArgumentException
                                    reason:[NSString stringWithFormat:@"Requested contents should be 11 or 12 digits long, but got %d", [contents length]]
                                  userInfo:nil];
  }
  return [NSString stringWithFormat:@"0%@", contents];
}

@end
