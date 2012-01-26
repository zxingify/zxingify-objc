#import "SMSTOMMSTOResultParser.h"

@implementation SMSTOMMSTOResultParser

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

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
  int bodyStart = [number rangeOfString:':'];
  if (bodyStart >= 0) {
    body = [number substringFromIndex:bodyStart + 1];
    number = [number substringFromIndex:0 param1:bodyStart];
  }
  return [[[SMSParsedResult alloc] init:number param1:nil param2:nil param3:body] autorelease];
}

@end
