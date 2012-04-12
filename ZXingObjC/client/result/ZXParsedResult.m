#import "ZXParsedResult.h"

@implementation ZXParsedResult

@synthesize type;
@synthesize displayResult;

- (id) initWithType:(ZXParsedResultType)aType {
  if (self = [super init]) {
    self.type = aType;
  }
  return self;
}

- (NSString *) displayResult {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

- (NSString *) description {
  return [self displayResult];
}

+ (void) maybeAppend:(NSString *)value result:(NSMutableString *)result {
  if (value != nil && [value length] > 0) {
    if ([result length] > 0) {
      [result appendString:@"\n"];
    }
    [result appendString:value];
  }
}

+ (void) maybeAppendArray:(NSArray *)value result:(NSMutableString *)result {
  if (value != nil) {

    for (int i = 0; i < [value count]; i++) {
      if ([value objectAtIndex:i] && [[value objectAtIndex:i] length] > 0) {
        if ([result length] > 0) {
          [result appendString:@"\n"];
        }
        [result appendString:[value objectAtIndex:i]];
      }
    }

  }
}

@end
