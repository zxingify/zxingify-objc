#import "NDEFRecord.h"

int const SUPPORTED_HEADER_MASK = 0x3F;
int const SUPPORTED_HEADER = 0x11;
NSString * const TEXT_WELL_KNOWN_TYPE = @"T";
NSString * const URI_WELL_KNOWN_TYPE = @"U";
NSString * const SMART_POSTER_WELL_KNOWN_TYPE = @"Sp";
NSString * const ACTION_WELL_KNOWN_TYPE = @"act";

@implementation NDEFRecord

- (id) init:(int)header type:(NSString *)type payload:(NSArray *)payload totalRecordLength:(int)totalRecordLength {
  if (self = [super init]) {
    header = header;
    type = type;
    payload = payload;
    totalRecordLength = totalRecordLength;
  }
  return self;
}

+ (NDEFRecord *) readRecord:(NSArray *)bytes offset:(int)offset {
  int header = bytes[offset] & 0xFF;
  if (((header ^ SUPPORTED_HEADER) & SUPPORTED_HEADER_MASK) != 0) {
    return nil;
  }
  int typeLength = bytes[offset + 1] & 0xFF;
  int payloadLength = bytes[offset + 2] & 0xFF;
  NSString * type = [AbstractNDEFResultParser bytesToString:bytes param1:offset + 3 param2:typeLength param3:@"US-ASCII"];
  NSArray * payload = [NSArray array];
  [System arraycopy:bytes param1:offset + 3 + typeLength param2:payload param3:0 param4:payloadLength];
  return [[[NDEFRecord alloc] init:header param1:type param2:payload param3:3 + typeLength + payloadLength] autorelease];
}

- (BOOL) isMessageBegin {
  return (header & 0x80) != 0;
}

- (BOOL) isMessageEnd {
  return (header & 0x40) != 0;
}

- (NSString *) getType {
  return type;
}

- (NSArray *) getPayload {
  return payload;
}

- (int) getTotalRecordLength {
  return totalRecordLength;
}

- (void) dealloc {
  [type release];
  [payload release];
  [super dealloc];
}

@end
