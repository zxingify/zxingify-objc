#import "AbstractDoCoMoResultParser.h"

@implementation AbstractDoCoMoResultParser

+ (NSArray *) matchDoCoMoPrefixedField:(NSString *)prefix rawText:(NSString *)rawText trim:(BOOL)trim {
  return [self matchPrefixedField:prefix rawText:rawText endChar:';' trim:trim];
}

+ (NSString *) matchSingleDoCoMoPrefixedField:(NSString *)prefix rawText:(NSString *)rawText trim:(BOOL)trim {
  return [self matchSinglePrefixedField:prefix rawText:rawText endChar:';' trim:trim];
}

@end
