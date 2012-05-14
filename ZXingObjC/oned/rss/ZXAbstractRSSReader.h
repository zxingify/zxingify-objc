#import "ZXNotFoundException.h"
#import "ZXOneDReader.h"

typedef enum {
	RSS_PATTERNS_RSS14_PATTERNS = 0,
	RSS_PATTERNS_RSS_EXPANDED_PATTERNS
} RSS_PATTERNS;

@interface ZXAbstractRSSReader : ZXOneDReader

@property (nonatomic, assign, readonly) int * decodeFinderCounters;
@property (nonatomic, assign, readonly) unsigned int decodeFinderCountersLen;
@property (nonatomic, assign, readonly) int * dataCharacterCounters;
@property (nonatomic, assign, readonly) unsigned int dataCharacterCountersLen;
@property (nonatomic, assign, readonly) float * oddRoundingErrors;
@property (nonatomic, assign, readonly) unsigned int oddRoundingErrorsLen;
@property (nonatomic, assign, readonly) float * evenRoundingErrors;
@property (nonatomic, assign, readonly) unsigned int evenRoundingErrorsLen;
@property (nonatomic, assign, readonly) int * oddCounts;
@property (nonatomic, assign, readonly) unsigned int oddCountsLen;
@property (nonatomic, assign, readonly) int * evenCounts;
@property (nonatomic, assign, readonly) unsigned int evenCountsLen;

+ (int)parseFinderValue:(int*)counters countersSize:(unsigned int)countersSize finderPatternType:(RSS_PATTERNS)finderPatternType;
+ (int)count:(int*)array arrayLen:(unsigned int)arrayLen;
+ (void)increment:(int *)array arrayLen:(unsigned int)arrayLen errors:(float *)errors;
+ (void)decrement:(int *)array arrayLen:(unsigned int)arrayLen errors:(float *)errors;
+ (BOOL)isFinderPattern:(int*)counters countersLen:(unsigned int)countersLen;

@end
