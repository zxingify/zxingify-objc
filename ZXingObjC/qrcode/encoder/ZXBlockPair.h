@interface ZXBlockPair : NSObject

@property (nonatomic, assign, readonly) unsigned char * dataBytes;
@property (nonatomic, assign, readonly) unsigned char * errorCorrectionBytes;
@property (nonatomic, assign, readonly) int errorCorrectionLength;
@property (nonatomic, assign, readonly) int length;

- (id)initWithData:(unsigned char *)data length:(unsigned int)length errorCorrection:(unsigned char *)errorCorrection errorCorrectionLength:(unsigned int)errorCorrectionLength;

@end
