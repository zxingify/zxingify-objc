@interface DataCharacter : NSObject {
  int value;
  int checksumPortion;
}

@property(nonatomic, readonly) int value;
@property(nonatomic, readonly) int checksumPortion;

- (id)initWithValue:(int)value checksumPortion:(int)checksumPortion;

@end
