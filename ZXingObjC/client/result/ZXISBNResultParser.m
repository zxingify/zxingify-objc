#import "ZXISBNParsedResult.h"
#import "ZXISBNResultParser.h"

@implementation ZXISBNResultParser

+ (ZXISBNParsedResult *)parse:(ZXResult *)result {
  ZXBarcodeFormat format = [result barcodeFormat];
  if (format != kBarcodeFormatEan13) {
    return nil;
  }
  NSString * rawText = [result text];
  if (rawText == nil) {
    return nil;
  }
  int length = [rawText length];
  if (length != 13) {
    return nil;
  }
  if (![rawText hasPrefix:@"978"] && ![rawText hasPrefix:@"979"]) {
    return nil;
  }
  return [[[ZXISBNParsedResult alloc] initWithIsbn:rawText] autorelease];
}

@end
