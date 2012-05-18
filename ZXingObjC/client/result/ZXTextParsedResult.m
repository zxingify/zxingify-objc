#import "ZXParsedResultType.h"
#import "ZXTextParsedResult.h"

@interface ZXTextParsedResult ()

@property (nonatomic, copy) NSString * text;
@property (nonatomic, copy) NSString * language;

@end

@implementation ZXTextParsedResult

@synthesize text;
@synthesize language;

- (id)initWithText:(NSString *)aText language:(NSString *)aLanguage {
  if (self = [super initWithType:kParsedResultTypeText]) {
    self.text = aText;
    self.language = aLanguage;
  }

  return self;
}

- (void)dealloc {
  [text release];
  [language release];

  [super dealloc];
}

- (NSString*)displayResult {
  return self.text;
}

@end
