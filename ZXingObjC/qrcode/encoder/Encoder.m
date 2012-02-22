#import "BitArray.h"
#import "BlockPair.h"
#import "ByteMatrix.h"
#import "CharacterSetECI.h"
#import "ECI.h"
#import "Encoder.h"
#import "EncodeHintType.h"
#import "ErrorCorrectionLevel.h"
#import "GenericGF.h"
#import "MaskUtil.h"
#import "MatrixUtil.h"
#import "Mode.h"
#import "QRCodeVersion.h"
#import "QRCode.h"
#import "ReedSolomonEncoder.h"
#import "WriterException.h"

// The original table is defined in the table 5 of JISX0510:2004 (p.19).
const int ALPHANUMERIC_TABLE[96] = {
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  // 0x00-0x0f
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  // 0x10-0x1f
  36, -1, -1, -1, 37, 38, -1, -1, -1, -1, 39, 40, -1, 41, 42, 43,  // 0x20-0x2f
  0,   1,  2,  3,  4,  5,  6,  7,  8,  9, 44, -1, -1, -1, -1, -1,  // 0x30-0x3f
  -1, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,  // 0x40-0x4f
  25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, -1, -1, -1, -1, -1,  // 0x50-0x5f
};

const NSStringEncoding DEFAULT_BYTE_MODE_ENCODING = NSISOLatin1StringEncoding;

@interface Encoder ()

+ (void) appendECI:(ECI *)eci bits:(BitArray *)bits;
+ (int) chooseMaskPattern:(BitArray *)bits ecLevel:(ErrorCorrectionLevel *)ecLevel version:(int)version matrix:(ByteMatrix *)matrix;
+ (void) initQRCode:(int)numInputBytes ecLevel:(ErrorCorrectionLevel *)ecLevel mode:(Mode *)mode qrCode:(QRCode *)qrCode;
+ (BOOL) isOnlyDoubleByteKanji:(NSString *)content;

@end

@implementation Encoder

+ (int) calculateMaskPenalty:(ByteMatrix *)matrix {
  int penalty = 0;
  penalty += [MaskUtil applyMaskPenaltyRule1:matrix];
  penalty += [MaskUtil applyMaskPenaltyRule2:matrix];
  penalty += [MaskUtil applyMaskPenaltyRule3:matrix];
  penalty += [MaskUtil applyMaskPenaltyRule4:matrix];
  return penalty;
}


/**
 * Encode "bytes" with the error correction level "ecLevel". The encoding mode will be chosen
 * internally by chooseMode(). On success, store the result in "qrCode".
 * 
 * We recommend you to use QRCode.EC_LEVEL_L (the lowest level) for
 * "getECLevel" since our primary use is to show QR code on desktop screens. We don't need very
 * strong error correction for this purpose.
 * 
 * Note that there is no way to encode bytes in MODE_KANJI. We might want to add EncodeWithMode()
 * with which clients can specify the encoding mode. For now, we don't need the functionality.
 */
+ (void) encode:(NSString *)content ecLevel:(ErrorCorrectionLevel *)ecLevel qrCode:(QRCode *)qrCode {
  [self encode:content ecLevel:ecLevel hints:nil qrCode:qrCode];
}

+ (void) encode:(NSString *)content ecLevel:(ErrorCorrectionLevel *)ecLevel hints:(NSMutableDictionary *)hints qrCode:(QRCode *)qrCode {
  NSStringEncoding encoding = hints == nil ? 0 : (NSStringEncoding)[[hints objectForKey:[NSNumber numberWithInt:kEncodeHintTypeCharacterSet]] unsignedIntegerValue];
  if (encoding == 0) {
    encoding = DEFAULT_BYTE_MODE_ENCODING;
  }

  // Step 1: Choose the mode (encoding).
  Mode * mode = [self chooseMode:content encoding:encoding];

  // Step 2: Append "bytes" into "dataBits" in appropriate encoding.
  BitArray * dataBits = [[[BitArray alloc] init] autorelease];
  [self appendBytes:content mode:mode bits:dataBits encoding:encoding];
  // Step 3: Initialize QR code that can contain "dataBits".
  int numInputBytes = [dataBits sizeInBytes];
  [self initQRCode:numInputBytes ecLevel:ecLevel mode:mode qrCode:qrCode];

  // Step 4: Build another bit vector that contains header and data.
  BitArray * headerAndDataBits = [[[BitArray alloc] init] autorelease];

  // Step 4.5: Append ECI message if applicable
  if ([mode isEqual:[Mode byteMode]] && DEFAULT_BYTE_MODE_ENCODING != encoding) {
    CharacterSetECI * eci = [CharacterSetECI getCharacterSetECIByEncoding:encoding];
    if (eci != nil) {
      [self appendECI:eci bits:headerAndDataBits];
    }
  }

  [self appendModeInfo:mode bits:headerAndDataBits];

  int numLetters = [mode isEqual:[Mode byteMode]] ? [dataBits sizeInBytes] : [content length];
  [self appendLengthInfo:numLetters version:[qrCode version] mode:mode bits:headerAndDataBits];
  [headerAndDataBits appendBitArray:dataBits];

  // Step 5: Terminate the bits properly.
  [self terminateBits:[qrCode numDataBytes] bits:headerAndDataBits];

  // Step 6: Interleave data bits with error correction code.
  BitArray * finalBits = [[[BitArray alloc] init] autorelease];
  [self interleaveWithECBytes:headerAndDataBits numTotalBytes:[qrCode numTotalBytes] numDataBytes:[qrCode numDataBytes] numRSBlocks:[qrCode numRSBlocks] result:finalBits];

  // Step 7: Choose the mask pattern and set to "qrCode".
  ByteMatrix * matrix = [[[ByteMatrix alloc] initWithWidth:[qrCode matrixWidth] height:[qrCode matrixWidth]] autorelease];
  [qrCode setMaskPattern:[self chooseMaskPattern:finalBits ecLevel:[qrCode eCLevel] version:[qrCode version] matrix:matrix]];

  // Step 8.  Build the matrix and set it to "qrCode".
  [MatrixUtil buildMatrix:finalBits ecLevel:[qrCode eCLevel] version:[qrCode version] maskPattern:[qrCode maskPattern] matrix:matrix];
  [qrCode setMatrix:matrix];
  // Step 9.  Make sure we have a valid QR Code.
  if (![qrCode valid]) {
    @throw [WriterException exceptionWithName:@"WriterException" reason:[NSString stringWithFormat:@"Invalid QR code: %@", [qrCode description]] userInfo:nil];
  }
}


/**
 * @return the code point of the table used in alphanumeric mode or
 * -1 if there is no corresponding code in the table.
 */
+ (int) alphanumericCode:(int)code {
  if (code < sizeof(ALPHANUMERIC_TABLE) / sizeof(int)) {
    return ALPHANUMERIC_TABLE[code];
  }
  return -1;
}

+ (Mode *) chooseMode:(NSString *)content {
  return [self chooseMode:content encoding:-1];
}


/**
 * Choose the best mode by examining the content. Note that 'encoding' is used as a hint;
 * if it is Shift_JIS, and the input is only double-byte Kanji, then we return {@link Mode#KANJI}.
 */
+ (Mode *) chooseMode:(NSString *)content encoding:(NSStringEncoding)encoding {
  if (NSShiftJISStringEncoding == encoding) {
    return [self isOnlyDoubleByteKanji:content] ? [Mode kanjiMode] : [Mode byteMode];
  }
  BOOL hasNumeric = NO;
  BOOL hasAlphanumeric = NO;
  for (int i = 0; i < [content length]; ++i) {
    unichar c = [content characterAtIndex:i];
    if (c >= '0' && c <= '9') {
      hasNumeric = YES;
    } else if ([self alphanumericCode:c] != -1) {
      hasAlphanumeric = YES;
    } else {
      return [Mode byteMode];
    }
  }
  if (hasAlphanumeric) {
    return [Mode alphanumericMode];
  } else if (hasNumeric) {
    return [Mode numericMode];
  }
  return [Mode byteMode];
}

+ (BOOL) isOnlyDoubleByteKanji:(NSString *)content {
  char* bytes = (char*)[[content dataUsingEncoding:NSShiftJISStringEncoding] bytes];
  int length = sizeof(bytes) / sizeof(char);
  if (length % 2 != 0) {
    return NO;
  }
  for (int i = 0; i < length; i += 2) {
    int byte1 = bytes[i] & 0xFF;
    if ((byte1 < 0x81 || byte1 > 0x9F) && (byte1 < 0xE0 || byte1 > 0xEB)) {
      return NO;
    }
  }
  return YES;
}

+ (int) chooseMaskPattern:(BitArray *)bits ecLevel:(ErrorCorrectionLevel *)ecLevel version:(int)version matrix:(ByteMatrix *)matrix {
  int minPenalty = NSIntegerMax;
  int bestMaskPattern = -1;

  for (int maskPattern = 0; maskPattern < NUM_MASK_PATTERNS; maskPattern++) {
    [MatrixUtil buildMatrix:bits ecLevel:ecLevel version:version maskPattern:maskPattern matrix:matrix];
    int penalty = [self calculateMaskPenalty:matrix];
    if (penalty < minPenalty) {
      minPenalty = penalty;
      bestMaskPattern = maskPattern;
    }
  }
  return bestMaskPattern;
}


/**
 * Initialize "qrCode" according to "numInputBytes", "ecLevel", and "mode". On success,
 * modify "qrCode".
 */
+ (void) initQRCode:(int)numInputBytes ecLevel:(ErrorCorrectionLevel *)ecLevel mode:(Mode *)mode qrCode:(QRCode *)qrCode {
  [qrCode setECLevel:ecLevel];
  [qrCode setMode:mode];

  for (int versionNum = 1; versionNum <= 40; versionNum++) {
    QRCodeVersion * version = [QRCodeVersion getVersionForNumber:versionNum];
    int numBytes = [version totalCodewords];
    QRCodeECBlocks * ecBlocks = [version getECBlocksForLevel:ecLevel];
    int numEcBytes = [ecBlocks totalECCodewords];
    int numRSBlocks = [ecBlocks numBlocks];
    int numDataBytes = numBytes - numEcBytes;
    if (numDataBytes >= numInputBytes + 3) {
      [qrCode setVersion:versionNum];
      [qrCode setNumTotalBytes:numBytes];
      [qrCode setNumDataBytes:numDataBytes];
      [qrCode setNumRSBlocks:numRSBlocks];
      [qrCode setNumECBytes:numEcBytes];
      [qrCode setMatrixWidth:[version dimensionForVersion]];
      return;
    }
  }

  @throw [WriterException exceptionWithName:@"WriterException" reason:@"Cannot find proper rs block info (input data too big?)" userInfo:nil];
}


/**
 * Terminate bits as described in 8.4.8 and 8.4.9 of JISX0510:2004 (p.24).
 */
+ (void) terminateBits:(int)numDataBytes bits:(BitArray *)bits {
  int capacity = numDataBytes << 3;
  if ([bits size] > capacity) {
    @throw [WriterException exceptionWithName:@"WriterException" reason:[NSString stringWithFormat:@"data bits cannot fit in the QR Code %d > %d", [bits size], capacity] userInfo:nil];
  }
  for (int i = 0; i < 4 && [bits size] < capacity; ++i) {
    [bits appendBit:NO];
  }
  int numBitsInLastByte = [bits size] & 0x07;
  if (numBitsInLastByte > 0) {
    for (int i = numBitsInLastByte; i < 8; i++) {
      [bits appendBit:NO];
    }
  }
  int numPaddingBytes = numDataBytes - [bits sizeInBytes];
  for (int i = 0; i < numPaddingBytes; ++i) {
    [bits appendBits:(i & 0x01) == 0 ? 0xEC : 0x11 numBits:8];
  }
  if ([bits size] != capacity) {
    @throw [WriterException exceptionWithName:@"WriterException" reason:@"Bits size does not equal capacity" userInfo:nil];
  }
}


/**
 * Get number of data bytes and number of error correction bytes for block id "blockID". Store
 * the result in "numDataBytesInBlock", and "numECBytesInBlock". See table 12 in 8.5.1 of
 * JISX0510:2004 (p.30)
 */
+ (void) getNumDataBytesAndNumECBytesForBlockID:(int)numTotalBytes numDataBytes:(int)numDataBytes numRSBlocks:(int)numRSBlocks blockID:(int)blockID numDataBytesInBlock:(int[])numDataBytesInBlock numECBytesInBlock:(int[])numECBytesInBlock {
  if (blockID >= numRSBlocks) {
    @throw [WriterException exceptionWithName:@"WriterException" reason:@"Block ID too large" userInfo:nil];
  }
  int numRsBlocksInGroup2 = numTotalBytes % numRSBlocks;
  int numRsBlocksInGroup1 = numRSBlocks - numRsBlocksInGroup2;
  int numTotalBytesInGroup1 = numTotalBytes / numRSBlocks;
  int numTotalBytesInGroup2 = numTotalBytesInGroup1 + 1;
  int numDataBytesInGroup1 = numDataBytes / numRSBlocks;
  int numDataBytesInGroup2 = numDataBytesInGroup1 + 1;
  int numEcBytesInGroup1 = numTotalBytesInGroup1 - numDataBytesInGroup1;
  int numEcBytesInGroup2 = numTotalBytesInGroup2 - numDataBytesInGroup2;
  if (numEcBytesInGroup1 != numEcBytesInGroup2) {
    @throw [WriterException exceptionWithName:@"WriterException" reason:@"EC bytes mismatch" userInfo:nil];
  }
  if (numRSBlocks != numRsBlocksInGroup1 + numRsBlocksInGroup2) {
    @throw [WriterException exceptionWithName:@"WriterException" reason:@"RS blocks mismatch" userInfo:nil];
  }
  if (numTotalBytes != ((numDataBytesInGroup1 + numEcBytesInGroup1) * numRsBlocksInGroup1) + ((numDataBytesInGroup2 + numEcBytesInGroup2) * numRsBlocksInGroup2)) {
    @throw [WriterException exceptionWithName:@"WriterException" reason:@"Total bytes mismatch" userInfo:nil];
  }
  if (blockID < numRsBlocksInGroup1) {
    numDataBytesInBlock[0] = numDataBytesInGroup1;
    numECBytesInBlock[0] = numEcBytesInGroup1;
  } else {
    numDataBytesInBlock[0] = numDataBytesInGroup2;
    numECBytesInBlock[0] = numEcBytesInGroup2;
  }
}


/**
 * Interleave "bits" with corresponding error correction bytes. On success, store the result in
 * "result". The interleave rule is complicated. See 8.6 of JISX0510:2004 (p.37) for details.
 */
+ (void) interleaveWithECBytes:(BitArray *)bits numTotalBytes:(int)numTotalBytes numDataBytes:(int)numDataBytes numRSBlocks:(int)numRSBlocks result:(BitArray *)result {
  if ([bits sizeInBytes] != numDataBytes) {
    @throw [WriterException exceptionWithName:@"WriterException" reason:@"Number of bits and data bytes does not match" userInfo:nil];
  }

  // Step 1.  Divide data bytes into blocks and generate error correction bytes for them. We'll
  // store the divided data bytes blocks and error correction bytes blocks into "blocks".
  int dataBytesOffset = 0;
  int maxNumDataBytes = 0;
  int maxNumEcBytes = 0;

  NSMutableArray * blocks = [NSMutableArray arrayWithCapacity:numRSBlocks];

  for (int i = 0; i < numRSBlocks; ++i) {
    int numDataBytesInBlock[1];
    int numEcBytesInBlock[1];
    [self getNumDataBytesAndNumECBytesForBlockID:numTotalBytes numDataBytes:numDataBytes numRSBlocks:numRSBlocks
                                         blockID:i numDataBytesInBlock:numDataBytesInBlock numECBytesInBlock:numEcBytesInBlock];

    int size = numDataBytesInBlock[0];
    char dataBytes[size];
    [bits toBytes:8 * dataBytesOffset array:dataBytes offset:0 numBytes:size];
    char *ecBytes = [self generateECBytes:(char*)dataBytes numEcBytesInBlock:numEcBytesInBlock[0]];
    [blocks addObject:[[[BlockPair alloc] initWithData:(char*)dataBytes errorCorrection:ecBytes] autorelease]];

    maxNumDataBytes = MAX(maxNumDataBytes, size);
    maxNumEcBytes = MAX(maxNumEcBytes, sizeof(ecBytes) / sizeof(char));
    dataBytesOffset += numDataBytesInBlock[0];
    free(ecBytes);
  }
  if (numDataBytes != dataBytesOffset) {
    @throw [WriterException exceptionWithName:@"WriterException" reason:@"Data bytes does not match offset" userInfo:nil];
  }

  for (int i = 0; i < maxNumDataBytes; ++i) {
    for (int j = 0; j < [blocks count]; ++j) {
      char * dataBytes = [[blocks objectAtIndex:j] dataBytes];
      if (i < sizeof(dataBytes) / sizeof(char)) {
        [result appendBits:dataBytes[i] numBits:8];
      }
    }
  }

  for (int i = 0; i < maxNumEcBytes; ++i) {
    for (int j = 0; j < [blocks count]; ++j) {
      char * ecBytes = [[blocks objectAtIndex:j] errorCorrectionBytes];
      if (i < sizeof(ecBytes) / sizeof(char)) {
        [result appendBits:ecBytes[i] numBits:8];
      }
    }
  }
  
  if (numTotalBytes != [result sizeInBytes]) {
    @throw [WriterException exceptionWithName:@"WriterException"
                                       reason:[NSString stringWithFormat:@"Interleaving error: %d and %d differ.", numTotalBytes, [result sizeInBytes]]
                                     userInfo:nil];
  }
}

+ (char*) generateECBytes:(char[])dataBytes numEcBytesInBlock:(int)numEcBytesInBlock {
  int numDataBytes = sizeof((char*)dataBytes) / sizeof(char);
  NSMutableArray * toEncode = [NSMutableArray arrayWithCapacity:numDataBytes + numEcBytesInBlock];
  for (int i = 0; i < numDataBytes; i++) {
    [toEncode addObject:[NSNumber numberWithInt:dataBytes[i] & 0xFF]];
  }
  [[[[ReedSolomonEncoder alloc] initWithField:[GenericGF QrCodeField256]] autorelease] encode:toEncode ecBytes:numEcBytesInBlock];

  char *ecBytes = (char*)malloc(numEcBytesInBlock * sizeof(char));
  for (int i = 0; i < numEcBytesInBlock; i++) {
    ecBytes[i] = (char)[[toEncode objectAtIndex:numDataBytes + i] charValue];
  }

  return ecBytes;
}


/**
 * Append mode info. On success, store the result in "bits".
 */
+ (void) appendModeInfo:(Mode *)mode bits:(BitArray *)bits {
  [bits appendBits:[mode bits] numBits:4];
}


/**
 * Append length info. On success, store the result in "bits".
 */
+ (void) appendLengthInfo:(int)numLetters version:(int)version mode:(Mode *)mode bits:(BitArray *)bits {
  int numBits = [mode getCharacterCountBits:[QRCodeVersion getVersionForNumber:version]];
  if (numLetters > ((1 << numBits) - 1)) {
    @throw [WriterException exceptionWithName:@"WriterException"
                                       reason:[NSString stringWithFormat:@"%d is bigger than %d", numLetters, ((1 << numBits) - 1)]
                                     userInfo:nil];
  }
  [bits appendBits:numLetters numBits:numBits];
}


/**
 * Append "bytes" in "mode" mode (encoding) into "bits". On success, store the result in "bits".
 */
+ (void) appendBytes:(NSString *)content mode:(Mode *)mode bits:(BitArray *)bits encoding:(NSStringEncoding)encoding {
  if ([mode isEqual:[Mode numericMode]]) {
    [self appendNumericBytes:content bits:bits];
  } else if ([mode isEqual:[Mode alphanumericMode]]) {
    [self appendAlphanumericBytes:content bits:bits];
  } else if ([mode isEqual:[Mode byteMode]]) {
    [self append8BitBytes:content bits:bits encoding:encoding];
  } else if ([mode isEqual:[Mode kanjiMode]]) {
    [self appendKanjiBytes:content bits:bits];
  } else {
    @throw [WriterException exceptionWithName:@"WriterException"
                                       reason:[NSString stringWithFormat:@"Invalid mode: %@", mode]
                                     userInfo:nil];
  }
}

+ (void) appendNumericBytes:(NSString *)content bits:(BitArray *)bits {
  int length = [content length];
  int i = 0;
  while (i < length) {
    int num1 = [content characterAtIndex:i] - '0';
    if (i + 2 < length) {
      int num2 = [content characterAtIndex:i + 1] - '0';
      int num3 = [content characterAtIndex:i + 2] - '0';
      [bits appendBits:num1 * 100 + num2 * 10 + num3 numBits:10];
      i += 3;
    } else if (i + 1 < length) {
      int num2 = [content characterAtIndex:i + 1] - '0';
      [bits appendBits:num1 * 10 + num2 numBits:7];
      i += 2;
    } else {
      [bits appendBits:num1 numBits:4];
      i++;
    }
  }
}

+ (void) appendAlphanumericBytes:(NSString *)content bits:(BitArray *)bits {
  int length = [content length];
  int i = 0;

  while (i < length) {
    int code1 = [self alphanumericCode:[content characterAtIndex:i]];
    if (code1 == -1) {
      @throw [[[WriterException alloc] init] autorelease];
    }
    if (i + 1 < length) {
      int code2 = [self alphanumericCode:[content characterAtIndex:i + 1]];
      if (code2 == -1) {
        @throw [[[WriterException alloc] init] autorelease];
      }
      [bits appendBits:code1 * 45 + code2 numBits:11];
      i += 2;
    } else {
      [bits appendBits:code1 numBits:6];
      i++;
    }
  }
}

+ (void) append8BitBytes:(NSString *)content bits:(BitArray *)bits encoding:(NSStringEncoding)encoding {
  char * bytes = (char*)[[content dataUsingEncoding:encoding] bytes];

  for (int i = 0; i < sizeof(bytes) / sizeof(char); ++i) {
    [bits appendBits:bytes[i] numBits:8];
  }
}

+ (void) appendKanjiBytes:(NSString *)content bits:(BitArray *)bits {
  char * bytes = (char*)[[content dataUsingEncoding:NSShiftJISStringEncoding] bytes];
  int length = sizeof(bytes) / sizeof(char);
  for (int i = 0; i < length; i += 2) {
    int byte1 = bytes[i] & 0xFF;
    int byte2 = bytes[i + 1] & 0xFF;
    int code = (byte1 << 8) | byte2;
    int subtracted = -1;
    if (code >= 0x8140 && code <= 0x9ffc) {
      subtracted = code - 0x8140;
    } else if (code >= 0xe040 && code <= 0xebbf) {
      subtracted = code - 0xc140;
    }
    if (subtracted == -1) {
      @throw [WriterException exceptionWithName:@"WriterException"
                                         reason:@"Invalid byte sequence"
                                       userInfo:nil];
    }
    int encoded = ((subtracted >> 8) * 0xc0) + (subtracted & 0xff);
    [bits appendBits:encoded numBits:13];
  }
}

+ (void) appendECI:(ECI *)eci bits:(BitArray *)bits {
  [bits appendBits:[[Mode eciMode] bits] numBits:4];
  [bits appendBits:[eci value] numBits:8];
}

@end
