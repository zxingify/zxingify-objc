#import "Result.h"
#import "SMSMMSResultParser.h"
#import "SMSParsedResult.h"

@implementation SMSMMSResultParser

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
  if (!([rawText hasPrefix:@"sms:"] || [rawText hasPrefix:@"SMS:"] || [rawText hasPrefix:@"mms:"] || [rawText hasPrefix:@"MMS:"])) {
    return nil;
  }
  NSMutableDictionary * nameValuePairs = [self parseNameValuePairs:rawText];
  NSString * subject = nil;
  NSString * body = nil;
  BOOL querySyntax = NO;
  if (nameValuePairs != nil && ![nameValuePairs empty]) {
    subject = (NSString *)[nameValuePairs objectForKey:@"subject"];
    body = (NSString *)[nameValuePairs objectForKey:@"body"];
    querySyntax = YES;
  }
  int queryStart = [rawText rangeOfString:'?' param1:4];
  NSString * smsURIWithoutQuery;
  if (queryStart < 0 || !querySyntax) {
    smsURIWithoutQuery = [rawText substringFromIndex:4];
  }
   else {
    smsURIWithoutQuery = [rawText substringFromIndex:4 param1:queryStart];
  }
  int lastComma = -1;
  int comma;
  NSMutableArray * numbers = [[[NSMutableArray alloc] init:1] autorelease];
  NSMutableArray * vias = [[[NSMutableArray alloc] init:1] autorelease];

  while ((comma = [smsURIWithoutQuery rangeOfString:',' param1:lastComma + 1]) > lastComma) {
    NSString * numberPart = [smsURIWithoutQuery substringFromIndex:lastComma + 1 param1:comma];
    [self addNumberVia:numbers vias:vias numberPart:numberPart];
    lastComma = comma;
  }

  [self addNumberVia:numbers vias:vias numberPart:[smsURIWithoutQuery substringFromIndex:lastComma + 1]];
  return [[[SMSParsedResult alloc] init:[self toStringArray:numbers] param1:[self toStringArray:vias] param2:subject param3:body] autorelease];
}

+ (void) addNumberVia:(NSMutableArray *)numbers vias:(NSMutableArray *)vias numberPart:(NSString *)numberPart {
  int numberEnd = [numberPart rangeOfString:';'];
  if (numberEnd < 0) {
    [numbers addObject:numberPart];
    [vias addObject:nil];
  }
   else {
    [numbers addObject:[numberPart substringFromIndex:0 param1:numberEnd]];
    NSString * maybeVia = [numberPart substringFromIndex:numberEnd + 1];
    NSString * via;
    if ([maybeVia hasPrefix:@"via="]) {
      via = [maybeVia substringFromIndex:4];
    }
     else {
      via = nil;
    }
    [vias addObject:via];
  }
}

@end
