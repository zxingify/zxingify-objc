#import "EAN13Writer.h"

int const codeWidth = 3 + (7 * 6) + 5 + (7 * 6) + 3;

@implementation EAN13Writer

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints {
  if (format != BarcodeFormat.EAN_13) {
    @throw [[[IllegalArgumentException alloc] init:[@"Can only encode EAN_13, but got " stringByAppendingString:format]] autorelease];
  }
  return [super encode:contents param1:format param2:width param3:height param4:hints];
}

- (NSArray *) encode:(NSString *)contents {
  if ([contents length] != 13) {
    @throw [[[IllegalArgumentException alloc] init:[@"Requested contents should be 13 digits long, but got " stringByAppendingString:[contents length]]] autorelease];
  }
  int firstDigit = [Integer parseInt:[contents substringFromIndex:0 param1:1]];
  int parities = EAN13Reader.FIRST_DIGIT_ENCODINGS[firstDigit];
  NSArray * result = [NSArray array];
  int pos = 0;
  pos += [self appendPattern:result param1:pos param2:UPCEANReader.START_END_PATTERN param3:1];

  for (int i = 1; i <= 6; i++) {
    int digit = [Integer parseInt:[contents substringFromIndex:i param1:i + 1]];
    if ((parities >> (6 - i) & 1) == 1) {
      digit += 10;
    }
    pos += [self appendPattern:result param1:pos param2:UPCEANReader.L_AND_G_PATTERNS[digit] param3:0];
  }

  pos += [self appendPattern:result param1:pos param2:UPCEANReader.MIDDLE_PATTERN param3:0];

  for (int i = 7; i <= 12; i++) {
    int digit = [Integer parseInt:[contents substringFromIndex:i param1:i + 1]];
    pos += [self appendPattern:result param1:pos param2:UPCEANReader.L_PATTERNS[digit] param3:1];
  }

  pos += [self appendPattern:result param1:pos param2:UPCEANReader.START_END_PATTERN param3:1];
  return result;
}

@end
