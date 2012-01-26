#import "ISBNResultParser.h"

@implementation ISBNResultParser

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

+ (ISBNParsedResult *) parse:(Result *)result {
  BarcodeFormat * format = [result barcodeFormat];
  if (![BarcodeFormat.EAN_13 isEqualTo:format]) {
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
  return [[[ISBNParsedResult alloc] init:rawText] autorelease];
}

@end
