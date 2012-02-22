@interface BlockPair : NSObject {
  unsigned char * dataBytes;
  unsigned char * errorCorrectionBytes;
  int errorCorrectionLength;
  int length;
}

@property(nonatomic, readonly) unsigned char * dataBytes;
@property(nonatomic, readonly) unsigned char * errorCorrectionBytes;
@property(nonatomic, readonly) int errorCorrectionLength;
@property(nonatomic, readonly) int length;

- (id) initWithData:(unsigned char *)data length:(unsigned int)length errorCorrection:(unsigned char *)errorCorrection errorCorrectionLength:(unsigned int)errorCorrectionLength;

@end
