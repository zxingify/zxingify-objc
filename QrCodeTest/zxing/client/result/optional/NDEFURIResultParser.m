#import "NDEFURIResultParser.h"

NSArray * const URI_PREFIXES = [NSArray arrayWithObjects:nil, @"http://www.", @"https://www.", @"http://", @"https://", @"tel:", @"mailto:", @"ftp://anonymous:anonymous@", @"ftp://ftp.", @"ftps://", @"sftp://", @"smb://", @"nfs://", @"ftp://", @"dav://", @"news:", @"telnet://", @"imap:", @"rtsp://", @"urn:", @"pop:", @"sip:", @"sips:", @"tftp:", @"btspp://", @"btl2cap://", @"btgoep://", @"tcpobex://", @"irdaobex://", @"file://", @"urn:epc:id:", @"urn:epc:tag:", @"urn:epc:pat:", @"urn:epc:raw:", @"urn:epc:", @"urn:nfc:", nil];

@implementation NDEFURIResultParser

+ (URIParsedResult *) parse:(Result *)result {
  NSArray * bytes = [result rawBytes];
  if (bytes == nil) {
    return nil;
  }
  NDEFRecord * ndefRecord = [NDEFRecord readRecord:bytes param1:0];
  if (ndefRecord == nil || ![ndefRecord messageBegin] || ![ndefRecord messageEnd]) {
    return nil;
  }
  if (![[ndefRecord type] isEqualTo:NDEFRecord.URI_WELL_KNOWN_TYPE]) {
    return nil;
  }
  NSString * fullURI = [self decodeURIPayload:[ndefRecord payload]];
  return [[[URIParsedResult alloc] init:fullURI param1:nil] autorelease];
}

+ (NSString *) decodeURIPayload:(NSArray *)payload {
  int identifierCode = payload[0] & 0xFF;
  NSString * prefix = nil;
  if (identifierCode < URI_PREFIXES.length) {
    prefix = URI_PREFIXES[identifierCode];
  }
  NSString * restOfURI = [self bytesToString:payload param1:1 param2:payload.length - 1 param3:@"UTF8"];
  return prefix == nil ? restOfURI : [prefix stringByAppendingString:restOfURI];
}

@end
