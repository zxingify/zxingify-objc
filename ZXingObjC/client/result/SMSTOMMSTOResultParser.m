#import "Result.h"
#import "SMSTOMMSTOResultParser.h"
#import "SMSParsedResult.h"

@implementation SMSTOMMSTOResultParser

+ (SMSParsedResult *) parse:(Result *)result {
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
  return [[[SMSParsedResult alloc] initWithNumber:number via:nil subject:nil body:body] autorelease];
}

@end
