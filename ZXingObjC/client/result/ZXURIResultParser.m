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

#import "ZXURIResultParser.h"
#import "ZXResult.h"
#import "ZXURIParsedResult.h"

static NSString* PATTERN_END =
  @"(:\\d{1,5})?" // maybe port
  @"(/|\\?|$)"; // query, path or nothing

static NSRegularExpression* URL_WITH_PROTOCOL_PATTERN = nil;
static NSRegularExpression* URL_WITHOUT_PROTOCOL_PATTERN = nil;

@implementation ZXURIResultParser

+ (void)initialize {
  URL_WITH_PROTOCOL_PATTERN = [[NSRegularExpression alloc] initWithPattern:
                               [@"^[a-zA-Z0-9]{2,}:(/)*" // protocol
                                @"[a-zA-Z0-9\\-]+(\\.[a-zA-Z0-9\\-]+)*" // host name elements
                                stringByAppendingString:PATTERN_END]
                                                                   options:0 error:nil];
  URL_WITHOUT_PROTOCOL_PATTERN = [[NSRegularExpression alloc] initWithPattern:
                                  [@"([a-zA-Z0-9\\-]+\\.)+[a-zA-Z0-9\\-]{2,}" // host name elements
                                   stringByAppendingString:PATTERN_END]
                                                                      options:0 error:nil];
}

- (ZXParsedResult *)parse:(ZXResult *)result {
  NSString * rawText = [ZXResultParser massagedText:result];
  // We specifically handle the odd "URL" scheme here for simplicity
  if ([rawText hasPrefix:@"URL:"]) {
    rawText = [rawText substringFromIndex:4];
  }
  rawText = [rawText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  return [[self class] isBasicallyValidURI:rawText] ? [ZXURIParsedResult uriParsedResultWithUri:rawText title:nil] : nil;
}


+ (BOOL)isBasicallyValidURI:(NSString *)uri {
  if ([URL_WITH_PROTOCOL_PATTERN numberOfMatchesInString:uri options:NSRegularExpressionAnchorsMatchLines range:NSMakeRange(0, uri.length)] > 0) { // match at start only
    return YES;
  }
  return [URL_WITHOUT_PROTOCOL_PATTERN numberOfMatchesInString:uri options:NSRegularExpressionAnchorsMatchLines range:NSMakeRange(0, uri.length)] > 0;
}

@end
