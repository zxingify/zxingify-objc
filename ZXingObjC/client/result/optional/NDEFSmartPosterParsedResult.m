#import "NDEFSmartPosterParsedResult.h"

int const ACTION_UNSPECIFIED = -1;
int const ACTION_DO = 0;
int const ACTION_SAVE = 1;
int const ACTION_OPEN = 2;

@implementation NDEFSmartPosterParsedResult

@synthesize title;
@synthesize uri;
@synthesize action;
@synthesize displayResult;

- (id) initWithAction:(int)anAction uri:(NSString *)aUri title:(NSString *)aTitle {
  if (self = [super initWithType:kParsedResultTypeNDEFSMartPoster]) {
    self.action = anAction;
    self.uri = aUri;
    self.title = aTitle;
  }
  return self;
}

- (NSString *) displayResult {
  if (self.title == nil) {
    return self.uri;
  } else {
    return [[self.title stringByAppendingString:@"\n"] stringByAppendingString:self.uri];
  }
}

- (void) dealloc {
  [title release];
  [uri release];
  [super dealloc];
}

@end
