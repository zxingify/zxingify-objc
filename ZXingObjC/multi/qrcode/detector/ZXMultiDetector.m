#import "ZXMultiDetector.h"
#import "ZXMultiFinderPatternFinder.h"
#import "ZXNotFoundException.h"

@implementation ZXMultiDetector

- (NSArray *) detectMulti:(ZXDecodeHints *)hints {
  ZXMultiFinderPatternFinder * finder = [[[ZXMultiFinderPatternFinder alloc] initWithImage:image] autorelease];
  NSArray * info = [finder findMulti:hints];

  if (info == nil || [info count] == 0) {
    @throw [ZXNotFoundException notFoundInstance];
  }

  NSMutableArray * result = [NSMutableArray array];
  for (int i = 0; i < [info count]; i++) {
    @try {
      [result addObject:[self processFinderPatternInfo:[info objectAtIndex:i]]];
    }
    @catch (ZXReaderException * e) {
    }
  }

  return result;
}

@end
