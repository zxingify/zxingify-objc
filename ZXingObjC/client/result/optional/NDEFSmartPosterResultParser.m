#import "NDEFRecord.h"
#import "NDEFSmartPosterParsedResult.h"
#import "NDEFSmartPosterResultParser.h"
#import "NDEFTextResultParser.h"
#import "NDEFURIResultParser.h"
#import "Result.h"

@implementation NDEFSmartPosterResultParser

+ (NDEFSmartPosterParsedResult *) parse:(Result *)result {
  unsigned char * bytes = [result rawBytes];
  if (bytes == nil) {
    return nil;
  }
  NDEFRecord * headerRecord = [NDEFRecord readRecord:bytes offset:0];
  if (headerRecord == nil || ![headerRecord messageBegin] || ![headerRecord messageEnd]) {
    return nil;
  }
  if (![[headerRecord type] isEqualToString:SMART_POSTER_WELL_KNOWN_TYPE]) {
    return nil;
  }

  int offset = 0;
  int recordNumber = 0;
  NDEFRecord * ndefRecord = nil;
  unsigned char * payload = [headerRecord payload];
  int action = ACTION_UNSPECIFIED;
  NSString * title = nil;
  NSString * uri = nil;

  while (offset < [headerRecord payloadLength] && (ndefRecord = [NDEFRecord readRecord:payload offset:offset]) != nil) {
    if (recordNumber == 0 && ![ndefRecord messageBegin]) {
      return nil;
    }

    NSString * type = [ndefRecord type];
    if ([TEXT_WELL_KNOWN_TYPE isEqualToString:type]) {
      NSArray * languageText = [NDEFTextResultParser decodeTextPayload:[ndefRecord payload] length:[ndefRecord payloadLength]];
      title = [languageText objectAtIndex:1];
    } else if ([URI_WELL_KNOWN_TYPE isEqualToString:type]) {
      uri = [NDEFURIResultParser decodeURIPayload:[ndefRecord payload] length:[ndefRecord payloadLength]];
    } else if ([ACTION_WELL_KNOWN_TYPE isEqualToString:type]) {
      action = [ndefRecord payload][0];
    }
    recordNumber++;
    offset += [ndefRecord totalRecordLength];
  }

  if (recordNumber == 0 || (ndefRecord != nil && ![ndefRecord messageEnd])) {
    return nil;
  }

  return [[[NDEFSmartPosterParsedResult alloc] initWithAction:action uri:uri title:title] autorelease];
}

@end
