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
#import "ZXWifiResultParser.h"
#import "ZXWifiParsedResult.h"

@implementation ZXWifiResultParser

+ (ZXWifiParsedResult *)parse:(ZXResult *)result {
  NSString * rawText = [result text];

  if (rawText == nil || ![rawText hasPrefix:@"WIFI:"]) {
    return nil;
  }

  BOOL trim = NO;
  NSString * ssid = [self matchSinglePrefixedField:@"S:" rawText:rawText endChar:';' trim:trim];
  NSString * pass = [self matchSinglePrefixedField:@"P:" rawText:rawText endChar:';' trim:trim];
  NSString * type = [self matchSinglePrefixedField:@"T:" rawText:rawText endChar:';' trim:trim];

  return [[[ZXWifiParsedResult alloc] initWithNetworkEncryption:type ssid:ssid password:pass] autorelease];
}

@end
