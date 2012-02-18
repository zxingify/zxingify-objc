@interface BlockPair : NSObject {
  char * dataBytes;
  char * errorCorrectionBytes;
}

@property(nonatomic, readonly) char * dataBytes;
@property(nonatomic, readonly) char * errorCorrectionBytes;

- (id) initWithData:(char *)data errorCorrection:(char *)errorCorrection;

@end
