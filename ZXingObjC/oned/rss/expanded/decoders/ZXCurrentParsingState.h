@interface ZXCurrentParsingState : NSObject

@property (nonatomic, assign) int position;

- (BOOL)alpha;
- (BOOL)numeric;
- (BOOL)isoIec646;
- (void)setNumeric;
- (void)setAlpha;
- (void)setIsoIec646;

@end
