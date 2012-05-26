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

#import "ZXNDEFRecord.h"
#import "ZXNDEFTextResultParser.h"
#import "ZXResult.h"
#import "ZXTextParsedResult.h"

@implementation ZXNDEFTextResultParser

+ (ZXTextParsedResult *)parse:(ZXResult *)result {
  unsigned char * bytes = [result rawBytes];
  if (bytes == nil) {
    return nil;
  }
  ZXNDEFRecord * ndefRecord = [ZXNDEFRecord readRecord:bytes offset:0];
  if (ndefRecord == nil || ![ndefRecord messageBegin] || ![ndefRecord messageEnd]) {
    return nil;
  }
  if (![[ndefRecord type] isEqualToString:TEXT_WELL_KNOWN_TYPE]) {
    return nil;
  }
  NSArray * languageText = [self decodeTextPayload:[ndefRecord payload] length:[ndefRecord payloadLength]];

  return [[[ZXTextParsedResult alloc] initWithText:[languageText objectAtIndex:0] language:[languageText objectAtIndex:1]] autorelease];
}

+ (NSArray *)decodeTextPayload:(unsigned char *)payload length:(unsigned int)length {
  char statusByte = payload[0];
  BOOL isUTF16 = (statusByte & 0x80) != 0;
  int languageLength = statusByte & 0x1F;
  NSString * language = [self bytesToString:payload offset:1 length:languageLength encoding:NSASCIIStringEncoding];
  NSStringEncoding encoding = isUTF16 ? NSUTF16StringEncoding : NSUTF8StringEncoding;
  NSString * text = [self bytesToString:payload
                                 offset:1 + languageLength
                                 length:length - languageLength - 1
                               encoding:encoding];
  return [NSArray arrayWithObjects:language, text, nil];
}

@end
