@interface ZXDataCharacter : NSObject

@property (nonatomic, assign, readonly) int value;
@property (nonatomic, assign, readonly) int checksumPortion;

- (id)initWithValue:(int)value checksumPortion:(int)checksumPortion;

@end
