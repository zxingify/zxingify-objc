#import "ZXBarcodeFormat.h"
#import "ZXResultMetadataType.h"

/**
 * Encapsulates the result of decoding a barcode within an image.
 */

@interface ZXResult : NSObject

@property (nonatomic, copy,   readonly) NSString * text;
@property (nonatomic, assign, readonly) unsigned char * rawBytes;
@property (nonatomic, assign, readonly) int length;
@property (nonatomic, retain, readonly) NSMutableArray * resultPoints;
@property (nonatomic, assign, readonly) ZXBarcodeFormat barcodeFormat;
@property (nonatomic, retain, readonly) NSMutableDictionary * resultMetadata;
@property (nonatomic, assign, readonly) long timestamp;

- (id)initWithText:(NSString *)text rawBytes:(unsigned char *)rawBytes length:(unsigned int)length resultPoints:(NSArray *)resultPoints format:(ZXBarcodeFormat)format;
- (id)initWithText:(NSString *)text rawBytes:(unsigned char *)rawBytes length:(unsigned int)length resultPoints:(NSArray *)resultPoints format:(ZXBarcodeFormat)format timestamp:(long)timestamp;
- (void)putMetadata:(ZXResultMetadataType)type value:(id)value;
- (void)putAllMetadata:(NSMutableDictionary *)metadata;
- (void)addResultPoints:(NSArray *)newPoints;

@end
