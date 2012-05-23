#import "ZXBarcodeFormat.h"
#import "ZXBitMatrix.h"
#import "ZXUPCEANReader.h"
#import "ZXUPCEANWriter.h"

@interface ZXUPCEANWriter ()

- (ZXBitMatrix *)renderResult:(NSArray *)code width:(int)width height:(int)height;

@end

@implementation ZXUPCEANWriter

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height error:(NSError **)error {
  return [self encode:contents format:format width:width height:height hints:nil error:error];
}

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height hints:(ZXEncodeHints *)hints error:(NSError **)error {
  if (contents == nil || [contents length] == 0) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"Found empty contents"
                                 userInfo:nil];
  }
  if (width < 0 || height < 0) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"Requested dimensions are too small: %dx%d", width, height]
                                 userInfo:nil];
  }
  NSArray * code = [self encode:contents];
  return [self renderResult:code width:width height:height];
}


- (ZXBitMatrix *)renderResult:(NSArray *)code width:(int)width height:(int)height {
  int inputWidth = [code count];
  int fullWidth = inputWidth + ((sizeof((int*)START_END_PATTERN) / sizeof(int)) << 1);
  int outputWidth = MAX(width, fullWidth);
  int outputHeight = MAX(1, height);

  int multiple = outputWidth / fullWidth;
  int leftPadding = (outputWidth - (inputWidth * multiple)) / 2;

  ZXBitMatrix * output = [[[ZXBitMatrix alloc] initWithWidth:outputWidth height:outputHeight] autorelease];
  for (int inputX = 0, outputX = leftPadding; inputX < inputWidth; inputX++, outputX += multiple) {
    if ([[code objectAtIndex:inputX] intValue] == 1) {
      [output setRegionAtLeft:outputX top:0 width:multiple height:outputHeight];
    }
  }
  return output;
}


/**
 * Appends the given pattern to the target array starting at pos.
 */
+ (int)appendPattern:(NSMutableArray *)target pos:(int)pos pattern:(int*)pattern patternLen:(unsigned int)patternLen startColor:(int)startColor {
  if (startColor != 0 && startColor != 1) {
    [NSException raise:NSInvalidArgumentException format:@"startColor must be either 0 or 1, but got: %d", startColor];
  }

  char color = (char)startColor;
  int numAdded = 0;
  for (int i = 0; i < patternLen; i++) {
    for (int j = 0; j < pattern[i]; j++) {
      [target replaceObjectAtIndex:pos withObject:[NSNumber numberWithChar:color]];
      pos += 1;
      numAdded += 1;
    }
    color ^= 1;
  }
  return numAdded;
}

- (NSArray *)encode:(NSString *)contents {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

@end
