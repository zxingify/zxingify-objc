#import "ErrorCorrectionLevel.h"
#import "FormatInformation.h"

int const FORMAT_INFO_MASK_QR = 0x5412;

/**
 * See ISO 18004:2006, Annex C, Table C.1
 */
int const FORMAT_INFO_DECODE_LOOKUP[32][2] = {
  {0x5412, 0x00},
  {0x5125, 0x01},
  {0x5E7C, 0x02},
  {0x5B4B, 0x03},
  {0x45F9, 0x04},
  {0x40CE, 0x05},
  {0x4F97, 0x06},
  {0x4AA0, 0x07},
  {0x77C4, 0x08},
  {0x72F3, 0x09},
  {0x7DAA, 0x0A},
  {0x789D, 0x0B},
  {0x662F, 0x0C},
  {0x6318, 0x0D},
  {0x6C41, 0x0E},
  {0x6976, 0x0F},
  {0x1689, 0x10},
  {0x13BE, 0x11},
  {0x1CE7, 0x12},
  {0x19D0, 0x13},
  {0x0762, 0x14},
  {0x0255, 0x15},
  {0x0D0C, 0x16},
  {0x083B, 0x17},
  {0x355F, 0x18},
  {0x3068, 0x19},
  {0x3F31, 0x1A},
  {0x3A06, 0x1B},
  {0x24B4, 0x1C},
  {0x2183, 0x1D},
  {0x2EDA, 0x1E},
  {0x2BED, 0x1F},
};

/**
 * Offset i holds the number of 1 bits in the binary representation of i
 */
int const BITS_SET_IN_HALF_BYTE[16] = {0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4};

@interface FormatInformation ()

+ (FormatInformation *) doDecodeFormatInformation:(int)maskedFormatInfo1 maskedFormatInfo2:(int)maskedFormatInfo2;

@end

@implementation FormatInformation

@synthesize dataMask, errorCorrectionLevel;

- (id) initWithFormatInfo:(int)formatInfo {
  if (self = [super init]) {
    errorCorrectionLevel = [ErrorCorrectionLevel forBits:(formatInfo >> 3) & 0x03];
    dataMask = (char)(formatInfo & 0x07);
  }
  return self;
}

+ (int) numBitsDiffering:(int)a b:(int)b {
  a ^= b;
  return BITS_SET_IN_HALF_BYTE[a & 0x0F] +
      BITS_SET_IN_HALF_BYTE[((int)((unsigned int)a) >> 4 & 0x0F)] +
      BITS_SET_IN_HALF_BYTE[((int)((unsigned int)a) >> 8 & 0x0F)] +
      BITS_SET_IN_HALF_BYTE[((int)((unsigned int)a) >> 12 & 0x0F)] +
      BITS_SET_IN_HALF_BYTE[((int)((unsigned int)a) >> 16 & 0x0F)] +
      BITS_SET_IN_HALF_BYTE[((int)((unsigned int)a) >> 20 & 0x0F)] +
      BITS_SET_IN_HALF_BYTE[((int)((unsigned int)a) >> 24 & 0x0F)] +
      BITS_SET_IN_HALF_BYTE[((int)((unsigned int)a) >> 28 & 0x0F)];
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
  int bestDifference = NSIntegerMax;
  int bestFormatInfo = 0;

  for (int i = 0; i < sizeof(FORMAT_INFO_DECODE_LOOKUP) / sizeof(int*); i++) {
    int targetInfo = FORMAT_INFO_DECODE_LOOKUP[i][0];
    if (targetInfo == maskedFormatInfo1 || targetInfo == maskedFormatInfo2) {
      return [[[FormatInformation alloc] initWithFormatInfo:FORMAT_INFO_DECODE_LOOKUP[i][1]] autorelease];
    }
    int bitsDifference = [self numBitsDiffering:maskedFormatInfo1 b:targetInfo];
    if (bitsDifference < bestDifference) {
      bestFormatInfo = FORMAT_INFO_DECODE_LOOKUP[i][1];
      bestDifference = bitsDifference;
    }
    if (maskedFormatInfo1 != maskedFormatInfo2) {
      bitsDifference = [self numBitsDiffering:maskedFormatInfo2 b:targetInfo];
      if (bitsDifference < bestDifference) {
        bestFormatInfo = FORMAT_INFO_DECODE_LOOKUP[i][1];
        bestDifference = bitsDifference;
      }
    }
  }

  if (bestDifference <= 3) {
    return [[[FormatInformation alloc] initWithFormatInfo:bestFormatInfo] autorelease];
  }
  return nil;
}

- (int) hash {
  return ([errorCorrectionLevel ordinal] << 3) | (int)dataMask;
}

- (BOOL) isEqualTo:(NSObject *)o {
  if (![o isKindOfClass:[FormatInformation class]]) {
    return NO;
  }
  FormatInformation * other = (FormatInformation *)o;
  return errorCorrectionLevel == other->errorCorrectionLevel && dataMask == other->dataMask;
}

- (void) dealloc {
  [errorCorrectionLevel release];
  [super dealloc];
}

@end
