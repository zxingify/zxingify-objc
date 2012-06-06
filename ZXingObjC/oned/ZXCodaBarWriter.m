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

#import "ZXCodaBarReader.h"
#import "ZXCodaBarWriter.h"

@implementation ZXCodaBarWriter

- (id)init {
  // Super constructor requires the sum of the left and right margin length.
  // CodaBar spec requires a side margin to be more than ten times wider than narrow space.
  // In this implementation, narrow space has a unit length, so 20 is required minimum.
  return [super initWithSidesMargin:20];
}

- (unsigned char*)encode:(NSString *)contents length:(int *)pLength {

  // Verify input and calculate decoded length.
  if (![ZXCodaBarReader arrayContains:"ABCD" length:4 key:[[contents uppercaseString] characterAtIndex:0]]) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"Codabar should start with one of the following: 'A', 'B', 'C' or 'D'"
                                 userInfo:nil];
  }
  if (![ZXCodaBarReader arrayContains:"TN*E" length:4 key:[[contents uppercaseString] characterAtIndex:contents.length - 1]]) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"Codabar should end with one of the following: 'T', 'N', '*' or 'E'"
                                 userInfo:nil];
  }
  // The start character and the end character are decoded to 10 length each.
  int resultLength = 20;
  char charsWhichAreTenLengthEachAfterDecoded[4] = {'/', ':', '+', '.'};
  for (int i = 1; i < contents.length - 1; i++) {
    if (([contents characterAtIndex:i] >= '0' && [contents characterAtIndex:i] <= '9') ||
        [contents characterAtIndex:i] == '-' || [contents characterAtIndex:i] == '$') {
      resultLength += 9;
    } else if ([ZXCodaBarReader arrayContains:charsWhichAreTenLengthEachAfterDecoded length:4 key:[contents characterAtIndex:i]]) {
      resultLength += 10;
    } else {
      @throw [NSException exceptionWithName:NSInvalidArgumentException
                                     reason:[NSString stringWithFormat:@"Cannot encode : '%C'", [contents characterAtIndex:i]]
                                   userInfo:nil];
    }
  }
  // A blank is placed between each character.
  resultLength += contents.length - 1;

  if (pLength) *pLength = resultLength;
  unsigned char* result = (unsigned char*)malloc(resultLength * sizeof(unsigned char));
  int position = 0;
  for (int index = 0; index < contents.length; index++) {
    unichar c = [[contents uppercaseString] characterAtIndex:index];
    if (index == contents.length - 1) {
      // The end chars are not in the CodaBarReader.ALPHABET.
      switch (c) {
        case 'T':
          c = 'A';
          break;
        case 'N':
          c = 'B';
          break;
        case '*':
          c = 'C';
          break;
        case 'E':
          c = 'D';
          break;
      }
    }
    int code = 0;
    for (int i = 0; i < CODA_ALPHABET_LEN; i++) {
      // Found any, because I checked above.
      if (c == CODA_ALPHABET[i]) {
        code = CODA_CHARACTER_ENCODINGS[i];
        break;
      }
    }
    unsigned char color = 1;
    int counter = 0;
    int bit = 0;
    while (bit < 7) { // A character consists of 7 digit.
      result[position] = color;
      position++;
      if (((code >> (6 - bit)) & 1) == 0 || counter == 1) {
        color ^= 1; // Flip the color.
        bit++;
        counter = 0;
      } else {
        counter++;
      }
    }
    if (index < contents.length - 1) {
      result[position] = 0;
      position++;
    }
  }
  return result;
}

@end
