#import "BitMatrix.h"
#import "Code39Reader.h"
#import "Code39Writer.h"

@interface Code39Writer ()

- (void) toIntArray:(int)a toReturn:(NSArray *)toReturn;

@end

@implementation Code39Writer

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints {
  if (format != kBarcodeFormatCode39) {
    [NSException raise:NSInvalidArgumentException 
                format:@"Can only encode CODE_39."];
  }
  return [super encode:contents format:format width:width height:height hints:hints];
}

- (NSArray *) encode:(NSString *)contents {
  int length = [contents length];
  if (length > 80) {
    [NSException raise:NSInvalidArgumentException 
                format:@"Requested contents should be less than 80 digits long, but got %d", length];
  }

  NSMutableArray * widths = [NSMutableArray arrayWithCapacity:9];
  int codeWidth = 24 + 1 + length;
  for (int i = 0; i < length; i++) {
    int indexInString = [ALPHABET_STRING rangeOfString:[contents substringWithRange:NSMakeRange(i, 1)]].location;
    [self toIntArray:CHARACTER_ENCODINGS[indexInString] toReturn:widths];

    for (int j = 0; j < [widths count]; j++) {
      codeWidth += [[widths objectAtIndex:j] intValue];
    }
  }

  NSMutableArray * result = [NSMutableArray arrayWithCapacity:codeWidth];
  [self toIntArray:CHARACTER_ENCODINGS[39] toReturn:widths];
  int pos = [Code39Writer appendPattern:result pos:0 pattern:widths startColor:1];
  NSArray * narrowWhite = [NSArray arrayWithObject:[NSNumber numberWithInt:1]];
  pos += [Code39Writer appendPattern:result pos:pos pattern:narrowWhite startColor:0];

  for (int i = length - 1; i >= 0; i--) {
    int indexInString = [ALPHABET_STRING rangeOfString:[contents substringWithRange:NSMakeRange(i, 1)]].location;
    [self toIntArray:CHARACTER_ENCODINGS[indexInString] toReturn:widths];
    pos += [Code39Writer appendPattern:result pos:pos pattern:widths startColor:1];
    pos += [Code39Writer appendPattern:result pos:pos pattern:narrowWhite startColor:0];
  }

  [self toIntArray:CHARACTER_ENCODINGS[39] toReturn:widths];
  pos += [Code39Writer appendPattern:result pos:pos pattern:widths startColor:1];
  return result;
}

- (void) toIntArray:(int)a toReturn:(NSMutableArray *)toReturn {
  for (int i = 0; i < 9; i++) {
    int temp = a & (1 << i);
    [toReturn addObject:[NSNumber numberWithInt:temp == 0 ? 1 : 2]];
  }
}

@end
