#import "ZXBitMatrix.h"
#import "ZXByteMatrix.h"
#import "ZXEncodeHints.h"
#import "ZXEncoder.h"
#import "ZXErrorCorrectionLevel.h"
#import "ZXQRCode.h"
#import "ZXQRCodeWriter.h"

int const QUIET_ZONE_SIZE = 4;

@interface ZXQRCodeWriter ()

- (ZXBitMatrix *)renderResult:(ZXQRCode *)code width:(int)width height:(int)height;

@end

@implementation ZXQRCodeWriter

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height {
  return [self encode:contents format:format width:width height:height hints:nil];
}

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height hints:(ZXEncodeHints *)hints {
  if (contents == nil || [contents length] == 0) {
    [NSException raise:NSInvalidArgumentException format:@"Found empty contents"];
  }

  if (format != kBarcodeFormatQRCode) {
    [NSException raise:NSInvalidArgumentException format:@"Can only encode QR_CODE"];
  }

  if (width < 0 || height < 0) {
    [NSException raise:NSInvalidArgumentException format:@"Requested dimensions are too small: %dx%d", width, height];
  }

  ZXErrorCorrectionLevel * errorCorrectionLevel = [ZXErrorCorrectionLevel errorCorrectionLevelL];
  if (hints != nil) {
    ZXErrorCorrectionLevel * requestedECLevel = hints.errorCorrectionLevel;
    if (requestedECLevel != nil) {
      errorCorrectionLevel = requestedECLevel;
    }
  }

  ZXQRCode * code = [[[ZXQRCode alloc] init] autorelease];
  [ZXEncoder encode:contents ecLevel:errorCorrectionLevel hints:hints qrCode:code];
  return [self renderResult:code width:width height:height];
}

- (ZXBitMatrix *)renderResult:(ZXQRCode *)code width:(int)width height:(int)height {
  ZXByteMatrix * input = code.matrix;
  int inputWidth = input.width;
  int inputHeight = input.height;
  int qrWidth = inputWidth + (QUIET_ZONE_SIZE << 1);
  int qrHeight = inputHeight + (QUIET_ZONE_SIZE << 1);
  int outputWidth = MAX(width, qrWidth);
  int outputHeight = MAX(height, qrHeight);

  int multiple = MIN(outputWidth / qrWidth, outputHeight / qrHeight);
  // Padding includes both the quiet zone and the extra white pixels to accommodate the requested
  // dimensions. For example, if input is 25x25 the QR will be 33x33 including the quiet zone.
  // If the requested size is 200x160, the multiple will be 4, for a QR of 132x132. These will
  // handle all the padding from 100x100 (the actual QR) up to 200x160.
  int leftPadding = (outputWidth - (inputWidth * multiple)) / 2;
  int topPadding = (outputHeight - (inputHeight * multiple)) / 2;

  ZXBitMatrix * output = [[[ZXBitMatrix alloc] initWithWidth:outputWidth height:outputHeight] autorelease];

  for (int inputY = 0, outputY = topPadding; inputY < inputHeight; inputY++, outputY += multiple) {
    for (int inputX = 0, outputX = leftPadding; inputX < inputWidth; inputX++, outputX += multiple) {
      if ([input getX:inputX y:inputY] == 1) {
        [output setRegionAtLeft:outputX top:outputY width:multiple height:multiple];
      }
    }
  }

  return output;
}

@end
