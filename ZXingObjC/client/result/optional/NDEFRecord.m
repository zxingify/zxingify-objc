#import "AbstractNDEFResultParser.h"
#import "NDEFRecord.h"

int const SUPPORTED_HEADER_MASK = 0x3F;
int const SUPPORTED_HEADER = 0x11;
NSString * const TEXT_WELL_KNOWN_TYPE = @"T";
NSString * const URI_WELL_KNOWN_TYPE = @"U";
NSString * const SMART_POSTER_WELL_KNOWN_TYPE = @"Sp";
NSString * const ACTION_WELL_KNOWN_TYPE = @"act";

@implementation NDEFRecord

@synthesize type, payload, totalRecordLength;

- (id) initWithHeader:(int)aHeader type:(NSString *)aType payload:(NSArray *)aPayload totalRecordLength:(int)aTotalRecordLength {
  if (self = [super init]) {
    header = aHeader;
    type = [aType copy];
    payload = [aPayload retain];
    totalRecordLength = aTotalRecordLength;
  }
  return self;
}

+ (NDEFRecord *) readRecord:(NSArray *)bytes offset:(int)offset {
  int header = [[bytes objectAtIndex:offset] charValue] & 0xFF;
  if (((header ^ SUPPORTED_HEADER) & SUPPORTED_HEADER_MASK) != 0) {
    return nil;
  }
  int typeLength = [[bytes objectAtIndex:offset + 1] charValue] & 0xFF;
  int payloadLength = [[bytes objectAtIndex:offset + 2] charValue] & 0xFF;
  NSString * type = [AbstractNDEFResultParser bytesToString:bytes offset:offset + 3 length:typeLength encoding:@"US-ASCII"];
  NSMutableArray * payload = [NSMutableArray arrayWithCapacity:payloadLength];
  for (int i = offset + 3 + typeLength; i < offset + 3 + typeLength + payloadLength; i++) {
    [payload addObject:[bytes objectAtIndex:i]];
  }

  return [[[NDEFRecord alloc] initWithHeader:header type:type payload:payload totalRecordLength:3 + typeLength + payloadLength] autorelease];
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
