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

#import "ZXBitMatrix.h"
#import "ZXBoolArray.h"
#import "ZXCode93Reader.h"
#import "ZXCode93Writer.h"
#import "ZXIntArray.h"

@implementation ZXCode93Writer

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height hints:(ZXEncodeHints *)hints error:(NSError **)error {
  if (format != kBarcodeFormatCode93) {
    [NSException raise:NSInvalidArgumentException format:@"Can only encode CODE_93."];
  }
  return [super encode:contents format:format width:width height:height hints:hints error:error];
}

- (ZXBoolArray *)encode:(NSString *)contents {
  int length = (int)[contents length];
  if (length > 80) {
    [NSException raise:NSInvalidArgumentException
                format:@"Requested contents should be less than 80 digits long, but got %d", length];
  }

  //each character is encoded by 9 of 0/1's
  ZXIntArray *widths = [[ZXIntArray alloc] initWithLength:9];

  //lenght of code + 2 start/stop characters + 2 checksums, each of 9 bits, plus a termination bar
  int codeWidth = (length + 2 + 2) * 9 + 1;
  ZXBoolArray *result = [[ZXBoolArray alloc] initWithLength:codeWidth];

  //start character (*)
  [self toIntArray:ZX_CODE93_CHARACTER_ENCODINGS[47] toReturn:widths];
  int pos = [self appendPattern:result pos:0 pattern:widths.array patternLen:widths.length];

  for (int i = 0; i < length; i++) {
    NSUInteger indexInString = [ZX_CODE93_ALPHABET_STRING rangeOfString:[contents substringWithRange:NSMakeRange(i, 1)]].location;
    if (indexInString == NSNotFound) {
      [NSException raise:NSInvalidArgumentException format:@"Bad contents: %@", contents];
    }
    [self toIntArray:ZX_CODE93_CHARACTER_ENCODINGS[indexInString] toReturn:widths];
    pos += [self appendPattern:result pos:pos pattern:widths.array patternLen:widths.length];
  }

  //add two checksums
  int check1 = [self computeChecksumIndexFrom:contents withMaxWeight:20];
  [self toIntArray:ZX_CODE93_CHARACTER_ENCODINGS[check1] toReturn:widths];
  pos += [self appendPattern:result pos:pos pattern:widths.array patternLen:widths.length];

  //append the contents to reflect the first checksum added
  contents = [contents stringByAppendingString:[ZX_CODE93_ALPHABET_STRING substringWithRange:NSMakeRange(check1, 1)]];

  int check2 = [self computeChecksumIndexFrom:contents withMaxWeight:15];
  [self toIntArray:ZX_CODE93_CHARACTER_ENCODINGS[check2] toReturn:widths];
  pos += [self appendPattern:result pos:pos pattern:widths.array patternLen:widths.length];

  //end character (*)
  [self toIntArray:ZX_CODE93_CHARACTER_ENCODINGS[47] toReturn:widths];
  pos += [self appendPattern:result pos:pos pattern:widths.array patternLen:widths.length];

  //termination bar (single black bar)
  result.array[pos] = true;

  return result;
}

- (int)appendPattern:(ZXBoolArray *)target pos:(int)pos pattern:(const int[])pattern patternLen:(int)patternLen {
  for (int i = 0; i < patternLen; i++) {
    target.array[pos++] = pattern[i] != 0;
  }
  return 9;
}

- (int)computeChecksumIndexFrom:(NSString *)contents withMaxWeight:(int)maxWeight {
  int weight = 1;
  int total = 0;
  int length = (int)[contents length];
  for (int i = length - 1; i >= 0; i--) {
    NSUInteger indexInString = [ZX_CODE93_ALPHABET_STRING rangeOfString:[contents substringWithRange:NSMakeRange(i, 1)]].location;
    if (indexInString == NSNotFound) {
      [NSException raise:NSInvalidArgumentException format:@"Bad contents: %@", contents];
    }
    total += indexInString * weight;
    if (++weight > maxWeight) {
      weight = 1;
    }
  }
  return total % 47;
}

- (void)toIntArray:(int)a toReturn:(ZXIntArray *)toReturn {
  for (int i = 0; i < 9; i++) {
    int temp = a & (1 << (8 - i));
    toReturn.array[i] = temp == 0 ? 0 : 1;
  }
}

@end
