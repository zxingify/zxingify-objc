#import "BarcodeFormat.h"
#import "ProductParsedResult.h"
#import "ProductResultParser.h"
#import "UPCEReader.h"

@implementation ProductResultParser

+ (ProductParsedResult *) parse:(Result *)result {
  BarcodeFormat format = [result barcodeFormat];
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
    normalizedProductID = [UPCEReader convertUPCEtoUPCA:rawText];
  } else {
    normalizedProductID = rawText;
  }
  return [[[ProductParsedResult alloc] initWithProductID:rawText normalizedProductID:normalizedProductID] autorelease];
}

@end
