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
#import "ZXBlockPair.h"
#import "ZXByteMatrix.h"
#import "ZXCharacterSetECI.h"
#import "ZXECI.h"
#import "ZXEncoder.h"
#import "ZXEncodeHints.h"
#import "ZXErrors.h"
#import "ZXErrorCorrectionLevel.h"
#import "ZXGenericGF.h"
#import "ZXMaskUtil.h"
#import "ZXMatrixUtil.h"
#import "ZXMode.h"
#import "ZXQRCodeVersion.h"
#import "ZXQRCode.h"
#import "ZXReedSolomonEncoder.h"

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

@interface ZXEncoder ()

+ (void)appendECI:(ZXECI *)eci bits:(ZXBitArray *)bits;
+ (int)chooseMaskPattern:(ZXBitArray *)bits ecLevel:(ZXErrorCorrectionLevel *)ecLevel version:(int)version matrix:(ZXByteMatrix *)matrix error:(NSError**)error;
+ (ZXMode *)chooseMode:(NSString *)content encoding:(NSStringEncoding)encoding;
+ (BOOL)initQRCode:(int)numInputBits ecLevel:(ZXErrorCorrectionLevel *)ecLevel mode:(ZXMode *)mode qrCode:(ZXQRCode *)qrCode error:(NSError**)error;
+ (BOOL)isOnlyDoubleByteKanji:(NSString *)content;
+ (int)totalInputBytes:(int)numInputBits version:(ZXQRCodeVersion*)version mode:(ZXMode*)mode;

@end

@implementation ZXEncoder

+ (int)calculateMaskPenalty:(ZXByteMatrix *)matrix {
  int penalty = 0;
  penalty += [ZXMaskUtil applyMaskPenaltyRule1:matrix];
  penalty += [ZXMaskUtil applyMaskPenaltyRule2:matrix];
  penalty += [ZXMaskUtil applyMaskPenaltyRule3:matrix];
  penalty += [ZXMaskUtil applyMaskPenaltyRule4:matrix];
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
+ (BOOL)encode:(NSString *)content ecLevel:(ZXErrorCorrectionLevel *)ecLevel qrCode:(ZXQRCode *)qrCode error:(NSError**)error {
  return [self encode:content ecLevel:ecLevel hints:nil qrCode:qrCode error:error];
}

+ (BOOL)encode:(NSString *)content ecLevel:(ZXErrorCorrectionLevel *)ecLevel hints:(ZXEncodeHints *)hints qrCode:(ZXQRCode *)qrCode error:(NSError**)error {
  NSStringEncoding encoding = hints == nil ? 0 : hints.encoding;
  if (encoding == 0) {
    encoding = DEFAULT_BYTE_MODE_ENCODING;
  }

  // Step 1: Choose the mode (encoding).
  ZXMode * mode = [self chooseMode:content encoding:encoding];

  ZXBitArray * dataBits = [[[ZXBitArray alloc] init] autorelease];

  // Step 1.5: Append ECI message if applicable
  if ([mode isEqual:[ZXMode byteMode]] && DEFAULT_BYTE_MODE_ENCODING != encoding) {
    ZXCharacterSetECI * eci = [ZXCharacterSetECI characterSetECIByEncoding:encoding];
    if (eci != nil) {
      [self appendECI:eci bits:dataBits];
    }
  }

  // Step 2: Append "bytes" into "dataBits" in appropriate encoding.
  if (![self appendBytes:content mode:mode bits:dataBits encoding:encoding error:error]) {
    return NO;
  }

  // Step 3: Initialize QR code that can contain "dataBits".
  int numInputBits = dataBits.size;
  if (![self initQRCode:numInputBits ecLevel:ecLevel mode:mode qrCode:qrCode error:error]) {
    return NO;
  }

  // Step 4: Build another bit vector that contains header and data.
  ZXBitArray * headerAndDataBits = [[[ZXBitArray alloc] init] autorelease];

  [self appendModeInfo:mode bits:headerAndDataBits];

  int numLetters = [mode isEqual:[ZXMode byteMode]] ? [dataBits sizeInBytes] : [content length];
  if (![self appendLengthInfo:numLetters version:[qrCode version] mode:mode bits:headerAndDataBits error:error]) {
    return NO;
  }
  [headerAndDataBits appendBitArray:dataBits];

  // Step 5: Terminate the bits properly.
  if (![self terminateBits:[qrCode numDataBytes] bits:headerAndDataBits error:error]) {
    return NO;
  }

  // Step 6: Interleave data bits with error correction code.
  ZXBitArray * finalBits = [[[ZXBitArray alloc] init] autorelease];
  if (![self interleaveWithECBytes:headerAndDataBits numTotalBytes:[qrCode numTotalBytes] numDataBytes:[qrCode numDataBytes]
                       numRSBlocks:[qrCode numRSBlocks] result:finalBits error:error]) {
    return NO;
  }

  // Step 7: Choose the mask pattern and set to "qrCode".
  ZXByteMatrix * matrix = [[[ZXByteMatrix alloc] initWithWidth:[qrCode matrixWidth] height:[qrCode matrixWidth]] autorelease];
  int maskPattern = [self chooseMaskPattern:finalBits ecLevel:[qrCode ecLevel] version:[qrCode version] matrix:matrix error:error];
  if (maskPattern == -1) {
    return NO;
  }
  [qrCode setMaskPattern:maskPattern];

  // Step 8.  Build the matrix and set it to "qrCode".
  if (![ZXMatrixUtil buildMatrix:finalBits ecLevel:[qrCode ecLevel] version:[qrCode version] maskPattern:[qrCode maskPattern] matrix:matrix error:error]) {
    return NO;
  }
  [qrCode setMatrix:matrix];
  // Step 9.  Make sure we have a valid QR Code.
  if (![qrCode isValid]) {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Invalid QR code: %@", qrCode]
                                                         forKey:NSLocalizedDescriptionKey];

    if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:userInfo] autorelease];
    return NO;
  }
  return YES;
}


/**
 * Return the code point of the table used in alphanumeric mode or
 * -1 if there is no corresponding code in the table.
 */
+ (int)alphanumericCode:(int)code {
  if (code < sizeof(ALPHANUMERIC_TABLE) / sizeof(int)) {
    return ALPHANUMERIC_TABLE[code];
  }
  return -1;
}

+ (ZXMode *)chooseMode:(NSString *)content {
  return [self chooseMode:content encoding:-1];
}


/**
 * Choose the best mode by examining the content. Note that 'encoding' is used as a hint;
 * if it is Shift_JIS, and the input is only double-byte Kanji, then we return {@link Mode#KANJI}.
 */
+ (ZXMode *)chooseMode:(NSString *)content encoding:(NSStringEncoding)encoding {
  if (NSShiftJISStringEncoding == encoding) {
    return [self isOnlyDoubleByteKanji:content] ? [ZXMode kanjiMode] : [ZXMode byteMode];
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
      return [ZXMode byteMode];
    }
  }
  if (hasAlphanumeric) {
    return [ZXMode alphanumericMode];
  }
  if (hasNumeric) {
    return [ZXMode numericMode];
  }
  return [ZXMode byteMode];
}

+ (BOOL)isOnlyDoubleByteKanji:(NSString *)content {
  NSData *data = [content dataUsingEncoding:NSShiftJISStringEncoding];
  unsigned char* bytes = (unsigned char*)[data bytes];
  int length = [data length];
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

+ (int)chooseMaskPattern:(ZXBitArray *)bits ecLevel:(ZXErrorCorrectionLevel *)ecLevel version:(int)version matrix:(ZXByteMatrix *)matrix error:(NSError **)error {
  int minPenalty = NSIntegerMax;
  int bestMaskPattern = -1;

  for (int maskPattern = 0; maskPattern < NUM_MASK_PATTERNS; maskPattern++) {
    if (![ZXMatrixUtil buildMatrix:bits ecLevel:ecLevel version:version maskPattern:maskPattern matrix:matrix error:error]) {
      return -1;
    }
    int penalty = [self calculateMaskPenalty:matrix];
    if (penalty < minPenalty) {
      minPenalty = penalty;
      bestMaskPattern = maskPattern;
    }
  }
  return bestMaskPattern;
}


/**
 * Initialize "qrCode" according to "numInputBits", "ecLevel", and "mode". On success,
 * modify "qrCode".
 */
+ (BOOL)initQRCode:(int)numInputBits ecLevel:(ZXErrorCorrectionLevel *)ecLevel mode:(ZXMode *)mode qrCode:(ZXQRCode *)qrCode error:(NSError **)error {
  qrCode.ecLevel = ecLevel;
  qrCode.mode = mode;

  // In the following comments, we use numbers of Version 7-H.
  for (int versionNum = 1; versionNum <= 40; versionNum++) {
    ZXQRCodeVersion * version = [ZXQRCodeVersion versionForNumber:versionNum];
    // numBytes = 196
    int numBytes = version.totalCodewords;
    // getNumECBytes = 130
    ZXQRCodeECBlocks * ecBlocks = [version ecBlocksForLevel:ecLevel];
    int numEcBytes = ecBlocks.totalECCodewords;
    // getNumRSBlocks = 5
    int numRSBlocks = ecBlocks.numBlocks;
    // getNumDataBytes = 196 - 130 = 66
    int numDataBytes = numBytes - numEcBytes;
    // We want to choose the smallest version which can contain data of "numInputBytes" + some
    // extra bits for the header (mode info and length info). The header can be three bytes
    // (precisely 4 + 16 bits) at most.
    if (numDataBytes >= [self totalInputBytes:numInputBits version:version mode:mode]) {
      // Yay, we found the proper rs block info!
      qrCode.version = versionNum;
      qrCode.numTotalBytes = numBytes;
      qrCode.numDataBytes = numDataBytes;
      qrCode.numRSBlocks = numRSBlocks;
      // getNumECBytes = 196 - 66 = 130
      qrCode.numECBytes = numEcBytes;
      // matrix width = 21 + 6 * 4 = 45
      qrCode.matrixWidth = version.dimensionForVersion;
      return YES;
    }
  }

  NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"Cannot find proper rs block info (input data too big?)"
                                                       forKey:NSLocalizedDescriptionKey];

  if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:userInfo] autorelease];
  return NO;
}

+ (int)totalInputBytes:(int)numInputBits version:(ZXQRCodeVersion*)version mode:(ZXMode*)mode {
  int modeInfoBits = 4;
  int charCountBits = [mode characterCountBits:version];
  int headerBits = modeInfoBits + charCountBits;
  int totalBits = numInputBits + headerBits;

  return (totalBits + 7) / 8;
}

/**
 * Terminate bits as described in 8.4.8 and 8.4.9 of JISX0510:2004 (p.24).
 */
+ (BOOL)terminateBits:(int)numDataBytes bits:(ZXBitArray *)bits error:(NSError **)error {
  int capacity = numDataBytes << 3;
  if ([bits size] > capacity) {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"data bits cannot fit in the QR Code %d > %d", [bits size], capacity]
                                                         forKey:NSLocalizedDescriptionKey];

    if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:userInfo] autorelease];
    return NO;
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
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"Bits size does not equal capacity"
                                                         forKey:NSLocalizedDescriptionKey];

    if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:userInfo] autorelease];
    return NO;
  }
  return YES;
}


/**
 * Get number of data bytes and number of error correction bytes for block id "blockID". Store
 * the result in "numDataBytesInBlock", and "numECBytesInBlock". See table 12 in 8.5.1 of
 * JISX0510:2004 (p.30)
 */
+ (BOOL)numDataBytesAndNumECBytesForBlockID:(int)numTotalBytes numDataBytes:(int)numDataBytes numRSBlocks:(int)numRSBlocks blockID:(int)blockID numDataBytesInBlock:(int[])numDataBytesInBlock numECBytesInBlock:(int[])numECBytesInBlock error:(NSError **)error {
  if (blockID >= numRSBlocks) {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"Block ID too large"
                                                         forKey:NSLocalizedDescriptionKey];

    if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:userInfo] autorelease];
    return NO;
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
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"EC bytes mismatch"
                                                         forKey:NSLocalizedDescriptionKey];

    if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:userInfo] autorelease];
    return NO;
  }
  if (numRSBlocks != numRsBlocksInGroup1 + numRsBlocksInGroup2) {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"RS blocks mismatch"
                                                         forKey:NSLocalizedDescriptionKey];

    if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:userInfo] autorelease];
    return NO;
  }
  if (numTotalBytes != ((numDataBytesInGroup1 + numEcBytesInGroup1) * numRsBlocksInGroup1) + ((numDataBytesInGroup2 + numEcBytesInGroup2) * numRsBlocksInGroup2)) {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"Total bytes mismatch"
                                                         forKey:NSLocalizedDescriptionKey];

    if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:userInfo] autorelease];
    return NO;
  }
  if (blockID < numRsBlocksInGroup1) {
    numDataBytesInBlock[0] = numDataBytesInGroup1;
    numECBytesInBlock[0] = numEcBytesInGroup1;
  } else {
    numDataBytesInBlock[0] = numDataBytesInGroup2;
    numECBytesInBlock[0] = numEcBytesInGroup2;
  }
  return YES;
}


/**
 * Interleave "bits" with corresponding error correction bytes. On success, store the result in
 * "result". The interleave rule is complicated. See 8.6 of JISX0510:2004 (p.37) for details.
 */
+ (BOOL)interleaveWithECBytes:(ZXBitArray *)bits numTotalBytes:(int)numTotalBytes numDataBytes:(int)numDataBytes numRSBlocks:(int)numRSBlocks result:(ZXBitArray *)result error:(NSError **)error {
  if ([bits sizeInBytes] != numDataBytes) {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"Number of bits and data bytes does not match"
                                                         forKey:NSLocalizedDescriptionKey];

    if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:userInfo] autorelease];
    return NO;
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
    if (![self numDataBytesAndNumECBytesForBlockID:numTotalBytes numDataBytes:numDataBytes numRSBlocks:numRSBlocks
                                         blockID:i numDataBytesInBlock:numDataBytesInBlock
                                 numECBytesInBlock:numEcBytesInBlock error:error]) {
      return NO;
    }

    int size = numDataBytesInBlock[0];
    unsigned char dataBytes[size];
    [bits toBytes:8 * dataBytesOffset array:dataBytes offset:0 numBytes:size];
    unsigned char *ecBytes = [self generateECBytes:dataBytes numDataBytes:size numEcBytesInBlock:numEcBytesInBlock[0]];
    [blocks addObject:[[[ZXBlockPair alloc] initWithData:dataBytes length:size errorCorrection:ecBytes errorCorrectionLength:numEcBytesInBlock[0]] autorelease]];

    maxNumDataBytes = MAX(maxNumDataBytes, size);
    maxNumEcBytes = MAX(maxNumEcBytes, numEcBytesInBlock[0]);
    dataBytesOffset += numDataBytesInBlock[0];
    free(ecBytes);
  }
  if (numDataBytes != dataBytesOffset) {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"Data bytes does not match offset"
                                                         forKey:NSLocalizedDescriptionKey];

    if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:userInfo] autorelease];
    return NO;
  }

  for (int i = 0; i < maxNumDataBytes; ++i) {
    for (ZXBlockPair* block in blocks) {
      unsigned char * dataBytes = block.dataBytes;
      int length = block.length;
      if (i < length) {
        [result appendBits:dataBytes[i] numBits:8];
      }
    }
  }

  for (int i = 0; i < maxNumEcBytes; ++i) {
    for (ZXBlockPair* block in blocks) {
      unsigned char * ecBytes = block.errorCorrectionBytes;
      int length = block.errorCorrectionLength;
      if (i < length) {
        [result appendBits:ecBytes[i] numBits:8];
      }
    }
  }
  
  if (numTotalBytes != [result sizeInBytes]) {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Interleaving error: %d and %d differ.", numTotalBytes, [result sizeInBytes]]
                                                         forKey:NSLocalizedDescriptionKey];

    if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:userInfo] autorelease];
    return NO;
  }
  return YES;
}

+ (unsigned char*)generateECBytes:(unsigned char[])dataBytes numDataBytes:(int)numDataBytes numEcBytesInBlock:(int)numEcBytesInBlock {
  int toEncodeLen = numDataBytes + numEcBytesInBlock;
  int toEncode[toEncodeLen];
  for (int i = 0; i < numDataBytes; i++) {
    toEncode[i] = dataBytes[i] & 0xFF;
  }
  for (int i = numDataBytes; i < toEncodeLen; i++) {
    toEncode[i] = 0;
  }

  [[[[ZXReedSolomonEncoder alloc] initWithField:[ZXGenericGF QrCodeField256]] autorelease] encode:toEncode toEncodeLen:toEncodeLen ecBytes:numEcBytesInBlock];

  unsigned char *ecBytes = (unsigned char*)malloc(numEcBytesInBlock * sizeof(unsigned char));
  for (int i = 0; i < numEcBytesInBlock; i++) {
    ecBytes[i] = (unsigned char)toEncode[numDataBytes + i];
  }

  return ecBytes;
}


/**
 * Append mode info. On success, store the result in "bits".
 */
+ (void)appendModeInfo:(ZXMode *)mode bits:(ZXBitArray *)bits {
  [bits appendBits:[mode bits] numBits:4];
}


/**
 * Append length info. On success, store the result in "bits".
 */
+ (BOOL)appendLengthInfo:(int)numLetters version:(int)version mode:(ZXMode *)mode bits:(ZXBitArray *)bits error:(NSError **)error {
  int numBits = [mode characterCountBits:[ZXQRCodeVersion versionForNumber:version]];
  if (numLetters > ((1 << numBits) - 1)) {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d is bigger than %d", numLetters, ((1 << numBits) - 1)]
                                                         forKey:NSLocalizedDescriptionKey];

    if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:userInfo] autorelease];
    return NO;
  }
  [bits appendBits:numLetters numBits:numBits];
  return YES;
}


/**
 * Append "bytes" in "mode" mode (encoding) into "bits". On success, store the result in "bits".
 */
+ (BOOL)appendBytes:(NSString *)content mode:(ZXMode *)mode bits:(ZXBitArray *)bits encoding:(NSStringEncoding)encoding error:(NSError **)error {
  if ([mode isEqual:[ZXMode numericMode]]) {
    [self appendNumericBytes:content bits:bits];
  } else if ([mode isEqual:[ZXMode alphanumericMode]]) {
    if (![self appendAlphanumericBytes:content bits:bits error:error]) {
      return NO;
    }
  } else if ([mode isEqual:[ZXMode byteMode]]) {
    [self append8BitBytes:content bits:bits encoding:encoding];
  } else if ([mode isEqual:[ZXMode kanjiMode]]) {
    if (![self appendKanjiBytes:content bits:bits error:error]) {
      return NO;
    }
  } else {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Invalid mode: %@", mode]
                                                         forKey:NSLocalizedDescriptionKey];

    if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:userInfo] autorelease];
    return NO;
  }
  return YES;
}

+ (void)appendNumericBytes:(NSString *)content bits:(ZXBitArray *)bits {
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

+ (BOOL)appendAlphanumericBytes:(NSString *)content bits:(ZXBitArray *)bits error:(NSError **)error {
  int length = [content length];
  int i = 0;

  while (i < length) {
    int code1 = [self alphanumericCode:[content characterAtIndex:i]];
    if (code1 == -1) {
      if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:nil] autorelease];
      return NO;
    }
    if (i + 1 < length) {
      int code2 = [self alphanumericCode:[content characterAtIndex:i + 1]];
      if (code2 == -1) {
        if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:nil] autorelease];
        return NO;
      }
      [bits appendBits:code1 * 45 + code2 numBits:11];
      i += 2;
    } else {
      [bits appendBits:code1 numBits:6];
      i++;
    }
  }
  return YES;
}

+ (void)append8BitBytes:(NSString *)content bits:(ZXBitArray *)bits encoding:(NSStringEncoding)encoding {
  NSData *data = [content dataUsingEncoding:encoding];
  unsigned char * bytes = (unsigned char*)[data bytes];

  for (int i = 0; i < [data length]; ++i) {
    [bits appendBits:bytes[i] numBits:8];
  }
}

+ (BOOL)appendKanjiBytes:(NSString *)content bits:(ZXBitArray *)bits error:(NSError **)error {
  NSData *data = [content dataUsingEncoding:NSShiftJISStringEncoding];
  unsigned char * bytes = (unsigned char*)[data bytes];
  for (int i = 0; i < [data length]; i += 2) {
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
      NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"Invalid byte sequence"
                                                           forKey:NSLocalizedDescriptionKey];

      if (error) *error = [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:userInfo] autorelease];
      return NO;
    }
    int encoded = ((subtracted >> 8) * 0xc0) + (subtracted & 0xff);
    [bits appendBits:encoded numBits:13];
  }
  return YES;
}

+ (void)appendECI:(ZXECI *)eci bits:(ZXBitArray *)bits {
  [bits appendBits:[[ZXMode eciMode] bits] numBits:4];
  [bits appendBits:[eci value] numBits:8];
}

@end
