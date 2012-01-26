#import "ParsedResult.h"
#import "ParsedResultType.h"

/**
 * @author Sean Owen
 */

extern int const ACTION_UNSPECIFIED;
extern int const ACTION_DO;
extern int const ACTION_SAVE;
extern int const ACTION_OPEN;

@interface NDEFSmartPosterParsedResult : ParsedResult {
  NSString * title;
  NSString * uri;
  int action;
}

@property(nonatomic, retain, readonly) NSString * title;
@property(nonatomic, retain, readonly) NSString * uRI;
@property(nonatomic, readonly) int action;
@property(nonatomic, retain, readonly) NSString * displayResult;
- (id) init:(int)action uri:(NSString *)uri title:(NSString *)title;
@end
