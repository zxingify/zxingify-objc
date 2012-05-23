#import "ZXErrors.h"
#import "ZXMultiDetector.h"
#import "ZXMultiFinderPatternFinder.h"

@implementation ZXMultiDetector

- (NSArray *)detectMulti:(ZXDecodeHints *)hints error:(NSError**)error {
  ZXMultiFinderPatternFinder * finder = [[[ZXMultiFinderPatternFinder alloc] initWithImage:self.image] autorelease];
  NSArray * info = [finder findMulti:hints error:error];
  if (info == nil || [info count] == 0) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  NSMutableArray * result = [NSMutableArray array];
  for (int i = 0; i < [info count]; i++) {
    ZXDetectorResult* patternInfo = [self processFinderPatternInfo:[info objectAtIndex:i] error:nil];
    if (patternInfo) {
      [result addObject:patternInfo];
    }
  }

  return result;
}

@end
