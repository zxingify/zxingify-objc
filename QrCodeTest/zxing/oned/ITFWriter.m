#import "ITFWriter.h"

@implementation ITFWriter

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints {
  if (format != BarcodeFormat.ITF) {
    @throw [[[IllegalArgumentException alloc] init:[@"Can only encode ITF, but got " stringByAppendingString:format]] autorelease];
  }
  return [super encode:contents param1:format param2:width param3:height param4:hints];
}

- (NSArray *) encode:(NSString *)contents {
  int length = [contents length];
  if (length > 80) {
    @throw [[[IllegalArgumentException alloc] init:[@"Requested contents should be less than 80 digits long, but got " stringByAppendingString:length]] autorelease];
  }
  NSArray * result = [NSArray array];
  NSArray * start = [NSArray arrayWithObjects:1, 1, 1, 1, nil];
  int pos = [self appendPattern:result param1:0 param2:start param3:1];

  for (int i = 0; i < length; i += 2) {
    int one = [Character digit:[contents characterAtIndex:i] param1:10];
    int two = [Character digit:[contents characterAtIndex:i + 1] param1:10];
    NSArray * encoding = [NSArray array];

    for (int j = 0; j < 5; j++) {
      encoding[(j << 1)] = ITFReader.PATTERNS[one][j];
      encoding[(j << 1) + 1] = ITFReader.PATTERNS[two][j];
    }

    pos += [self appendPattern:result param1:pos param2:encoding param3:1];
  }

  NSArray * end = [NSArray arrayWithObjects:3, 1, 1, nil];
  pos += [self appendPattern:result param1:pos param2:end param3:1];
  return result;
}

@end
