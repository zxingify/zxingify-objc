#import "NotFoundException.h"
#import "OneDReader.h"

@interface AbstractRSSReader : OneDReader {
  NSArray * decodeFinderCounters;
  NSArray * dataCharacterCounters;
  NSArray * oddRoundingErrors;
  NSArray * evenRoundingErrors;
  NSMutableArray * oddCounts;
  NSMutableArray * evenCounts;
}

+ (int) parseFinderValue:(int[])counters finderPatterns:(int*[])finderPatterns;
+ (int) count:(int[])array;
+ (int) countArray:(NSArray*)array;
+ (void) increment:(NSMutableArray *)array errors:(NSArray *)errors;
+ (void) decrement:(NSMutableArray *)array errors:(NSArray *)errors;
+ (BOOL) isFinderPattern:(NSArray *)counters;

@end
