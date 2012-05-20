#import "BinaryUtil.h"
#import "ZXBitArray.h"

@implementation BinaryUtil

/*
 * Constructs a BitArray from a String like the one returned from BitArray.toString()
 */
+ (ZXBitArray*)buildBitArrayFromString:(NSString*)data {
  NSString* dotsAndXs = [[data stringByReplacingOccurrencesOfString:@"1" withString:@"X"]
                         stringByReplacingOccurrencesOfString:@"0" withString:@"."];
  ZXBitArray* binary = [[[ZXBitArray alloc] initWithSize:[dotsAndXs stringByReplacingOccurrencesOfString:@" " withString:@""].length] autorelease];
  int counter = 0;

  for(int i = 0; i < dotsAndXs.length; ++i){
    if(i % 9 == 0) { // spaces
      if([dotsAndXs characterAtIndex:i] != ' ') {
        @throw [NSException exceptionWithName:@"IllegalStateException" reason:@"space expected" userInfo:nil];
      }
      continue;
    }

    unichar currentChar = [dotsAndXs characterAtIndex:i];
    if(currentChar == 'X' || currentChar == 'x') {
      [binary set:counter];
    }
    counter++;
  }
  return binary;
}

+ (ZXBitArray*)buildBitArrayFromStringWithoutSpaces:(NSString*)data {
  NSMutableString* sb = [NSMutableString string];

  NSString* dotsAndXs = [[data stringByReplacingOccurrencesOfString:@"1" withString:@"X"]
                         stringByReplacingOccurrencesOfString:@"0" withString:@"."];

  int current = 0;
  while(current < dotsAndXs.length) {
    [sb appendString:@" "];
    for(int i = 0; i < 8 && current < dotsAndXs.length; ++i){
      [sb appendFormat:@"%C", [dotsAndXs characterAtIndex:current]];
      current++;
    }
  }

  return [self buildBitArrayFromString:sb];
}


@end
