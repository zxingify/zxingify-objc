#import "BarcodeFormat.h"
#import "ResultMetadataType.h"

/**
 * <p>Encapsulates the result of decoding a barcode within an image.</p>
 * 
 * @author Sean Owen
 */

@interface Result : NSObject {
  NSString * text;
  char * rawBytes;
  NSMutableArray * resultPoints;
  BarcodeFormat format;
  NSMutableDictionary * resultMetadata;
  long timestamp;
}

@property(nonatomic, readonly) NSString * text;
@property(nonatomic, readonly) char * rawBytes;
@property(nonatomic, readonly) NSMutableArray * resultPoints;
@property(nonatomic, readonly) BarcodeFormat barcodeFormat;
@property(nonatomic, readonly) NSMutableDictionary * resultMetadata;
@property(nonatomic, readonly) long timestamp;

- (id) initWithText:(NSString *)text rawBytes:(char *)rawBytes resultPoints:(NSArray *)resultPoints format:(BarcodeFormat)format;
- (id) initWithText:(NSString *)text rawBytes:(char *)rawBytes resultPoints:(NSArray *)resultPoints format:(BarcodeFormat)format timestamp:(long)timestamp;
- (void) putMetadata:(ResultMetadataType)type value:(id)value;
- (void) putAllMetadata:(NSMutableDictionary *)metadata;
- (void) addResultPoints:(NSArray *)newPoints;

@end
