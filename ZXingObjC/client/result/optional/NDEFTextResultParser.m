#import "NDEFRecord.h"
#import "NDEFTextResultParser.h"
#import "Result.h"
#import "TextParsedResult.h"

@implementation NDEFTextResultParser

+ (TextParsedResult *) parse:(Result *)result {
  char * bytes = [result rawBytes];
  if (bytes == nil) {
    return nil;
  }
  NDEFRecord * ndefRecord = [NDEFRecord readRecord:bytes offset:0];
  if (ndefRecord == nil || ![ndefRecord messageBegin] || ![ndefRecord messageEnd]) {
    return nil;
  }
  if (![[ndefRecord type] isEqualToString:TEXT_WELL_KNOWN_TYPE]) {
    return nil;
  }
  NSArray * languageText = [self decodeTextPayload:[ndefRecord payload]];
  return [[[TextParsedResult alloc] initWithText:[languageText objectAtIndex:0] language:[languageText objectAtIndex:1]] autorelease];
}

+ (NSArray *) decodeTextPayload:(char *)payload {
  char statusByte = payload[0];
  BOOL isUTF16 = (statusByte & 0x80) != 0;
  int languageLength = statusByte & 0x1F;
  NSString * language = [self bytesToString:payload offset:1 length:languageLength encoding:NSASCIIStringEncoding];
  NSStringEncoding encoding = isUTF16 ? NSUTF16StringEncoding : NSUTF8StringEncoding;
  NSString * text = [self bytesToString:payload
                                 offset:1 + languageLength
                                 length:(sizeof(payload) / sizeof(char)) - languageLength - 1
                               encoding:encoding];
  return [NSArray arrayWithObjects:language, text, nil];
}

@end
