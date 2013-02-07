/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXResult.h"
#import "ZXSMSMMSResultParser.h"
#import "ZXSMSParsedResult.h"

@interface ZXSMSMMSResultParser ()

- (void)addNumberVia:(NSMutableArray *)numbers vias:(NSMutableArray *)vias numberPart:(NSString *)numberPart;

@end

@implementation ZXSMSMMSResultParser

- (ZXParsedResult *)parse:(ZXResult *)result {
  NSString *rawText = [ZXResultParser massagedText:result];
  if (!([rawText hasPrefix:@"sms:"] || [rawText hasPrefix:@"SMS:"] || [rawText hasPrefix:@"mms:"] || [rawText hasPrefix:@"MMS:"])) {
    return nil;
  }

  NSMutableDictionary *nameValuePairs = [self parseNameValuePairs:rawText];
  NSString *subject = nil;
  NSString *body = nil;
  BOOL querySyntax = NO;
  if (nameValuePairs != nil && [nameValuePairs count] > 0) {
    subject = [nameValuePairs objectForKey:@"subject"];
    body = [nameValuePairs objectForKey:@"body"];
    querySyntax = YES;
  }

  int queryStart = [rawText rangeOfString:@"?" options:NSLiteralSearch range:NSMakeRange(4, [rawText length] - 4)].location;
  NSString *smsURIWithoutQuery;
  if (queryStart == NSNotFound || !querySyntax) {
    smsURIWithoutQuery = [rawText substringFromIndex:4];
  } else {
    smsURIWithoutQuery = [rawText substringWithRange:NSMakeRange(4, queryStart - 4)];
  }

  int lastComma = -1;
  int comma;
  NSMutableArray *numbers = [NSMutableArray arrayWithCapacity:1];
  NSMutableArray *vias = [NSMutableArray arrayWithCapacity:1];
  while ((comma = [smsURIWithoutQuery rangeOfString:@"," options:NSLiteralSearch range:NSMakeRange(lastComma + 1, [smsURIWithoutQuery length] - lastComma - 1)].location) > lastComma && comma != NSNotFound) {
    NSString *numberPart = [smsURIWithoutQuery substringWithRange:NSMakeRange(lastComma + 1, comma - lastComma - 1)];
    [self addNumberVia:numbers vias:vias numberPart:numberPart];
    lastComma = comma;
  }
  [self addNumberVia:numbers vias:vias numberPart:[smsURIWithoutQuery substringFromIndex:lastComma + 1]];

  return [ZXSMSParsedResult smsParsedResultWithNumbers:numbers
                                                  vias:vias
                                               subject:subject
                                                  body:body];
}

- (void)addNumberVia:(NSMutableArray *)numbers vias:(NSMutableArray *)vias numberPart:(NSString *)numberPart {
  int numberEnd = [numberPart rangeOfString:@";"].location;
  if (numberEnd == NSNotFound) {
    [numbers addObject:numberPart];
    [vias addObject:[NSNull null]];
  } else {
    [numbers addObject:[numberPart substringToIndex:numberEnd]];
    NSString *maybeVia = [numberPart substringFromIndex:numberEnd + 1];
    NSString *via;
    if ([maybeVia hasPrefix:@"via="]) {
      via = [maybeVia substringFromIndex:4];
    } else {
      via = nil;
    }
    [vias addObject:via];
  }
}

@end
