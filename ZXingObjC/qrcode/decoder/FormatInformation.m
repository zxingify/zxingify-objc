#import "FormatInformation.h"

int const FORMAT_INFO_MASK_QR = 0x5412;

/**
 * See ISO 18004:2006, Annex C, Table C.1
 */
NSArray * const FORMAT_INFO_DECODE_LOOKUP = [NSArray arrayWithObjects:[NSArray arrayWithObjects:0x5412, 0x00, nil], [NSArray arrayWithObjects:0x5125, 0x01, nil], [NSArray arrayWithObjects:0x5E7C, 0x02, nil], [NSArray arrayWithObjects:0x5B4B, 0x03, nil], [NSArray arrayWithObjects:0x45F9, 0x04, nil], [NSArray arrayWithObjects:0x40CE, 0x05, nil], [NSArray arrayWithObjects:0x4F97, 0x06, nil], [NSArray arrayWithObjects:0x4AA0, 0x07, nil], [NSArray arrayWithObjects:0x77C4, 0x08, nil], [NSArray arrayWithObjects:0x72F3, 0x09, nil], [NSArray arrayWithObjects:0x7DAA, 0x0A, nil], [NSArray arrayWithObjects:0x789D, 0x0B, nil], [NSArray arrayWithObjects:0x662F, 0x0C, nil], [NSArray arrayWithObjects:0x6318, 0x0D, nil], [NSArray arrayWithObjects:0x6C41, 0x0E, nil], [NSArray arrayWithObjects:0x6976, 0x0F, nil], [NSArray arrayWithObjects:0x1689, 0x10, nil], [NSArray arrayWithObjects:0x13BE, 0x11, nil], [NSArray arrayWithObjects:0x1CE7, 0x12, nil], [NSArray arrayWithObjects:0x19D0, 0x13, nil], [NSArray arrayWithObjects:0x0762, 0x14, nil], [NSArray arrayWithObjects:0x0255, 0x15, nil], [NSArray arrayWithObjects:0x0D0C, 0x16, nil], [NSArray arrayWithObjects:0x083B, 0x17, nil], [NSArray arrayWithObjects:0x355F, 0x18, nil], [NSArray arrayWithObjects:0x3068, 0x19, nil], [NSArray arrayWithObjects:0x3F31, 0x1A, nil], [NSArray arrayWithObjects:0x3A06, 0x1B, nil], [NSArray arrayWithObjects:0x24B4, 0x1C, nil], [NSArray arrayWithObjects:0x2183, 0x1D, nil], [NSArray arrayWithObjects:0x2EDA, 0x1E, nil], [NSArray arrayWithObjects:0x2BED, 0x1F, nil], nil];

/**
 * Offset i holds the number of 1 bits in the binary representation of i
 */
NSArray * const BITS_SET_IN_HALF_BYTE = [NSArray arrayWithObjects:0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, nil];

@implementation FormatInformation

- (id) initWithFormatInfo:(int)formatInfo {
  if (self = [super init]) {
    errorCorrectionLevel = [ErrorCorrectionLevel forBits:(formatInfo >> 3) & 0x03];
    dataMask = (char)(formatInfo & 0x07);
  }
  return self;
}

+ (int) numBitsDiffering:(int)a b:(int)b {
  a ^= b;
  return BITS_SET_IN_HALF_BYTE[a & 0x0F] + BITS_SET_IN_HALF_BYTE[(a >>> 4 & 0x0F)] + BITS_SET_IN_HALF_BYTE[(a >>> 8 & 0x0F)] + BITS_SET_IN_HALF_BYTE[(a >>> 12 & 0x0F)] + BITS_SET_IN_HALF_BYTE[(a >>> 16 & 0x0F)] + BITS_SET_IN_HALF_BYTE[(a >>> 20 & 0x0F)] + BITS_SET_IN_HALF_BYTE[(a >>> 24 & 0x0F)] + BITS_SET_IN_HALF_BYTE[(a >>> 28 & 0x0F)];
}


/**
 * @param maskedFormatInfo1 format info indicator, with mask still applied
 * @param maskedFormatInfo2 second copy of same info; both are checked at the same time
 * to establish best match
 * @return information about the format it specifies, or <code>null</code>
 * if doesn't seem to match any known pattern
 */
+ (FormatInformation *) decodeFormatInformation:(int)maskedFormatInfo1 maskedFormatInfo2:(int)maskedFormatInfo2 {
  FormatInformation * formatInfo = [self doDecodeFormatInformation:maskedFormatInfo1 maskedFormatInfo2:maskedFormatInfo2];
  if (formatInfo != nil) {
    return formatInfo;
  }
  return [self doDecodeFormatInformation:maskedFormatInfo1 ^ FORMAT_INFO_MASK_QR maskedFormatInfo2:maskedFormatInfo2 ^ FORMAT_INFO_MASK_QR];
}

+ (FormatInformation *) doDecodeFormatInformation:(int)maskedFormatInfo1 maskedFormatInfo2:(int)maskedFormatInfo2 {
  int bestDifference = Integer.MAX_VALUE;
  int bestFormatInfo = 0;

  for (int i = 0; i < FORMAT_INFO_DECODE_LOOKUP.length; i++) {
    NSArray * decodeInfo = FORMAT_INFO_DECODE_LOOKUP[i];
    int targetInfo = decodeInfo[0];
    if (targetInfo == maskedFormatInfo1 || targetInfo == maskedFormatInfo2) {
      return [[[FormatInformation alloc] init:decodeInfo[1]] autorelease];
    }
    int bitsDifference = [self numBitsDiffering:maskedFormatInfo1 b:targetInfo];
    if (bitsDifference < bestDifference) {
      bestFormatInfo = decodeInfo[1];
      bestDifference = bitsDifference;
    }
    if (maskedFormatInfo1 != maskedFormatInfo2) {
      bitsDifference = [self numBitsDiffering:maskedFormatInfo2 b:targetInfo];
      if (bitsDifference < bestDifference) {
        bestFormatInfo = decodeInfo[1];
        bestDifference = bitsDifference;
      }
    }
  }

  if (bestDifference <= 3) {
    return [[[FormatInformation alloc] init:bestFormatInfo] autorelease];
  }
  return nil;
}

- (ErrorCorrectionLevel *) getErrorCorrectionLevel {
  return errorCorrectionLevel;
}

- (char) getDataMask {
  return dataMask;
}

- (int) hash {
  return ([errorCorrectionLevel ordinal] << 3) | (int)dataMask;
}

- (BOOL) isEqualTo:(NSObject *)o {
  if (!([o conformsToProtocol:@protocol(FormatInformation)])) {
    return NO;
  }
  FormatInformation * other = (FormatInformation *)o;
  return errorCorrectionLevel == other.errorCorrectionLevel && dataMask == other.dataMask;
}

- (void) dealloc {
  [errorCorrectionLevel release];
  [super dealloc];
}

@end
