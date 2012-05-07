/**
 * Encapsulates the result of decoding a matrix of bits. This typically
 * applies to 2D barcode formats. For now it contains the raw bytes obtained,
 * as well as a String interpretation of those bytes, if applicable.
 */

@interface ZXDecoderResult : NSObject

@property (nonatomic, assign, readonly) unsigned char * rawBytes;
@property (nonatomic, assign, readonly) int length;
@property (nonatomic, copy, readonly) NSString * text;
@property (nonatomic, retain, readonly) NSMutableArray * byteSegments;
@property (nonatomic, copy, readonly) NSString * ecLevel;

- (id)initWithRawBytes:(unsigned char *)rawBytes
                length:(unsigned int)length
                  text:(NSString *)text
          byteSegments:(NSMutableArray *)byteSegments
               ecLevel:(NSString *)ecLevel;

@end
