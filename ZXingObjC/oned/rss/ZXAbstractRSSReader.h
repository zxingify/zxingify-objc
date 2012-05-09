#import "ZXNotFoundException.h"
#import "ZXOneDReader.h"

typedef enum {
	RSS_PATTERNS_RSS14_PATTERNS = 0,
	RSS_PATTERNS_RSS_EXPANDED_PATTERNS
} RSS_PATTERNS;

@interface ZXAbstractRSSReader : ZXOneDReader

@property (nonatomic, retain, readonly) NSMutableArray * decodeFinderCounters;
@property (nonatomic, retain, readonly) NSMutableArray * dataCharacterCounters;
@property (nonatomic, retain, readonly) NSMutableArray * oddRoundingErrors;
@property (nonatomic, retain, readonly) NSMutableArray * evenRoundingErrors;
@property (nonatomic, retain, readonly) NSMutableArray * oddCounts;
@property (nonatomic, retain, readonly) NSMutableArray * evenCounts;

+ (int)parseFinderValue:(int[])counters countersSize:(int)countersSize finderPatternType:(RSS_PATTERNS)finderPatternType;
+ (int)count:(int[])array;
+ (int)countArray:(NSArray*)array;
+ (void)increment:(NSMutableArray *)array errors:(NSArray *)errors;
+ (void)decrement:(NSMutableArray *)array errors:(NSArray *)errors;
+ (BOOL)isFinderPattern:(int[])counters;

@end
