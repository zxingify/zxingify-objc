/**
 * <p>Encapsulates the result of decoding a matrix of bits. This typically
 * applies to 2D barcode formats. For now it contains the raw bytes obtained,
 * as well as a String interpretation of those bytes, if applicable.</p>
 * 
 * @author Sean Owen
 */

@interface DecoderResult : NSObject {
  unsigned char * rawBytes;
  int length;
  NSString * text;
  NSMutableArray * byteSegments;
  NSString * ecLevel;
}

@property(nonatomic, readonly) unsigned char * rawBytes;
@property(nonatomic, readonly) int length;
@property(nonatomic, readonly) NSString * text;
@property(nonatomic, readonly) NSMutableArray * byteSegments;
@property(nonatomic, readonly) NSString * eCLevel;

- (id) init:(unsigned char *)rawBytes length:(unsigned int)length text:(NSString *)text byteSegments:(NSMutableArray *)byteSegments ecLevel:(NSString *)ecLevel;

@end
