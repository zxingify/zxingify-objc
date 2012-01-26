#import "NotFoundException.h"
#import "OneDReader.h"

@interface AbstractRSSReader : OneDReader {
  NSArray * decodeFinderCounters;
  NSArray * dataCharacterCounters;
  NSArray * oddRoundingErrors;
  NSArray * evenRoundingErrors;
  NSArray * oddCounts;
  NSArray * evenCounts;
}

- (id) init;
+ (int) parseFinderValue:(NSArray *)counters finderPatterns:(NSArray *)finderPatterns;
+ (int) count:(NSArray *)array;
+ (void) increment:(NSArray *)array errors:(NSArray *)errors;
+ (void) decrement:(NSArray *)array errors:(NSArray *)errors;
+ (BOOL) isFinderPattern:(NSArray *)counters;
@end
