/**
 * <p>Represents a record in an NDEF message. This class only supports certain types
 * of records -- namely, non-chunked records, where ID length is omitted, and only
 * "short records".</p>
 * 
 * @author Sean Owen
 */

extern NSString * const TEXT_WELL_KNOWN_TYPE;
extern NSString * const URI_WELL_KNOWN_TYPE;
extern NSString * const SMART_POSTER_WELL_KNOWN_TYPE;
extern NSString * const ACTION_WELL_KNOWN_TYPE;

@interface NDEFRecord : NSObject {
  int header;
  NSString * type;
  char * payload;
  int totalRecordLength;
}

@property (nonatomic, readonly) NSString * type;
@property (nonatomic, readonly) char * payload;
@property (nonatomic, readonly) int totalRecordLength;

+ (NDEFRecord *) readRecord:(char *)bytes offset:(int)offset;
- (BOOL) messageBegin;
- (BOOL) messageEnd;

@end
