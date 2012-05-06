/**
 * Represents a record in an NDEF message. This class only supports certain types
 * of records -- namely, non-chunked records, where ID length is omitted, and only
 * "short records".
 */

extern NSString * const TEXT_WELL_KNOWN_TYPE;
extern NSString * const URI_WELL_KNOWN_TYPE;
extern NSString * const SMART_POSTER_WELL_KNOWN_TYPE;
extern NSString * const ACTION_WELL_KNOWN_TYPE;

@interface ZXNDEFRecord : NSObject

@property (nonatomic, copy, readonly) NSString * type;
@property (nonatomic, readonly) unsigned char * payload;
@property (nonatomic, readonly) int payloadLength;
@property (nonatomic, readonly) int totalRecordLength;

+ (ZXNDEFRecord *)readRecord:(unsigned char *)bytes offset:(int)offset;
- (BOOL)messageBegin;
- (BOOL)messageEnd;

@end
