#import "NSEnumerator.h"
#import "NSMutableDictionary.h"

/**
 * <p>Encapsulates the result of decoding a barcode within an image.</p>
 * 
 * @author Sean Owen
 */

@interface Result : NSObject {
  NSString * text;
  NSArray * rawBytes;
  NSArray * resultPoints;
  BarcodeFormat * format;
  NSMutableDictionary * resultMetadata;
  long timestamp;
}

@property(nonatomic, retain, readonly) NSString * text;
@property(nonatomic, retain, readonly) NSArray * rawBytes;
@property(nonatomic, retain, readonly) NSArray * resultPoints;
@property(nonatomic, retain, readonly) BarcodeFormat * barcodeFormat;
@property(nonatomic, retain, readonly) NSMutableDictionary * resultMetadata;
@property(nonatomic, readonly) long timestamp;
- (id) init:(NSString *)text rawBytes:(NSArray *)rawBytes resultPoints:(NSArray *)resultPoints format:(BarcodeFormat *)format;
- (id) init:(NSString *)text rawBytes:(NSArray *)rawBytes resultPoints:(NSArray *)resultPoints format:(BarcodeFormat *)format timestamp:(long)timestamp;
- (void) putMetadata:(ResultMetadataType *)type value:(NSObject *)value;
- (void) putAllMetadata:(NSMutableDictionary *)metadata;
- (void) addResultPoints:(NSArray *)newPoints;
- (NSString *) description;
@end
