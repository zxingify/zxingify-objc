#import "ZXResult.h"
#import "ZXSMSMMSResultParser.h"
#import "ZXSMSParsedResult.h"

@interface ZXSMSMMSResultParser ()

+ (void) addNumberVia:(NSMutableArray *)numbers vias:(NSMutableArray *)vias numberPart:(NSString *)numberPart;

@end

@implementation ZXSMSMMSResultParser

+ (ZXSMSParsedResult *) parse:(ZXResult *)result {
  NSString * rawText = [result text];
  if (rawText == nil) {
    return nil;
  }
  if (!([rawText hasPrefix:@"sms:"] || [rawText hasPrefix:@"SMS:"] || [rawText hasPrefix:@"mms:"] || [rawText hasPrefix:@"MMS:"])) {
    return nil;
  }

  NSMutableDictionary * nameValuePairs = [self parseNameValuePairs:rawText];
  NSString * subject = nil;
  NSString * body = nil;
  BOOL querySyntax = NO;
  if (nameValuePairs != nil && [nameValuePairs count] > 0) {
    subject = [nameValuePairs objectForKey:@"subject"];
    body = [nameValuePairs objectForKey:@"body"];
    querySyntax = YES;
  }

  int queryStart = [rawText rangeOfString:@"?" options:NSLiteralSearch range:NSMakeRange(4, [rawText length] - 4)].location;
  NSString * smsURIWithoutQuery;
  if (queryStart < 0 || !querySyntax) {
    smsURIWithoutQuery = [rawText substringFromIndex:4];
  } else {
    smsURIWithoutQuery = [rawText substringWithRange:NSMakeRange(4, [rawText length] - queryStart)];
  }

  int lastComma = -1;
  int comma;
  NSMutableArray * numbers = [NSMutableArray arrayWithCapacity:1];
  NSMutableArray * vias = [NSMutableArray arrayWithCapacity:1];
  while ((comma = [smsURIWithoutQuery rangeOfString:@"," options:NSLiteralSearch range:NSMakeRange(lastComma + 1, [smsURIWithoutQuery length] - lastComma - 1)].location) > lastComma) {
    NSString * numberPart = [smsURIWithoutQuery substringWithRange:NSMakeRange(lastComma + 1, [smsURIWithoutQuery length] - comma)];
    [self addNumberVia:numbers vias:vias numberPart:numberPart];
    lastComma = comma;
  }
  [self addNumberVia:numbers vias:vias numberPart:[smsURIWithoutQuery substringFromIndex:lastComma + 1]];

  return [[[ZXSMSParsedResult alloc] initWithNumbers:numbers
                                                vias:vias
                                             subject:subject
                                                body:body] autorelease];
}

+ (void) addNumberVia:(NSMutableArray *)numbers vias:(NSMutableArray *)vias numberPart:(NSString *)numberPart {
  int numberEnd = [numberPart rangeOfString:@";"].location;
  if (numberEnd < 0) {
    [numbers addObject:numberPart];
    [vias addObject:nil];
  } else {
    [numbers addObject:[numberPart substringToIndex:numberEnd]];
    NSString * maybeVia = [numberPart substringFromIndex:numberEnd + 1];
    NSString * via;
    if ([maybeVia hasPrefix:@"via="]) {
      via = [maybeVia substringFromIndex:4];
    } else {
      via = nil;
    }
    [vias addObject:via];
  }
}

@end
