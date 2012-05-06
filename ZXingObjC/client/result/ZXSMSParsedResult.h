#import "ZXParsedResult.h"

@interface ZXSMSParsedResult : ZXParsedResult

@property (nonatomic, retain, readonly) NSArray * numbers;
@property (nonatomic, retain, readonly) NSArray * vias;
@property (nonatomic, copy, readonly) NSString * subject;
@property (nonatomic, copy, readonly) NSString * body;

- (id)initWithNumber:(NSString *)number via:(NSString *)via subject:(NSString *)subject body:(NSString *)body;
- (id)initWithNumbers:(NSArray *)numbers vias:(NSArray *)vias subject:(NSString *)subject body:(NSString *)body;
- (NSString *)sMSURI;

@end
