#import "NDEFRecord.h"
#import "NDEFURIResultParser.h"
#import "Result.h"
#import "URIParsedResult.h"

@implementation NDEFURIResultParser

+ (URIParsedResult *) parse:(Result *)result {
  char * bytes = [result rawBytes];
  if (bytes == nil) {
    return nil;
  }
  NDEFRecord * ndefRecord = [NDEFRecord readRecord:bytes offset:0];
  if (ndefRecord == nil || ![ndefRecord messageBegin] || ![ndefRecord messageEnd]) {
    return nil;
  }
  if (![ndefRecord.type isEqualToString:URI_WELL_KNOWN_TYPE]) {
    return nil;
  }
  NSString * fullURI = [self decodeURIPayload:[ndefRecord payload]];
  return [[[URIParsedResult alloc] initWithUri:fullURI title:nil] autorelease];
}

+ (NSString *) decodeURIPayload:(char *)payload {
  static NSArray* URI_PREFIXES = nil;
  if (!URI_PREFIXES) {
    URI_PREFIXES = [NSArray arrayWithObjects:[NSNull null], @"http://www.", @"https://www.", @"http://", @"https://", @"tel:", @"mailto:", @"ftp://anonymous:anonymous@", @"ftp://ftp.", @"ftps://", @"sftp://", @"smb://", @"nfs://", @"ftp://", @"dav://", @"news:", @"telnet://", @"imap:", @"rtsp://", @"urn:", @"pop:", @"sip:", @"sips:", @"tftp:", @"btspp://", @"btl2cap://", @"btgoep://", @"tcpobex://", @"irdaobex://", @"file://", @"urn:epc:id:", @"urn:epc:tag:", @"urn:epc:pat:", @"urn:epc:raw:", @"urn:epc:", @"urn:nfc:", nil];
  }

  int identifierCode = payload[0] & 0xFF;
  NSString * prefix = nil;
  if (identifierCode < [URI_PREFIXES count]) {
    prefix = [URI_PREFIXES objectAtIndex:identifierCode];
  }
  NSString * restOfURI = [AbstractNDEFResultParser bytesToString:payload offset:1 length:(sizeof(payload) / sizeof(char)) - 1 encoding:NSUTF8StringEncoding];
  return prefix == nil ? restOfURI : [prefix stringByAppendingString:restOfURI];
}

@end
