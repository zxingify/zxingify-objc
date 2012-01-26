
@interface BlockPair : NSObject {
  NSArray * dataBytes;
  NSArray * errorCorrectionBytes;
}

@property(nonatomic, retain, readonly) NSArray * dataBytes;
@property(nonatomic, retain, readonly) NSArray * errorCorrectionBytes;
- (id) init:(NSArray *)data errorCorrection:(NSArray *)errorCorrection;
@end
