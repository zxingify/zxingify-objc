@class ZXBitArray, ZXGeneralAppIdDecoder;

@interface ZXAbstractExpandedDecoder : NSObject

@property (nonatomic, retain, readonly) ZXGeneralAppIdDecoder * generalDecoder;
@property (nonatomic, retain, readonly) ZXBitArray * information;

- (id)initWithInformation:(ZXBitArray *)information;
- (NSString *)parseInformationWithError:(NSError**)error;
+ (ZXAbstractExpandedDecoder *)createDecoder:(ZXBitArray *)information;

@end
