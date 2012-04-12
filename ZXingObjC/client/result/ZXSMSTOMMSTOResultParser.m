#import "ZXResult.h"
#import "ZXSMSTOMMSTOResultParser.h"
#import "ZXSMSParsedResult.h"

@implementation ZXSMSTOMMSTOResultParser

+ (ZXSMSParsedResult *) parse:(ZXResult *)result {
  NSString * rawText = [result text];
  if (rawText == nil) {
    return nil;
  }
  if (!([rawText hasPrefix:@"smsto:"] || [rawText hasPrefix:@"SMSTO:"] || [rawText hasPrefix:@"mmsto:"] || [rawText hasPrefix:@"MMSTO:"])) {
    return nil;
  }
  NSString * number = [rawText substringFromIndex:6];
  NSString * body = nil;
  int bodyStart = [number rangeOfString:@":"].location;
  if (bodyStart >= 0) {
    body = [number substringFromIndex:bodyStart + 1];
    number = [number substringToIndex:bodyStart];
  }
  return [[[ZXSMSParsedResult alloc] initWithNumber:number via:nil subject:nil body:body] autorelease];
}

@end
