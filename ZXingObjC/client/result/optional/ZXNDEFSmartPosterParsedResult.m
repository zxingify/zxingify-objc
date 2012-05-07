#import "ZXNDEFSmartPosterParsedResult.h"

int const ACTION_UNSPECIFIED = -1;
int const ACTION_DO = 0;
int const ACTION_SAVE = 1;
int const ACTION_OPEN = 2;

@interface ZXNDEFSmartPosterParsedResult ()

@property (nonatomic) int action;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * uri;

@end

@implementation ZXNDEFSmartPosterParsedResult

@synthesize action;
@synthesize title;
@synthesize uri;

- (id)initWithAction:(int)anAction uri:(NSString *)aUri title:(NSString *)aTitle {
  if (self = [super initWithType:kParsedResultTypeNDEFSMartPoster]) {
    self.action = anAction;
    self.uri = aUri;
    self.title = aTitle;
  }

  return self;
}

- (void)dealloc {
  [title release];
  [uri release];

  [super dealloc];
}

- (NSString *)displayResult {
  if (self.title == nil) {
    return self.uri;
  } else {
    return [[self.title stringByAppendingString:@"\n"] stringByAppendingString:self.uri];
  }
}

@end
