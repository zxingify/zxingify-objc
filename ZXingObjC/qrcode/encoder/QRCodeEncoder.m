#import "MaskUtil.h"
#import "QRCodeEncoder.h"

NSArray * const ALPHANUMERIC_TABLE = [NSArray arrayWithObjects:-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 36, -1, -1, -1, 37, 38, -1, -1, -1, -1, 39, 40, -1, 41, 42, 43, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 44, -1, -1, -1, -1, -1, -1, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, -1, -1, -1, -1, -1, nil];
NSString * const DEFAULT_BYTE_MODE_ENCODING = @"ISO-8859-1";

@implementation QRCodeEncoder

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

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
  NSString * encoding = hints == nil ? nil : (NSString *)[hints objectForKey:EncodeHintType.CHARACTER_SET];
  if (encoding == nil) {
    encoding = DEFAULT_BYTE_MODE_ENCODING;
  }
  Mode * mode = [self chooseMode:content encoding:encoding];
  BitArray * dataBits = [[[BitArray alloc] init] autorelease];
  [self appendBytes:content mode:mode bits:dataBits encoding:encoding];
  int numInputBytes = [dataBits sizeInBytes];
  [self initQRCode:numInputBytes ecLevel:ecLevel mode:mode qrCode:qrCode];
  BitArray * headerAndDataBits = [[[BitArray alloc] init] autorelease];
  if (mode == Mode.BYTE && ![DEFAULT_BYTE_MODE_ENCODING isEqualToString:encoding]) {
    CharacterSetECI * eci = [CharacterSetECI getCharacterSetECIByName:encoding];
    if (eci != nil) {
      [self appendECI:eci bits:headerAndDataBits];
    }
  }
  [self appendModeInfo:mode bits:headerAndDataBits];
  int numLetters = [mode isEqualTo:Mode.BYTE] ? [dataBits sizeInBytes] : [content length];
  [self appendLengthInfo:numLetters version:[qrCode version] mode:mode bits:headerAndDataBits];
  [headerAndDataBits appendBitArray:dataBits];
  [self terminateBits:[qrCode numDataBytes] bits:headerAndDataBits];
  BitArray * finalBits = [[[BitArray alloc] init] autorelease];
  [self interleaveWithECBytes:headerAndDataBits numTotalBytes:[qrCode numTotalBytes] numDataBytes:[qrCode numDataBytes] numRSBlocks:[qrCode numRSBlocks] result:finalBits];
  ByteMatrix * matrix = [[[ByteMatrix alloc] init:[qrCode matrixWidth] param1:[qrCode matrixWidth]] autorelease];
  [qrCode setMaskPattern:[self chooseMaskPattern:finalBits ecLevel:[qrCode eCLevel] version:[qrCode version] matrix:matrix]];
  [MatrixUtil buildMatrix:finalBits param1:[qrCode eCLevel] param2:[qrCode version] param3:[qrCode maskPattern] param4:matrix];
  [qrCode setMatrix:matrix];
  if (![qrCode valid]) {
    @throw [[[WriterException alloc] init:[@"Invalid QR code: " stringByAppendingString:[qrCode description]]] autorelease];
  }
}


/**
 * @return the code point of the table used in alphanumeric mode or
 * -1 if there is no corresponding code in the table.
 */
+ (int) getAlphanumericCode:(int)code {
  if (code < ALPHANUMERIC_TABLE.length) {
    return ALPHANUMERIC_TABLE[code];
  }
  return -1;
}

+ (Mode *) chooseMode:(NSString *)content {
  return [self chooseMode:content encoding:nil];
}


/**
 * Choose the best mode by examining the content. Note that 'encoding' is used as a hint;
 * if it is Shift_JIS, and the input is only double-byte Kanji, then we return {@link Mode#KANJI}.
 */
+ (Mode *) chooseMode:(NSString *)content encoding:(NSString *)encoding {
  if ([@"Shift_JIS" isEqualToString:encoding]) {
    return [self isOnlyDoubleByteKanji:content] ? Mode.KANJI : Mode.BYTE;
  }
  BOOL hasNumeric = NO;
  BOOL hasAlphanumeric = NO;

  for (int i = 0; i < [content length]; ++i) {
    unichar c = [content characterAtIndex:i];
    if (c >= '0' && c <= '9') {
      hasNumeric = YES;
    }
     else if ([self getAlphanumericCode:c] != -1) {
      hasAlphanumeric = YES;
    }
     else {
      return Mode.BYTE;
    }
  }

  if (hasAlphanumeric) {
    return Mode.ALPHANUMERIC;
  }
   else if (hasNumeric) {
    return Mode.NUMERIC;
  }
  return Mode.BYTE;
}

+ (BOOL) isOnlyDoubleByteKanji:(NSString *)content {
  NSArray * bytes;

  @try {
    bytes = [content getBytes:@"Shift_JIS"];
  }
  @catch (UnsupportedEncodingException * uee) {
    return NO;
  }
  int length = bytes.length;
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
  int minPenalty = Integer.MAX_VALUE;
  int bestMaskPattern = -1;

  for (int maskPattern = 0; maskPattern < QRCode.NUM_MASK_PATTERNS; maskPattern++) {
    [MatrixUtil buildMatrix:bits param1:ecLevel param2:version param3:maskPattern param4:matrix];
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
    Version * version = [Version getVersionForNumber:versionNum];
    int numBytes = [version totalCodewords];
    ECBlocks * ecBlocks = [version getECBlocksForLevel:ecLevel];
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

  @throw [[[WriterException alloc] init:@"Cannot find proper rs block info (input data too big?)"] autorelease];
}


/**
 * Terminate bits as described in 8.4.8 and 8.4.9 of JISX0510:2004 (p.24).
 */
+ (void) terminateBits:(int)numDataBytes bits:(BitArray *)bits {
  int capacity = numDataBytes << 3;
  if ([bits size] > capacity) {
    @throw [[[WriterException alloc] init:[[@"data bits cannot fit in the QR Code" stringByAppendingString:[bits size]] stringByAppendingString:@" > "] + capacity] autorelease];
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
    [bits appendBits:(i & 0x01) == 0 ? 0xEC : 0x11 param1:8];
  }

  if ([bits size] != capacity) {
    @throw [[[WriterException alloc] init:@"Bits size does not equal capacity"] autorelease];
  }
}


/**
 * Get number of data bytes and number of error correction bytes for block id "blockID". Store
 * the result in "numDataBytesInBlock", and "numECBytesInBlock". See table 12 in 8.5.1 of
 * JISX0510:2004 (p.30)
 */
+ (void) getNumDataBytesAndNumECBytesForBlockID:(int)numTotalBytes numDataBytes:(int)numDataBytes numRSBlocks:(int)numRSBlocks blockID:(int)blockID numDataBytesInBlock:(NSArray *)numDataBytesInBlock numECBytesInBlock:(NSArray *)numECBytesInBlock {
  if (blockID >= numRSBlocks) {
    @throw [[[WriterException alloc] init:@"Block ID too large"] autorelease];
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
    @throw [[[WriterException alloc] init:@"EC bytes mismatch"] autorelease];
  }
  if (numRSBlocks != numRsBlocksInGroup1 + numRsBlocksInGroup2) {
    @throw [[[WriterException alloc] init:@"RS blocks mismatch"] autorelease];
  }
  if (numTotalBytes != ((numDataBytesInGroup1 + numEcBytesInGroup1) * numRsBlocksInGroup1) + ((numDataBytesInGroup2 + numEcBytesInGroup2) * numRsBlocksInGroup2)) {
    @throw [[[WriterException alloc] init:@"Total bytes mismatch"] autorelease];
  }
  if (blockID < numRsBlocksInGroup1) {
    numDataBytesInBlock[0] = numDataBytesInGroup1;
    numECBytesInBlock[0] = numEcBytesInGroup1;
  }
   else {
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
    @throw [[[WriterException alloc] init:@"Number of bits and data bytes does not match"] autorelease];
  }
  int dataBytesOffset = 0;
  int maxNumDataBytes = 0;
  int maxNumEcBytes = 0;
  NSMutableArray * blocks = [[[NSMutableArray alloc] init:numRSBlocks] autorelease];

  for (int i = 0; i < numRSBlocks; ++i) {
    NSArray * numDataBytesInBlock = [NSArray array];
    NSArray * numEcBytesInBlock = [NSArray array];
    [self getNumDataBytesAndNumECBytesForBlockID:numTotalBytes numDataBytes:numDataBytes numRSBlocks:numRSBlocks blockID:i numDataBytesInBlock:numDataBytesInBlock numECBytesInBlock:numEcBytesInBlock];
    int size = numDataBytesInBlock[0];
    NSArray * dataBytes = [NSArray array];
    [bits toBytes:8 * dataBytesOffset param1:dataBytes param2:0 param3:size];
    NSArray * ecBytes = [self generateECBytes:dataBytes numEcBytesInBlock:numEcBytesInBlock[0]];
    [blocks addObject:[[[BlockPair alloc] init:dataBytes param1:ecBytes] autorelease]];
    maxNumDataBytes = [Math max:maxNumDataBytes param1:size];
    maxNumEcBytes = [Math max:maxNumEcBytes param1:ecBytes.length];
    dataBytesOffset += numDataBytesInBlock[0];
  }

  if (numDataBytes != dataBytesOffset) {
    @throw [[[WriterException alloc] init:@"Data bytes does not match offset"] autorelease];
  }

  for (int i = 0; i < maxNumDataBytes; ++i) {

    for (int j = 0; j < [blocks count]; ++j) {
      NSArray * dataBytes = [((BlockPair *)[blocks objectAtIndex:j]) dataBytes];
      if (i < dataBytes.length) {
        [result appendBits:dataBytes[i] param1:8];
      }
    }

  }


  for (int i = 0; i < maxNumEcBytes; ++i) {

    for (int j = 0; j < [blocks count]; ++j) {
      NSArray * ecBytes = [((BlockPair *)[blocks objectAtIndex:j]) errorCorrectionBytes];
      if (i < ecBytes.length) {
        [result appendBits:ecBytes[i] param1:8];
      }
    }

  }

  if (numTotalBytes != [result sizeInBytes]) {
    @throw [[[WriterException alloc] init:[[[@"Interleaving error: " stringByAppendingString:numTotalBytes] stringByAppendingString:@" and "] + [result sizeInBytes] stringByAppendingString:@" differ."]] autorelease];
  }
}

+ (NSArray *) generateECBytes:(NSArray *)dataBytes numEcBytesInBlock:(int)numEcBytesInBlock {
  int numDataBytes = dataBytes.length;
  NSArray * toEncode = [NSArray array];

  for (int i = 0; i < numDataBytes; i++) {
    toEncode[i] = dataBytes[i] & 0xFF;
  }

  [[[[ReedSolomonEncoder alloc] init:GenericGF.QR_CODE_FIELD_256] autorelease] encode:toEncode param1:numEcBytesInBlock];
  NSArray * ecBytes = [NSArray array];

  for (int i = 0; i < numEcBytesInBlock; i++) {
    ecBytes[i] = (char)toEncode[numDataBytes + i];
  }

  return ecBytes;
}


/**
 * Append mode info. On success, store the result in "bits".
 */
+ (void) appendModeInfo:(Mode *)mode bits:(BitArray *)bits {
  [bits appendBits:[mode bits] param1:4];
}


/**
 * Append length info. On success, store the result in "bits".
 */
+ (void) appendLengthInfo:(int)numLetters version:(int)version mode:(Mode *)mode bits:(BitArray *)bits {
  int numBits = [mode getCharacterCountBits:[Version getVersionForNumber:version]];
  if (numLetters > ((1 << numBits) - 1)) {
    @throw [[[WriterException alloc] init:[numLetters stringByAppendingString:@"is bigger than"] + ((1 << numBits) - 1)] autorelease];
  }
  [bits appendBits:numLetters param1:numBits];
}


/**
 * Append "bytes" in "mode" mode (encoding) into "bits". On success, store the result in "bits".
 */
+ (void) appendBytes:(NSString *)content mode:(Mode *)mode bits:(BitArray *)bits encoding:(NSString *)encoding {
  if ([mode isEqualTo:Mode.NUMERIC]) {
    [self appendNumericBytes:content bits:bits];
  }
   else if ([mode isEqualTo:Mode.ALPHANUMERIC]) {
    [self appendAlphanumericBytes:content bits:bits];
  }
   else if ([mode isEqualTo:Mode.BYTE]) {
    [self append8BitBytes:content bits:bits encoding:encoding];
  }
   else if ([mode isEqualTo:Mode.KANJI]) {
    [self appendKanjiBytes:content bits:bits];
  }
   else {
    @throw [[[WriterException alloc] init:[@"Invalid mode: " stringByAppendingString:mode]] autorelease];
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
      [bits appendBits:num1 * 100 + num2 * 10 + num3 param1:10];
      i += 3;
    }
     else if (i + 1 < length) {
      int num2 = [content characterAtIndex:i + 1] - '0';
      [bits appendBits:num1 * 10 + num2 param1:7];
      i += 2;
    }
     else {
      [bits appendBits:num1 param1:4];
      i++;
    }
  }

}

+ (void) appendAlphanumericBytes:(NSString *)content bits:(BitArray *)bits {
  int length = [content length];
  int i = 0;

  while (i < length) {
    int code1 = [self getAlphanumericCode:[content characterAtIndex:i]];
    if (code1 == -1) {
      @throw [[[WriterException alloc] init] autorelease];
    }
    if (i + 1 < length) {
      int code2 = [self getAlphanumericCode:[content characterAtIndex:i + 1]];
      if (code2 == -1) {
        @throw [[[WriterException alloc] init] autorelease];
      }
      [bits appendBits:code1 * 45 + code2 param1:11];
      i += 2;
    }
     else {
      [bits appendBits:code1 param1:6];
      i++;
    }
  }

}

+ (void) append8BitBytes:(NSString *)content bits:(BitArray *)bits encoding:(NSString *)encoding {
  NSArray * bytes;

  @try {
    bytes = [content getBytes:encoding];
  }
  @catch (UnsupportedEncodingException * uee) {
    @throw [[[WriterException alloc] init:[uee description]] autorelease];
  }

  for (int i = 0; i < bytes.length; ++i) {
    [bits appendBits:bytes[i] param1:8];
  }

}

+ (void) appendKanjiBytes:(NSString *)content bits:(BitArray *)bits {
  NSArray * bytes;

  @try {
    bytes = [content getBytes:@"Shift_JIS"];
  }
  @catch (UnsupportedEncodingException * uee) {
    @throw [[[WriterException alloc] init:[uee description]] autorelease];
  }
  int length = bytes.length;

  for (int i = 0; i < length; i += 2) {
    int byte1 = bytes[i] & 0xFF;
    int byte2 = bytes[i + 1] & 0xFF;
    int code = (byte1 << 8) | byte2;
    int subtracted = -1;
    if (code >= 0x8140 && code <= 0x9ffc) {
      subtracted = code - 0x8140;
    }
     else if (code >= 0xe040 && code <= 0xebbf) {
      subtracted = code - 0xc140;
    }
    if (subtracted == -1) {
      @throw [[[WriterException alloc] init:@"Invalid byte sequence"] autorelease];
    }
    int encoded = ((subtracted >> 8) * 0xc0) + (subtracted & 0xff);
    [bits appendBits:encoded param1:13];
  }

}

+ (void) appendECI:(ECI *)eci bits:(BitArray *)bits {
  [bits appendBits:[Mode.ECI bits] param1:4];
  [bits appendBits:[eci value] param1:8];
}

@end
