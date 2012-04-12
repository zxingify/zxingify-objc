#import "ZXBarcodeFormat.h"
#import "ZXResultMetadataType.h"

/**
 * <p>Encapsulates the result of decoding a barcode within an image.</p>
 * 
 * @author Sean Owen
 */

@interface ZXResult : NSObject {
  NSString * text;
  unsigned char * rawBytes;
  int length;
  NSMutableArray * resultPoints;
  ZXBarcodeFormat format;
  NSMutableDictionary * resultMetadata;
  long timestamp;
}

@property(nonatomic, readonly) NSString * text;
@property(nonatomic, readonly) unsigned char * rawBytes;
@property(nonatomic, readonly) int length;
@property(nonatomic, readonly) NSMutableArray * resultPoints;
@property(nonatomic, readonly) ZXBarcodeFormat barcodeFormat;
@property(nonatomic, readonly) NSMutableDictionary * resultMetadata;
@property(nonatomic, readonly) long timestamp;

- (id) initWithText:(NSString *)text rawBytes:(unsigned char *)rawBytes length:(unsigned int)length resultPoints:(NSArray *)resultPoints format:(ZXBarcodeFormat)format;
- (id) initWithText:(NSString *)text rawBytes:(unsigned char *)rawBytes length:(unsigned int)length resultPoints:(NSArray *)resultPoints format:(ZXBarcodeFormat)format timestamp:(long)timestamp;
- (void) putMetadata:(ZXResultMetadataType)type value:(id)value;
- (void) putAllMetadata:(NSMutableDictionary *)metadata;
- (void) addResultPoints:(NSArray *)newPoints;

@end
