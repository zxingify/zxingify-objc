#import "Code128Writer.h"

int const CODE_START_B = 104;
int const CODE_START_C = 105;
int const CODE_CODE_B = 100;
int const CODE_CODE_C = 99;
int const CODE_STOP = 106;

@implementation Code128Writer

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints {
  if (format != BarcodeFormat.CODE_128) {
    @throw [[[IllegalArgumentException alloc] init:[@"Can only encode CODE_128, but got " stringByAppendingString:format]] autorelease];
  }
  return [super encode:contents param1:format param2:width param3:height param4:hints];
}

- (NSArray *) encode:(NSString *)contents {
  int length = [contents length];
  if (length < 1 || length > 80) {
    @throw [[[IllegalArgumentException alloc] init:[@"Contents length should be between 1 and 80 characters, but got " stringByAppendingString:length]] autorelease];
  }

  for (int i = 0; i < length; i++) {
    unichar c = [contents characterAtIndex:i];
    if (c < ' ' || c > '~') {
      @throw [[[IllegalArgumentException alloc] init:@"Contents should only contain characters between ' ' and '~'"] autorelease];
    }
  }

  NSMutableArray * patterns = [[[NSMutableArray alloc] init] autorelease];
  int checkSum = 0;
  int checkWeight = 1;
  int codeSet = 0;
  int position = 0;

  while (position < length) {
    int requiredDigitCount = codeSet == CODE_CODE_C ? 2 : 4;
    int newCodeSet;
    if (length - position >= requiredDigitCount && [self isDigits:contents start:position length:requiredDigitCount]) {
      newCodeSet = CODE_CODE_C;
    }
     else {
      newCodeSet = CODE_CODE_B;
    }
    int patternIndex;
    if (newCodeSet == codeSet) {
      if (codeSet == CODE_CODE_B) {
        patternIndex = [contents characterAtIndex:position] - ' ';
        position += 1;
      }
       else {
        patternIndex = [Integer parseInt:[contents substringFromIndex:position param1:position + 2]];
        position += 2;
      }
    }
     else {
      if (codeSet == 0) {
        if (newCodeSet == CODE_CODE_B) {
          patternIndex = CODE_START_B;
        }
         else {
          patternIndex = CODE_START_C;
        }
      }
       else {
        patternIndex = newCodeSet;
      }
      codeSet = newCodeSet;
    }
    [patterns addObject:Code128Reader.CODE_PATTERNS[patternIndex]];
    checkSum += patternIndex * checkWeight;
    if (position != 0) {
      checkWeight++;
    }
  }

  checkSum %= 103;
  [patterns addObject:Code128Reader.CODE_PATTERNS[checkSum]];
  [patterns addObject:Code128Reader.CODE_PATTERNS[CODE_STOP]];
  int codeWidth = 0;
  NSEnumerator * patternEnumeration = [patterns elements];

  while ([patternEnumeration hasMoreElements]) {
    NSArray * pattern = (NSArray *)[patternEnumeration nextObject];

    for (int i = 0; i < pattern.length; i++) {
      codeWidth += pattern[i];
    }

  }

  NSArray * result = [NSArray array];
  patternEnumeration = [patterns elements];
  int pos = 0;

  while ([patternEnumeration hasMoreElements]) {
    NSArray * pattern = (NSArray *)[patternEnumeration nextObject];
    pos += [self appendPattern:result param1:pos param2:pattern param3:1];
  }

  return result;
}

+ (BOOL) isDigits:(NSString *)value start:(int)start length:(int)length {
  int end = start + length;

  for (int i = start; i < end; i++) {
    unichar c = [value characterAtIndex:i];
    if (c < '0' || c > '9') {
      return NO;
    }
  }

  return YES;
}

@end
