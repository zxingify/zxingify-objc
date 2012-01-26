#import "NDEFTextResultParser.h"

@implementation NDEFTextResultParser

+ (TextParsedResult *) parse:(Result *)result {
  NSArray * bytes = [result rawBytes];
  if (bytes == nil) {
    return nil;
  }
  NDEFRecord * ndefRecord = [NDEFRecord readRecord:bytes param1:0];
  if (ndefRecord == nil || ![ndefRecord messageBegin] || ![ndefRecord messageEnd]) {
    return nil;
  }
  if (![[ndefRecord type] isEqualTo:NDEFRecord.TEXT_WELL_KNOWN_TYPE]) {
    return nil;
  }
  NSArray * languageText = [self decodeTextPayload:[ndefRecord payload]];
  return [[[TextParsedResult alloc] init:languageText[0] param1:languageText[1]] autorelease];
}

+ (NSArray *) decodeTextPayload:(NSArray *)payload {
  char statusByte = payload[0];
  BOOL isUTF16 = (statusByte & 0x80) != 0;
  int languageLength = statusByte & 0x1F;
  NSString * language = [self bytesToString:payload param1:1 param2:languageLength param3:@"US-ASCII"];
  NSString * encoding = isUTF16 ? @"UTF-16" : @"UTF8";
  NSString * text = [self bytesToString:payload param1:1 + languageLength param2:payload.length - languageLength - 1 param3:encoding];
  return [NSArray arrayWithObjects:language, text, nil];
}

@end
