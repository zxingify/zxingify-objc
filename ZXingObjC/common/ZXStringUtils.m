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

#import "ZXDecodeHints.h"
#import "ZXStringUtils.h"

@implementation ZXStringUtils

+ (NSStringEncoding)guessEncoding:(unsigned char *)bytes length:(unsigned int)length hints:(ZXDecodeHints *)hints {
  BOOL assumeShiftJIS = CFStringGetSystemEncoding() == NSShiftJISStringEncoding || CFStringGetSystemEncoding() == NSJapaneseEUCStringEncoding;
  
  if (hints != nil) {
    NSStringEncoding encoding = hints.encoding;
    if (encoding > 0) {
      return encoding;
    }
  }
  if (length > 3 && bytes[0] == (char) 0xEF &&
      bytes[1] == (char) 0xBB &&
      bytes[2] == (char) 0xBF) {
    return NSUTF8StringEncoding;
  }
  BOOL canBeISO88591 = YES;
  BOOL canBeShiftJIS = YES;
  BOOL canBeUTF8 = YES;
  int utf8BytesLeft = 0;
  int maybeDoubleByteCount = 0;
  int maybeSingleByteKatakanaCount = 0;
  BOOL sawLatin1Supplement = NO;
  BOOL sawUTF8Start = NO;
  BOOL lastWasPossibleDoubleByteStart = NO;

  for (int i = 0; i < length && (canBeISO88591 || canBeShiftJIS || canBeUTF8); i++) {
    int value = bytes[i] & 0xFF;
    if (value >= 0x80 && value <= 0xBF) {
      if (utf8BytesLeft > 0) {
        utf8BytesLeft--;
      }
    }
     else {
      if (utf8BytesLeft > 0) {
        canBeUTF8 = NO;
      }
      if (value >= 0xC0 && value <= 0xFD) {
        sawUTF8Start = YES;
        int valueCopy = value;

        while ((valueCopy & 0x40) != 0) {
          utf8BytesLeft++;
          valueCopy <<= 1;
        }

      }
    }
    if ((value == 0xC2 || value == 0xC3) && i < length - 1) {
      int nextValue = bytes[i + 1] & 0xFF;
      if (nextValue <= 0xBF && ((value == 0xC2 && nextValue >= 0xA0) || (value == 0xC3 && nextValue >= 0x80))) {
        sawLatin1Supplement = YES;
      }
    }
    if (value >= 0x7F && value <= 0x9F) {
      canBeISO88591 = NO;
    }
    if (value >= 0xA1 && value <= 0xDF) {
      if (!lastWasPossibleDoubleByteStart) {
        maybeSingleByteKatakanaCount++;
      }
    }
    if (!lastWasPossibleDoubleByteStart && ((value >= 0xF0 && value <= 0xFF) || value == 0x80 || value == 0xA0)) {
      canBeShiftJIS = NO;
    }
    if ((value >= 0x81 && value <= 0x9F) || (value >= 0xE0 && value <= 0xEF)) {
      if (lastWasPossibleDoubleByteStart) {
        lastWasPossibleDoubleByteStart = NO;
      }
       else {
        lastWasPossibleDoubleByteStart = YES;
        if (i >= length - 1) {
          canBeShiftJIS = NO;
        } else {
          int nextValue = bytes[i + 1] & 0xFF;
          if (nextValue < 0x40 || nextValue > 0xFC) {
            canBeShiftJIS = NO;
          } else {
            maybeDoubleByteCount++;
          }
        }
      }
    } else {
      lastWasPossibleDoubleByteStart = NO;
    }
  }

  if (utf8BytesLeft > 0) {
    canBeUTF8 = NO;
  }
  if (canBeShiftJIS && assumeShiftJIS) {
    return NSShiftJISStringEncoding;
  }
  if (canBeUTF8 && sawUTF8Start) {
    return NSUTF8StringEncoding;
  }
  if (canBeShiftJIS && (maybeDoubleByteCount >= 3 || 20 * maybeSingleByteKatakanaCount > length)) {
    return NSShiftJISStringEncoding;
  }
  if (!sawLatin1Supplement && canBeISO88591) {
    return NSISOLatin1StringEncoding;
  }
  return CFStringGetSystemEncoding();
}

@end
