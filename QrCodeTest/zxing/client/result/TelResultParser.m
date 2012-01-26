#import "TelResultParser.h"

@implementation TelResultParser

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

+ (TelParsedResult *) parse:(Result *)result {
  NSString * rawText = [result text];
  if (rawText == nil || (![rawText hasPrefix:@"tel:"] && ![rawText hasPrefix:@"TEL:"])) {
    return nil;
  }
  NSString * telURI = [rawText hasPrefix:@"TEL:"] ? [@"tel:" stringByAppendingString:[rawText substringFromIndex:4]] : rawText;
  int queryStart = [rawText rangeOfString:'?' param1:4];
  NSString * number = queryStart < 0 ? [rawText substringFromIndex:4] : [rawText substringFromIndex:4 param1:queryStart];
  return [[[TelParsedResult alloc] init:number param1:telURI param2:nil] autorelease];
}

@end
