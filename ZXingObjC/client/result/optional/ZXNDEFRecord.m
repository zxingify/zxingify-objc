#import "ZXAbstractNDEFResultParser.h"
#import "ZXNDEFRecord.h"

int const SUPPORTED_HEADER_MASK = 0x3F;
int const SUPPORTED_HEADER = 0x11;
NSString * const TEXT_WELL_KNOWN_TYPE = @"T";
NSString * const URI_WELL_KNOWN_TYPE = @"U";
NSString * const SMART_POSTER_WELL_KNOWN_TYPE = @"Sp";
NSString * const ACTION_WELL_KNOWN_TYPE = @"act";

@interface ZXNDEFRecord ()

@property (nonatomic) int header;
@property (nonatomic) unsigned char * payload;
@property (nonatomic) int payloadLength;
@property (nonatomic) int totalRecordLength;
@property (nonatomic, copy) NSString * type;

@end

@implementation ZXNDEFRecord

@synthesize header;
@synthesize payload;
@synthesize payloadLength;
@synthesize totalRecordLength;
@synthesize type;

- (id)initWithHeader:(int)aHeader type:(NSString *)aType payload:(unsigned char *)aPayload payloadLength:(unsigned int)aPayloadLength totalRecordLength:(unsigned int)aTotalRecordLength {
  if (self = [super init]) {
    self.header = aHeader;
    self.type = aType;
    self.payload = aPayload;
    self.payloadLength = aPayloadLength;
    self.totalRecordLength = aTotalRecordLength;
  }
  return self;
}

- (void)dealloc {
  if (payload != NULL) {
    free(payload);
    payload = NULL;
  }
  [type release];

  [super dealloc];
}

+ (ZXNDEFRecord *)readRecord:(unsigned char *)bytes offset:(int)offset {
  int header = bytes[offset] & 0xFF;
  if (((header ^ SUPPORTED_HEADER) & SUPPORTED_HEADER_MASK) != 0) {
    return nil;
  }
  int typeLength = bytes[offset + 1] & 0xFF;
  
  unsigned int payloadLength = bytes[offset + 2] & 0xFF;

  NSString * type = [ZXAbstractNDEFResultParser bytesToString:bytes offset:offset + 3 length:typeLength encoding:NSASCIIStringEncoding];

  unsigned char* payload = (unsigned char*)malloc(payloadLength * sizeof(unsigned char));
  int payloadCount = 0;
  for (int i = offset + 3 + typeLength; i < offset + 3 + typeLength + payloadLength; i++) {
    payload[payloadCount++] = bytes[i];
  }

  return [[[ZXNDEFRecord alloc] initWithHeader:header
                                          type:type
                                       payload:payload
                                 payloadLength:payloadLength
                             totalRecordLength:3 + typeLength + payloadLength] autorelease];
}

- (BOOL)messageBegin {
  return (self.header & 0x80) != 0;
}

- (BOOL)messageEnd {
  return (self.header & 0x40) != 0;
}

@end
