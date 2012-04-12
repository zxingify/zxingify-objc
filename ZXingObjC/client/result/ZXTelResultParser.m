#import "ZXTelParsedResult.h"
#import "ZXTelResultParser.h"

@implementation ZXTelResultParser

+ (ZXTelParsedResult *) parse:(ZXResult *)result {
  NSString * rawText = [result text];
  if (rawText == nil || (![rawText hasPrefix:@"tel:"] && ![rawText hasPrefix:@"TEL:"])) {
    return nil;
  }
  NSString * telURI = [rawText hasPrefix:@"TEL:"] ? [@"tel:" stringByAppendingString:[rawText substringFromIndex:4]] : rawText;
  int queryStart = [rawText rangeOfString:@"?" options:NSLiteralSearch range:NSMakeRange(4, [rawText length] - 4)].location;
  NSString * number = queryStart < 0 ? [rawText substringFromIndex:4] : [rawText substringWithRange:NSMakeRange(4, [rawText length] - queryStart)];
  return [[[ZXTelParsedResult alloc] initWithNumber:number telURI:telURI title:nil] autorelease];
}

@end
