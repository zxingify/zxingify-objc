#import "DecodeHintType.h"
#import "StringUtils.h"

@implementation StringUtils

/**
 * @param bytes bytes encoding a string, whose encoding should be guessed
 * @param hints decode hints if applicable
 * @return name of guessed encoding; at the moment will only guess one of:
 * {@link #SHIFT_JIS}, {@link #UTF8}, {@link #ISO88591}, or the platform
 * default encoding if none of these can possibly be correct
 */
+ (NSStringEncoding) guessEncoding:(unsigned char *)bytes length:(unsigned int)length hints:(NSMutableDictionary *)hints {
  BOOL assumeShiftJIS = CFStringGetSystemEncoding() == NSShiftJISStringEncoding || CFStringGetSystemEncoding() == NSJapaneseEUCStringEncoding;
  
  if (hints != nil) {
    NSString * characterSet = (NSString *)[hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypeCharacterSet]];
    if (characterSet != nil) {
      return [characterSet intValue];
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
