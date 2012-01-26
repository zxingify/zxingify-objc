#import "ParsedResult.h"

@implementation ParsedResult

@synthesize type;
@synthesize displayResult;

- (id) initWithType:(ParsedResultType *)type {
  if (self = [super init]) {
    type = type;
  }
  return self;
}

- (NSString *) displayResult {
}

- (NSString *) description {
  return [self displayResult];
}

+ (void) maybeAppend:(NSString *)value result:(StringBuffer *)result {
  if (value != nil && [value length] > 0) {
    if ([result length] > 0) {
      [result append:'\n'];
    }
    [result append:value];
  }
}

+ (void) maybeAppend:(NSArray *)value result:(StringBuffer *)result {
  if (value != nil) {

    for (int i = 0; i < value.length; i++) {
      if (value[i] != nil && [value[i] count] > 0) {
        if ([result length] > 0) {
          [result append:'\n'];
        }
        [result append:value[i]];
      }
    }

  }
}

- (void) dealloc {
  [type release];
  [super dealloc];
}

@end
