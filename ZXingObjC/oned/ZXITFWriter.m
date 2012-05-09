#import "ZXITFReader.h"
#import "ZXITFWriter.h"

@implementation ZXITFWriter

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height hints:(ZXEncodeHints *)hints {
  if (format != kBarcodeFormatITF) {
    [NSException raise:NSInvalidArgumentException format:@"Can only encode ITF"];
  }

  return [super encode:contents format:format width:width height:height hints:hints];
}

- (NSArray *)encode:(NSString *)contents {
  int length = [contents length];
  if (length > 80) {
    [NSException raise:NSInvalidArgumentException format:@"Requested contents should be less than 80 digits long, but got %d", length];
  }
  NSMutableArray * result = [NSMutableArray arrayWithCapacity:9 + 9 * length];
  int start[4] = {1, 1, 1, 1};
  int pos = [ZXUPCEANWriter appendPattern:result pos:0 pattern:start startColor:1];
  for (int i = 0; i < length; i += 2) {
    int one = [[contents substringWithRange:NSMakeRange(i, 1)] intValue];
    int two = [[contents substringWithRange:NSMakeRange(i + 1, 1)] intValue];
    int encoding[18];
    for (int j = 0; j < 5; j++) {
      encoding[(j << 1)] = PATTERNS[one][j];
      encoding[(j << 1) + 1] = PATTERNS[two][j];
    }
    pos += [ZXUPCEANWriter appendPattern:result pos:pos pattern:encoding startColor:1];
  }

  int end[3] = {3, 1, 1};
  pos += [ZXUPCEANWriter appendPattern:result pos:pos pattern:end startColor:1];

  return result;
}

@end
