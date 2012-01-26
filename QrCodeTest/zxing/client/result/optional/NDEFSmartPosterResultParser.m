#import "NDEFSmartPosterResultParser.h"

@implementation NDEFSmartPosterResultParser

+ (NDEFSmartPosterParsedResult *) parse:(Result *)result {
  NSArray * bytes = [result rawBytes];
  if (bytes == nil) {
    return nil;
  }
  NDEFRecord * headerRecord = [NDEFRecord readRecord:bytes param1:0];
  if (headerRecord == nil || ![headerRecord messageBegin] || ![headerRecord messageEnd]) {
    return nil;
  }
  if (![[headerRecord type] isEqualTo:NDEFRecord.SMART_POSTER_WELL_KNOWN_TYPE]) {
    return nil;
  }
  int offset = 0;
  int recordNumber = 0;
  NDEFRecord * ndefRecord = nil;
  NSArray * payload = [headerRecord payload];
  int action = NDEFSmartPosterParsedResult.ACTION_UNSPECIFIED;
  NSString * title = nil;
  NSString * uri = nil;

  while (offset < payload.length && (ndefRecord = [NDEFRecord readRecord:payload param1:offset]) != nil) {
    if (recordNumber == 0 && ![ndefRecord messageBegin]) {
      return nil;
    }
    NSString * type = [ndefRecord type];
    if ([NDEFRecord.TEXT_WELL_KNOWN_TYPE isEqualTo:type]) {
      NSArray * languageText = [NDEFTextResultParser decodeTextPayload:[ndefRecord payload]];
      title = languageText[1];
    }
     else if ([NDEFRecord.URI_WELL_KNOWN_TYPE isEqualTo:type]) {
      uri = [NDEFURIResultParser decodeURIPayload:[ndefRecord payload]];
    }
     else if ([NDEFRecord.ACTION_WELL_KNOWN_TYPE isEqualTo:type]) {
      action = [ndefRecord payload][0];
    }
    recordNumber++;
    offset += [ndefRecord totalRecordLength];
  }

  if (recordNumber == 0 || (ndefRecord != nil && ![ndefRecord messageEnd])) {
    return nil;
  }
  return [[[NDEFSmartPosterParsedResult alloc] init:action param1:uri param2:title] autorelease];
}

@end
