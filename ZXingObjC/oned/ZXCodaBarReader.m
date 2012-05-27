/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXBitArray.h"
#import "ZXCodaBarReader.h"
#import "ZXErrors.h"
#import "ZXResult.h"
#import "ZXResultPoint.h"

const int CODA_ALPHABET_LEN = 22;
const char CODA_ALPHABET[CODA_ALPHABET_LEN] = "0123456789-$:/.+ABCDTN";

/**
 * These represent the encodings of characters, as patterns of wide and narrow bars. The 7 least-significant bits of
 * each int correspond to the pattern of wide and narrow, with 1s representing "wide" and 0s representing narrow. NOTE
 * : c is equal to the  * pattern NOTE : d is equal to the e pattern
 */
const int CODA_CHARACTER_ENCODINGS[22] = {
  0x003, 0x006, 0x009, 0x060, 0x012, 0x042, 0x021, 0x024, 0x030, 0x048, // 0-9
  0x00c, 0x018, 0x045, 0x051, 0x054, 0x015, 0x01A, 0x029, 0x00B, 0x00E, // -$:/.+ABCD
  0x01A, 0x029 //TN
};

// minimal number of characters that should be present (inclusing start and stop characters)
// this check has been added to reduce the number of false positive on other formats
// until the cause for this behaviour has been determined
// under normal circumstances this should be set to 3
const int minCharacterLength = 6;

// multiple start/end patterns
// official start and end patterns
const char STARTEND_ENCODING[8] = {'E', '*', 'A', 'B', 'C', 'D', 'T', 'N'};

// some industries use a checksum standard but this is not part of the original codabar standard
// for more information see : http://www.mecsw.com/specs/codabar.html

@interface ZXCodaBarReader ()

- (NSMutableArray *)findAsteriskPattern:(ZXBitArray *)row;
- (unichar)toNarrowWidePattern:(int[])counters;

@end

@implementation ZXCodaBarReader

- (ZXResult *)decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(ZXDecodeHints *)hints error:(NSError **)error {
  NSMutableArray * start = [self findAsteriskPattern:row];
  if (!start) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }
  [start replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:0]]; // BAS: settings this to 0 improves the recognition rate somehow?
  int nextStart = [[start objectAtIndex:1] intValue];
  int end = [row size];

  // Read off white space
  while (nextStart < end && ![row get:nextStart]) {
    nextStart++;
  }

  NSMutableString * result = [NSMutableString string];
  const int countersLen = 7;
  int counters[countersLen];
  int lastStart;

  do {
    for (int i = 0; i < countersLen; i++) {
      counters[i] = 0;
    }

    if (![ZXOneDReader recordPattern:row start:nextStart counters:counters countersSize:countersLen]) {
      if (error) *error = NotFoundErrorInstance();
      return nil;
    }

    unichar decodedChar = [self toNarrowWidePattern:counters];
    if (decodedChar == '!') {
      if (error) *error = NotFoundErrorInstance();
      return nil;
    }
    [result appendFormat:@"%C", decodedChar];
    lastStart = nextStart;
    for (int i = 0; i < sizeof(counters) / sizeof(int); i++) {
      nextStart += counters[i];
    }

    while (nextStart < end && ![row get:nextStart]) {
      nextStart++;
    }
  } while (nextStart < end); // no fixed end pattern so keep on reading while data is available

  // Look for whitespace after pattern:
  int lastPatternSize = 0;
  for (int i = 0; i < sizeof(counters) / sizeof(int); i++) {
    lastPatternSize += counters[i];
  }

  int whiteSpaceAfterEnd = nextStart - lastStart - lastPatternSize;
  // If 50% of last pattern size, following last pattern, is not whitespace, fail
  // (but if it's whitespace to the very end of the image, that's OK)
  if (nextStart != end && (whiteSpaceAfterEnd / 2 < lastPatternSize)) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  // valid result?
  if ([result length] < 2) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  unichar startchar = [result characterAtIndex:0];
  if (![ZXCodaBarReader arrayContains:(char*)STARTEND_ENCODING length:8 key:startchar]) {
    // invalid start character
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  // find stop character
  for (int k = 1; k < [result length]; k++) {
    if ([result characterAtIndex:k] == startchar) {
      // found stop character -> discard rest of the string
      if ((k + 1) != [result length]) {
        [result deleteCharactersInRange:NSMakeRange(k + 1, [result length] - k)];
        k = [result length];
      }
    }
  }

  // remove stop/start characters character and check if a string longer than 5 characters is contained
  if ([result length] <= minCharacterLength) {
    // Almost surely a false positive ( start + stop + at least 1 character)
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  [result deleteCharactersInRange:NSMakeRange([result length] - 1, 1)];
  [result deleteCharactersInRange:NSMakeRange(0, 1)];

  float left = (float)([[start objectAtIndex:1] intValue] + [[start objectAtIndex:0] intValue]) / 2.0f;
  float right = (float)(nextStart + lastStart) / 2.0f;
  return [[[ZXResult alloc] initWithText:result
                                rawBytes:nil
                                  length:0
                            resultPoints:[NSArray arrayWithObjects:
                                          [[[ZXResultPoint alloc] initWithX:left y:(float)rowNumber] autorelease],
                                          [[[ZXResultPoint alloc] initWithX:right y:(float)rowNumber] autorelease], nil]
                                  format:kBarcodeFormatCodabar] autorelease];
}

- (NSMutableArray *)findAsteriskPattern:(ZXBitArray *)row {
  int width = row.size;
  int rowOffset = 0;

  while (rowOffset < width) {
    if ([row get:rowOffset]) {
      break;
    }
    rowOffset++;
  }

  int counterPosition = 0;
  const int patternLength = 7;
  int counters[patternLength] = {0, 0, 0, 0, 0, 0, 0};
  int patternStart = rowOffset;
  BOOL isWhite = NO;

  for (int i = rowOffset; i < width; i++) {
    BOOL pixel = [row get:i];
    if (pixel ^ isWhite) {
      counters[counterPosition]++;
    } else {
      if (counterPosition == patternLength - 1) {
        @try {
          if ([ZXCodaBarReader arrayContains:(char*)STARTEND_ENCODING length:8 key:[self toNarrowWidePattern:counters]]) {
            if ([row isRange:MAX(0, patternStart - (i - patternStart) / 2) end:patternStart value:NO]) {
              return [NSArray arrayWithObjects:[NSNumber numberWithInt:patternStart],
                      [NSNumber numberWithInt:i], nil];
            }
          }
        } @catch (NSException * re) {
        }
        
        patternStart += counters[0] + counters[1];
        for (int y = 2; y < patternLength; y++) {
          counters[y - 2] = counters[y];
        }
        counters[patternLength - 2] = 0;
        counters[patternLength - 1] = 0;
        counterPosition--;
      } else {
        counterPosition++;
      }
      counters[counterPosition] = 1;
      isWhite ^= YES;
    }
  }

  return nil;
}

+ (BOOL)arrayContains:(char *)array length:(unsigned int)length key:(unichar)key {
  if (array != nil) {
    for (int i = 0; i < length; i++) {
      if (array[i] == key) {
        return YES;
      }
    }
  }
  return NO;
}

- (unichar)toNarrowWidePattern:(int[])counters {
  int numCounters = sizeof((int*)counters) / sizeof(int);
  int maxNarrowCounter = 0;
  
  int minCounter = NSIntegerMax;
  for (int i = 0; i < numCounters; i++) {
    if (counters[i] < minCounter) {
      minCounter = counters[i];
    }
    if (counters[i] > maxNarrowCounter) {
      maxNarrowCounter = counters[i];
    }
  }

  do {
    int wideCounters = 0;
    int pattern = 0;

    for (int i = 0; i < numCounters; i++) {
      if (counters[i] > maxNarrowCounter) {
        pattern |= 1 << (numCounters - 1 - i);
        wideCounters++;
      }
    }

    if ((wideCounters == 2) || (wideCounters == 3)) {
      for (int i = 0; i < sizeof(CODA_CHARACTER_ENCODINGS) / sizeof(int); i++) {
        if (CODA_CHARACTER_ENCODINGS[i] == pattern) {
          return CODA_ALPHABET[i];
        }
      }

    }
    maxNarrowCounter--;
  } while (maxNarrowCounter > minCounter);

  return '!';
}

@end
