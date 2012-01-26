#import "ProductResultParser.h"

@implementation ProductResultParser

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

+ (ProductParsedResult *) parse:(Result *)result {
  BarcodeFormat * format = [result barcodeFormat];
  if (!([BarcodeFormat.UPC_A isEqualTo:format] || [BarcodeFormat.UPC_E isEqualTo:format] || [BarcodeFormat.EAN_8 isEqualTo:format] || [BarcodeFormat.EAN_13 isEqualTo:format])) {
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
  if ([BarcodeFormat.UPC_E isEqualTo:format]) {
    normalizedProductID = [UPCEReader convertUPCEtoUPCA:rawText];
  }
   else {
    normalizedProductID = rawText;
  }
  return [[[ProductParsedResult alloc] init:rawText param1:normalizedProductID] autorelease];
}

@end
