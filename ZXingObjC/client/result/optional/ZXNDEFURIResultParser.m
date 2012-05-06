#import "ZXNDEFRecord.h"
#import "ZXNDEFURIResultParser.h"
#import "ZXResult.h"
#import "ZXURIParsedResult.h"

@implementation ZXNDEFURIResultParser

+ (ZXURIParsedResult *)parse:(ZXResult *)result {
  unsigned char * bytes = [result rawBytes];
  if (bytes == nil) {
    return nil;
  }
  ZXNDEFRecord * ndefRecord = [ZXNDEFRecord readRecord:bytes offset:0];
  if (ndefRecord == nil || ![ndefRecord messageBegin] || ![ndefRecord messageEnd]) {
    return nil;
  }
  if (![ndefRecord.type isEqualToString:URI_WELL_KNOWN_TYPE]) {
    return nil;
  }
  NSString * fullURI = [self decodeURIPayload:[ndefRecord payload] length:[ndefRecord payloadLength]];
  return [[[ZXURIParsedResult alloc] initWithUri:fullURI title:nil] autorelease];
}

+ (NSString *)decodeURIPayload:(unsigned char *)payload length:(unsigned int)length {
  static NSArray* URI_PREFIXES = nil;
  if (!URI_PREFIXES) {
    URI_PREFIXES = [NSArray arrayWithObjects:[NSNull null], @"http://www.", @"https://www.", @"http://", @"https://", @"tel:", @"mailto:", @"ftp://anonymous:anonymous@", @"ftp://ftp.", @"ftps://", @"sftp://", @"smb://", @"nfs://", @"ftp://", @"dav://", @"news:", @"telnet://", @"imap:", @"rtsp://", @"urn:", @"pop:", @"sip:", @"sips:", @"tftp:", @"btspp://", @"btl2cap://", @"btgoep://", @"tcpobex://", @"irdaobex://", @"file://", @"urn:epc:id:", @"urn:epc:tag:", @"urn:epc:pat:", @"urn:epc:raw:", @"urn:epc:", @"urn:nfc:", nil];
  }

  int identifierCode = payload[0] & 0xFF;
  NSString * prefix = nil;
  if (identifierCode < [URI_PREFIXES count]) {
    prefix = [URI_PREFIXES objectAtIndex:identifierCode];
  }
  NSString * restOfURI = [ZXAbstractNDEFResultParser bytesToString:payload offset:1 length:length - 1 encoding:NSUTF8StringEncoding];
  return prefix == nil ? restOfURI : [prefix stringByAppendingString:restOfURI];
}

@end
