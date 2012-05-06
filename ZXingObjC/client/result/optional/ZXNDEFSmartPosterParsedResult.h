#import "ZXParsedResult.h"
#import "ZXParsedResultType.h"

extern int const ACTION_UNSPECIFIED;
extern int const ACTION_DO;
extern int const ACTION_SAVE;
extern int const ACTION_OPEN;

@interface ZXNDEFSmartPosterParsedResult : ZXParsedResult

@property (nonatomic, readonly) int action;
@property (nonatomic, copy, readonly) NSString * title;
@property (nonatomic, copy, readonly) NSString * uri;

- (id)initWithAction:(int)action uri:(NSString *)uri title:(NSString *)title;

@end
