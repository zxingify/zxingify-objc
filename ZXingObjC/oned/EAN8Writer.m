#import "EAN8Writer.h"

int const codeWidth = 3 + (7 * 4) + 5 + (7 * 4) + 3;

@implementation EAN8Writer

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints {
  if (format != BarcodeFormat.EAN_8) {
    @throw [[[IllegalArgumentException alloc] init:[@"Can only encode EAN_8, but got " stringByAppendingString:format]] autorelease];
  }
  return [super encode:contents param1:format param2:width param3:height param4:hints];
}


/**
 * @return a byte array of horizontal pixels (0 = white, 1 = black)
 */
- (NSArray *) encode:(NSString *)contents {
  if ([contents length] != 8) {
    @throw [[[IllegalArgumentException alloc] init:[@"Requested contents should be 8 digits long, but got " stringByAppendingString:[contents length]]] autorelease];
  }
  NSArray * result = [NSArray array];
  int pos = 0;
  pos += [self appendPattern:result param1:pos param2:UPCEANReader.START_END_PATTERN param3:1];

  for (int i = 0; i <= 3; i++) {
    int digit = [Integer parseInt:[contents substringFromIndex:i param1:i + 1]];
    pos += [self appendPattern:result param1:pos param2:UPCEANReader.L_PATTERNS[digit] param3:0];
  }

  pos += [self appendPattern:result param1:pos param2:UPCEANReader.MIDDLE_PATTERN param3:0];

  for (int i = 4; i <= 7; i++) {
    int digit = [Integer parseInt:[contents substringFromIndex:i param1:i + 1]];
    pos += [self appendPattern:result param1:pos param2:UPCEANReader.L_PATTERNS[digit] param3:1];
  }

  pos += [self appendPattern:result param1:pos param2:UPCEANReader.START_END_PATTERN param3:1];
  return result;
}

@end
