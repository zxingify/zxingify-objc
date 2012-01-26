#import "NSMutableArray.h"

/**
 * <p>Encapsulates the result of decoding a matrix of bits. This typically
 * applies to 2D barcode formats. For now it contains the raw bytes obtained,
 * as well as a String interpretation of those bytes, if applicable.</p>
 * 
 * @author Sean Owen
 */

@interface DecoderResult : NSObject {
  NSArray * rawBytes;
  NSString * text;
  NSMutableArray * byteSegments;
  NSString * ecLevel;
}

@property(nonatomic, retain, readonly) NSArray * rawBytes;
@property(nonatomic, retain, readonly) NSString * text;
@property(nonatomic, retain, readonly) NSMutableArray * byteSegments;
@property(nonatomic, retain, readonly) NSString * eCLevel;
- (id) init:(NSArray *)rawBytes text:(NSString *)text byteSegments:(NSMutableArray *)byteSegments ecLevel:(NSString *)ecLevel;
@end
