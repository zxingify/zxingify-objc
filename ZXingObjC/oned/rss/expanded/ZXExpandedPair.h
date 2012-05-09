@class ZXDataCharacter, ZXRSSFinderPattern;

@interface ZXExpandedPair : NSObject

@property (nonatomic, retain, readonly) ZXDataCharacter * leftChar;
@property (nonatomic, retain, readonly) ZXDataCharacter * rightChar;
@property (nonatomic, retain, readonly) ZXRSSFinderPattern * finderPattern;
@property (nonatomic, assign, readonly) BOOL mayBeLast;
@property (nonatomic, assign, readonly) BOOL mustBeLast;

- (id)initWithLeftChar:(ZXDataCharacter *)leftChar rightChar:(ZXDataCharacter *)rightChar finderPattern:(ZXRSSFinderPattern *)finderPattern mayBeLast:(BOOL)mayBeLast;

@end
