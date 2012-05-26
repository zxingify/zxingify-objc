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
