#import "MultiDetector.h"

NSArray * const EMPTY_DETECTOR_RESULTS = [NSArray array];

@implementation MultiDetector

- (id) initWithImage:(BitMatrix *)image {
  if (self = [super init:image]) {
  }
  return self;
}

- (NSArray *) detectMulti:(NSMutableDictionary *)hints {
  BitMatrix * image = [self image];
  MultiFinderPatternFinder * finder = [[[MultiFinderPatternFinder alloc] init:image] autorelease];
  NSArray * info = [finder findMulti:hints];
  if (info == nil || info.length == 0) {
    @throw [NotFoundException notFoundInstance];
  }
  NSMutableArray * result = [[[NSMutableArray alloc] init] autorelease];

  for (int i = 0; i < info.length; i++) {

    @try {
      [result addObject:[self processFinderPatternInfo:info[i]]];
    }
    @catch (ReaderException * e) {
    }
  }

  if ([result empty]) {
    return EMPTY_DETECTOR_RESULTS;
  }
   else {
    NSArray * resultArray = [NSArray array];

    for (int i = 0; i < [result count]; i++) {
      resultArray[i] = (DetectorResult *)[result objectAtIndex:i];
    }

    return resultArray;
  }
}

@end
