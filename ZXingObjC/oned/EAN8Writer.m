#import "BarcodeFormat.h"
#import "EAN8Writer.h"
#import "UPCEANReader.h"

int const codeWidth = 3 + (7 * 4) + 5 + (7 * 4) + 3;

@implementation EAN8Writer

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints {
  if (format != kBarcodeFormatEan8) {
    [NSException raise:NSInvalidArgumentException format:@"Can only encode EAN_8"];
  }
  return [super encode:contents format:format width:width height:height hints:hints];
}


/**
 * @return a byte array of horizontal pixels (0 = white, 1 = black)
 */
- (NSArray *) encode:(NSString *)contents {
  if ([contents length] != 8) {
    [NSException raise:NSInvalidArgumentException format:@"Requested contents should be 8 digits long, but got %d", [contents length]];
  }

  NSMutableArray * result = [NSMutableArray arrayWithCapacity:codeWidth];
  int pos = 0;

  pos += [UPCEANWriter appendPattern:result pos:pos pattern:(int*)START_END_PATTERN startColor:1];

  for (int i = 0; i <= 3; i++) {
    int digit = [[contents substringWithRange:NSMakeRange(i, 1)] intValue];
    pos += [UPCEANWriter appendPattern:result pos:pos pattern:(int*)L_PATTERNS[digit] startColor:0];
  }

  pos += [UPCEANWriter appendPattern:result pos:pos pattern:(int*)MIDDLE_PATTERN startColor:0];

  for (int i = 4; i <= 7; i++) {
    int digit = [[contents substringWithRange:NSMakeRange(i, 1)] intValue];
    pos += [UPCEANWriter appendPattern:result pos:pos pattern:(int*)L_PATTERNS[digit] startColor:1];
  }

  pos += [UPCEANWriter appendPattern:result pos:pos pattern:(int*)START_END_PATTERN startColor:1];

  return result;
}

@end
