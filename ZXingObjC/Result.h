#import "BarcodeFormat.h"
#import "ResultMetadataType.h"

/**
 * <p>Encapsulates the result of decoding a barcode within an image.</p>
 * 
 * @author Sean Owen
 */

@interface Result : NSObject {
  NSString * text;
  NSArray * rawBytes;
  NSArray * resultPoints;
  BarcodeFormat format;
  NSMutableDictionary * resultMetadata;
  long timestamp;
}

@property(nonatomic, copy) NSString * text;
@property(nonatomic, retain) NSArray * rawBytes;
@property(nonatomic, retain) NSArray * resultPoints;
@property(nonatomic, assign) BarcodeFormat barcodeFormat;
@property(nonatomic, retain) NSMutableDictionary * resultMetadata;
@property(nonatomic, readonly) long timestamp;
- (id) init:(NSString *)text rawBytes:(NSArray *)rawBytes resultPoints:(NSArray *)resultPoints format:(BarcodeFormat)format;
- (id) init:(NSString *)text rawBytes:(NSArray *)rawBytes resultPoints:(NSArray *)resultPoints format:(BarcodeFormat)format timestamp:(long)timestamp;
- (void) putMetadata:(ResultMetadataType)type value:(id)value;
- (void) putAllMetadata:(NSMutableDictionary *)metadata;
- (void) addResultPoints:(NSArray *)newPoints;
- (NSString *) description;
@end
