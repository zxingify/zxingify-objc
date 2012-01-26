#import "Code39Writer.h"

@implementation Code39Writer

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints {
  if (format != BarcodeFormat.CODE_39) {
    @throw [[[IllegalArgumentException alloc] init:[@"Can only encode CODE_39, but got " stringByAppendingString:format]] autorelease];
  }
  return [super encode:contents param1:format param2:width param3:height param4:hints];
}

- (NSArray *) encode:(NSString *)contents {
  int length = [contents length];
  if (length > 80) {
    @throw [[[IllegalArgumentException alloc] init:[@"Requested contents should be less than 80 digits long, but got " stringByAppendingString:length]] autorelease];
  }
  NSArray * widths = [NSArray array];
  int codeWidth = 24 + 1 + length;

  for (int i = 0; i < length; i++) {
    int indexInString = [Code39Reader.ALPHABET_STRING indexOf:[contents characterAtIndex:i]];
    [self toIntArray:Code39Reader.CHARACTER_ENCODINGS[indexInString] toReturn:widths];

    for (int j = 0; j < widths.length; j++) {
      codeWidth += widths[j];
    }

  }

  NSArray * result = [NSArray array];
  [self toIntArray:Code39Reader.CHARACTER_ENCODINGS[39] toReturn:widths];
  int pos = [self appendPattern:result param1:0 param2:widths param3:1];
  NSArray * narrowWhite = [NSArray arrayWithObjects:1, nil];
  pos += [self appendPattern:result param1:pos param2:narrowWhite param3:0];

  for (int i = length - 1; i >= 0; i--) {
    int indexInString = [Code39Reader.ALPHABET_STRING indexOf:[contents characterAtIndex:i]];
    [self toIntArray:Code39Reader.CHARACTER_ENCODINGS[indexInString] toReturn:widths];
    pos += [self appendPattern:result param1:pos param2:widths param3:1];
    pos += [self appendPattern:result param1:pos param2:narrowWhite param3:0];
  }

  [self toIntArray:Code39Reader.CHARACTER_ENCODINGS[39] toReturn:widths];
  pos += [self appendPattern:result param1:pos param2:widths param3:1];
  return result;
}

+ (void) toIntArray:(int)a toReturn:(NSArray *)toReturn {

  for (int i = 0; i < 9; i++) {
    int temp = a & (1 << i);
    toReturn[i] = temp == 0 ? 1 : 2;
  }

}

@end
