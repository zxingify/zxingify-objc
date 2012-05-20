#import "ZXBarcodeFormat.h"
#import "ZXEAN13Reader.h"
#import "ZXEAN13Writer.h"
#import "ZXUPCEANReader.h"

const int EAN13codeWidth = 3 + // start guard
  (7 * 6) + // left bars
  5 + // middle guard
  (7 * 6) + // right bars
  3; // end guard

@implementation ZXEAN13Writer

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height hints:(ZXEncodeHints *)hints {
  if (format != kBarcodeFormatEan13) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"Can only encode EAN_13, but got %d", format]
                                 userInfo:nil];
  }

  return [super encode:contents format:format width:width height:height hints:hints];
}

- (NSArray *)encode:(NSString *)contents {
  if ([contents length] != 13) {
    [NSException raise:NSInvalidArgumentException format:@"Requested contents should be 13 digits long, but got %d", [contents length]];
  }

  int firstDigit = [[contents substringToIndex:1] intValue];
  int parities = FIRST_DIGIT_ENCODINGS[firstDigit];
  NSMutableArray * result = [NSMutableArray arrayWithCapacity:EAN13codeWidth];
  for (int i = 0; i < EAN13codeWidth; i++) {
    [result addObject:[NSNumber numberWithInt:0]];
  }
  int pos = 0;

  pos += [ZXUPCEANWriter appendPattern:result pos:pos pattern:(int*)START_END_PATTERN patternLen:START_END_PATTERN_LEN startColor:1];

  for (int i = 1; i <= 6; i++) {
    int digit = [[contents substringWithRange:NSMakeRange(i, 1)] intValue];
    if ((parities >> (6 - i) & 1) == 1) {
      digit += 10;
    }
    pos += [ZXUPCEANWriter appendPattern:result pos:pos pattern:(int*)L_AND_G_PATTERNS[digit] patternLen:L_PATTERNS_SUB_LEN startColor:0];
  }

  pos += [ZXUPCEANWriter appendPattern:result pos:pos pattern:(int*)MIDDLE_PATTERN patternLen:MIDDLE_PATTERN_LEN startColor:0];

  for (int i = 7; i <= 12; i++) {
    int digit = [[contents substringWithRange:NSMakeRange(i, 1)] intValue];
    pos += [ZXUPCEANWriter appendPattern:result pos:pos pattern:(int*)L_PATTERNS[digit] patternLen:L_PATTERNS_SUB_LEN startColor:1];
  }
  pos += [ZXUPCEANWriter appendPattern:result pos:pos pattern:(int*)START_END_PATTERN patternLen:START_END_PATTERN_LEN startColor:1];

  return result;
}

@end
