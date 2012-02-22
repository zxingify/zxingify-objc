#import "BarcodeFormat.h"
#import "EAN13Reader.h"
#import "EAN13Writer.h"
#import "UPCEANReader.h"

const int EAN13codeWidth = 3 + // start guard
  (7 * 6) + // left bars
  5 + // middle guard
  (7 * 6) + // right bars
  3; // end guard

@implementation EAN13Writer

- (BitMatrix *)encode:(NSString *)contents format:(BarcodeFormat)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints {
  if (format != kBarcodeFormatEan13) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"Can only encode EAN_13, but got %d", format]
                                 userInfo:nil];
  }

  return [super encode:contents format:format width:width height:height hints:hints];
}

- (NSArray *) encode:(NSString *)contents {
  if ([contents length] != 13) {
    [NSException raise:NSInvalidArgumentException format:@"Requested contents should be 13 digits long, but got %d", [contents length]];
  }

  int firstDigit = [[contents substringToIndex:1] intValue];
  int parities = FIRST_DIGIT_ENCODINGS[firstDigit];
  NSMutableArray * result = [NSMutableArray arrayWithCapacity:EAN13codeWidth];
  int pos = 0;

  pos += [UPCEANWriter appendPattern:result pos:pos pattern:(int*)START_END_PATTERN startColor:1];

  for (int i = 1; i <= 6; i++) {
    int digit = [[contents substringWithRange:NSMakeRange(i, 1)] intValue];
    if ((parities >> (6 - i) & 1) == 1) {
      digit += 10;
    }
    pos += [UPCEANWriter appendPattern:result pos:pos pattern:(int*)L_AND_G_PATTERNS[digit] startColor:0];
  }

  pos += [UPCEANWriter appendPattern:result pos:pos pattern:(int*)MIDDLE_PATTERN startColor:0];

  for (int i = 7; i <= 12; i++) {
    int digit = [[contents substringWithRange:NSMakeRange(i, 1)] intValue];
    pos += [UPCEANWriter appendPattern:result pos:pos pattern:(int*)L_PATTERNS[digit] startColor:1];
  }
  pos += [UPCEANWriter appendPattern:result pos:pos pattern:(int*)START_END_PATTERN startColor:1];

  return result;
}

@end
