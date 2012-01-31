#import "AbstractDoCoMoResultParser.h"

@implementation AbstractDoCoMoResultParser

+ (NSArray *) matchDoCoMoPrefixedField:(NSString *)prefix rawText:(NSString *)rawText trim:(BOOL)trim {
  return [self matchPrefixedField:prefix rawText:rawText rawText:';' trim:trim];
}

+ (NSString *) matchSingleDoCoMoPrefixedField:(NSString *)prefix rawText:(NSString *)rawText trim:(BOOL)trim {
  return [self matchSinglePrefixedField:prefix param1:rawText param2:';' param3:trim];
}

@end
