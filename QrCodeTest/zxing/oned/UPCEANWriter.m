#import "UPCEANWriter.h"

@implementation UPCEANWriter

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height {
  return [self encode:contents format:format width:width height:height hints:nil];
}

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints {
  if (contents == nil || [contents length] == 0) {
    @throw [[[IllegalArgumentException alloc] init:@"Found empty contents"] autorelease];
  }
  if (width < 0 || height < 0) {
    @throw [[[IllegalArgumentException alloc] init:[@"Requested dimensions are too small: " stringByAppendingString:width] + 'x' + height] autorelease];
  }
  NSArray * code = [self encode:contents];
  return [self renderResult:code width:width height:height];
}


/**
 * @return a byte array of horizontal pixels (0 = white, 1 = black)
 */
+ (BitMatrix *) renderResult:(NSArray *)code width:(int)width height:(int)height {
  int inputWidth = code.length;
  int fullWidth = inputWidth + (UPCEANReader.START_END_PATTERN.length << 1);
  int outputWidth = [Math max:width param1:fullWidth];
  int outputHeight = [Math max:1 param1:height];
  int multiple = outputWidth / fullWidth;
  int leftPadding = (outputWidth - (inputWidth * multiple)) / 2;
  BitMatrix * output = [[[BitMatrix alloc] init:outputWidth param1:outputHeight] autorelease];

  for (int inputX = 0, outputX = leftPadding; inputX < inputWidth; inputX++, outputX += multiple) {
    if (code[inputX] == 1) {
      [output setRegion:outputX param1:0 param2:multiple param3:outputHeight];
    }
  }

  return output;
}


/**
 * Appends the given pattern to the target array starting at pos.
 * 
 * @param startColor
 * starting color - 0 for white, 1 for black
 * @return the number of elements added to target.
 */
+ (int) appendPattern:(NSArray *)target pos:(int)pos pattern:(NSArray *)pattern startColor:(int)startColor {
  if (startColor != 0 && startColor != 1) {
    @throw [[[IllegalArgumentException alloc] init:[@"startColor must be either 0 or 1, but got: " stringByAppendingString:startColor]] autorelease];
  }
  char color = (char)startColor;
  int numAdded = 0;

  for (int i = 0; i < pattern.length; i++) {

    for (int j = 0; j < pattern[i]; j++) {
      target[pos] = color;
      pos += 1;
      numAdded += 1;
    }

    color ^= 1;
  }

  return numAdded;
}


/**
 * @return a byte array of horizontal pixels (0 = white, 1 = black)
 */
- (NSArray *) encode:(NSString *)contents {
}

@end
