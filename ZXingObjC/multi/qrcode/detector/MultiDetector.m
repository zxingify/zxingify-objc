#import "MultiDetector.h"
#import "MultiFinderPatternFinder.h"
#import "NotFoundException.h"

@implementation MultiDetector

- (NSArray *) detectMulti:(NSMutableDictionary *)hints {
  MultiFinderPatternFinder * finder = [[[MultiFinderPatternFinder alloc] initWithImage:image] autorelease];
  NSArray * info = [finder findMulti:hints];

  if (info == nil || [info count] == 0) {
    @throw [NotFoundException notFoundInstance];
  }

  NSMutableArray * result = [NSMutableArray array];
  for (int i = 0; i < [info count]; i++) {
    @try {
      [result addObject:[self processFinderPatternInfo:[info objectAtIndex:i]]];
    }
    @catch (ReaderException * e) {
    }
  }

  return result;
}

@end
