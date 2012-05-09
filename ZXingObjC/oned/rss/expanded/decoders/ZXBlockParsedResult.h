@class ZXDecodedInformation;

@interface ZXBlockParsedResult : NSObject

@property (nonatomic, retain, readonly) ZXDecodedInformation * decodedInformation;
@property (nonatomic, assign, readonly) BOOL finished;

- (id)initWithFinished:(BOOL)finished;
- (id)initWithInformation:(ZXDecodedInformation *)information finished:(BOOL)finished;

@end
