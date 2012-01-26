#import "NDEFSmartPosterParsedResult.h"

int const ACTION_UNSPECIFIED = -1;
int const ACTION_DO = 0;
int const ACTION_SAVE = 1;
int const ACTION_OPEN = 2;

@implementation NDEFSmartPosterParsedResult

@synthesize title;
@synthesize uRI;
@synthesize action;
@synthesize displayResult;

- (id) init:(int)action uri:(NSString *)uri title:(NSString *)title {
  if (self = [super init:ParsedResultType.NDEF_SMART_POSTER]) {
    action = action;
    uri = uri;
    title = title;
  }
  return self;
}

- (NSString *) displayResult {
  if (title == nil) {
    return uri;
  }
   else {
    return [[title stringByAppendingString:'\n'] stringByAppendingString:uri];
  }
}

- (void) dealloc {
  [title release];
  [uri release];
  [super dealloc];
}

@end
