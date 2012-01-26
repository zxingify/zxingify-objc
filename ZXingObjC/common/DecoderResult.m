#import "DecoderResult.h"

@implementation DecoderResult

@synthesize rawBytes;
@synthesize text;
@synthesize byteSegments;
@synthesize eCLevel;

- (id) init:(NSArray *)rawBytes text:(NSString *)text byteSegments:(NSMutableArray *)byteSegments ecLevel:(NSString *)ecLevel {
  if (self = [super init]) {
    if (rawBytes == nil && text == nil) {
      @throw [[[IllegalArgumentException alloc] init] autorelease];
    }
    rawBytes = rawBytes;
    text = text;
    byteSegments = byteSegments;
    ecLevel = ecLevel;
  }
  return self;
}

- (void) dealloc {
  [rawBytes release];
  [text release];
  [byteSegments release];
  [ecLevel release];
  [super dealloc];
}

@end
