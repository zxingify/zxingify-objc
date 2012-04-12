#import "ZXBarcodeFormat.h"
#import "ZXProductParsedResult.h"
#import "ZXProductResultParser.h"
#import "ZXUPCEReader.h"

@implementation ZXProductResultParser

+ (ZXProductParsedResult *) parse:(ZXResult *)result {
  ZXBarcodeFormat format = [result barcodeFormat];
  if (!(format == kBarcodeFormatUPCA || format == kBarcodeFormatUPCE || format == kBarcodeFormatEan8 || format == kBarcodeFormatEan13)) {
    return nil;
  }
  NSString * rawText = [result text];
  if (rawText == nil) {
    return nil;
  }
  int length = [rawText length];

  for (int x = 0; x < length; x++) {
    unichar c = [rawText characterAtIndex:x];
    if (c < '0' || c > '9') {
      return nil;
    }
  }

  NSString * normalizedProductID;
  if (format == kBarcodeFormatUPCE) {
    normalizedProductID = [ZXUPCEReader convertUPCEtoUPCA:rawText];
  } else {
    normalizedProductID = rawText;
  }
  return [[[ZXProductParsedResult alloc] initWithProductID:rawText normalizedProductID:normalizedProductID] autorelease];
}

@end
