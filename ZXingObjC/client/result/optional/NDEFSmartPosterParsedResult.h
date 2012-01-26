#import "ParsedResult.h"
#import "ParsedResultType.h"

/**
 * @author Sean Owen
 */

extern int const ACTION_UNSPECIFIED;
extern int const ACTION_DO;
extern int const ACTION_SAVE;
extern int const ACTION_OPEN;

@interface NDEFSmartPosterParsedResult : ParsedResult

@property(nonatomic, copy) NSString * title;
@property(nonatomic, copy) NSString * uri;
@property(nonatomic, assign) int action;

- (id) initWithAction:(int)action uri:(NSString *)uri title:(NSString *)title;
- (NSString *) displayResult;

@end
