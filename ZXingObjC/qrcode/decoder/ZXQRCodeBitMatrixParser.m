#import "ZXBitMatrix.h"
#import "ZXDataMask.h"
#import "ZXFormatException.h"
#import "ZXFormatInformation.h"
#import "ZXQRCodeBitMatrixParser.h"
#import "ZXQRCodeVersion.h"

@interface ZXQRCodeBitMatrixParser ()

- (int) copyBit:(int)i j:(int)j versionBits:(int)versionBits;

@end

@implementation ZXQRCodeBitMatrixParser

/**
 * @param bitMatrix {@link BitMatrix} to parse
 * @throws FormatException if dimension is not >= 21 and 1 mod 4
 */
- (id) initWithBitMatrix:(ZXBitMatrix *)aBitMatrix {
  if (self = [super init]) {
    int dimension = [aBitMatrix height];
    if (dimension < 21 || (dimension & 0x03) != 1) {
      @throw [ZXFormatException formatInstance];
    }
    bitMatrix = aBitMatrix;
  }
  return self;
}


/**
 * <p>Reads format information from one of its two locations within the QR Code.</p>
 * 
 * @return {@link FormatInformation} encapsulating the QR Code's format info
 * @throws FormatException if both format information locations cannot be parsed as
 * the valid encoding of format information
 */
- (ZXFormatInformation *) readFormatInformation {
  if (parsedFormatInfo != nil) {
    return parsedFormatInfo;
  }
  int formatInfoBits1 = 0;

  for (int i = 0; i < 6; i++) {
    formatInfoBits1 = [self copyBit:i j:8 versionBits:formatInfoBits1];
  }

  formatInfoBits1 = [self copyBit:7 j:8 versionBits:formatInfoBits1];
  formatInfoBits1 = [self copyBit:8 j:8 versionBits:formatInfoBits1];
  formatInfoBits1 = [self copyBit:8 j:7 versionBits:formatInfoBits1];

  for (int j = 5; j >= 0; j--) {
    formatInfoBits1 = [self copyBit:8 j:j versionBits:formatInfoBits1];
  }

  int dimension = [bitMatrix height];
  int formatInfoBits2 = 0;
  int jMin = dimension - 7;

  for (int j = dimension - 1; j >= jMin; j--) {
    formatInfoBits2 = [self copyBit:8 j:j versionBits:formatInfoBits2];
  }


  for (int i = dimension - 8; i < dimension; i++) {
    formatInfoBits2 = [self copyBit:i j:8 versionBits:formatInfoBits2];
  }

  parsedFormatInfo = [[ZXFormatInformation decodeFormatInformation:formatInfoBits1 maskedFormatInfo2:formatInfoBits2] retain];
  if (parsedFormatInfo != nil) {
    return parsedFormatInfo;
  }
  @throw [ZXFormatException formatInstance];
}


/**
 * <p>Reads version information from one of its two locations within the QR Code.</p>
 * 
 * @return {@link Version} encapsulating the QR Code's version
 * @throws FormatException if both version information locations cannot be parsed as
 * the valid encoding of version information
 */
- (ZXQRCodeVersion *) readVersion {
  if (parsedVersion != nil) {
    return parsedVersion;
  }
  int dimension = [bitMatrix height];
  int provisionalVersion = (dimension - 17) >> 2;
  if (provisionalVersion <= 6) {
    return [ZXQRCodeVersion getVersionForNumber:provisionalVersion];
  }
  int versionBits = 0;
  int ijMin = dimension - 11;

  for (int j = 5; j >= 0; j--) {

    for (int i = dimension - 9; i >= ijMin; i--) {
      versionBits = [self copyBit:i j:j versionBits:versionBits];
    }

  }

  parsedVersion = [ZXQRCodeVersion decodeVersionInformation:versionBits];
  if (parsedVersion != nil && [parsedVersion dimensionForVersion] == dimension) {
    return parsedVersion;
  }
  versionBits = 0;

  for (int i = 5; i >= 0; i--) {

    for (int j = dimension - 9; j >= ijMin; j--) {
      versionBits = [self copyBit:i j:j versionBits:versionBits];
    }

  }

  parsedVersion = [ZXQRCodeVersion decodeVersionInformation:versionBits];
  if (parsedVersion != nil && [parsedVersion dimensionForVersion] == dimension) {
    return parsedVersion;
  }
  @throw [ZXFormatException formatInstance];
}

- (int) copyBit:(int)i j:(int)j versionBits:(int)versionBits {
  return [bitMatrix get:i y:j] ? (versionBits << 1) | 0x1 : versionBits << 1;
}


/**
 * <p>Reads the bits in the {@link BitMatrix} representing the finder pattern in the
 * correct order in order to reconstitute the codewords bytes contained within the
 * QR Code.</p>
 * 
 * @return bytes encoded within the QR Code
 * @throws FormatException if the exact number of bytes expected is not read
 */
- (NSArray *) readCodewords {
  ZXFormatInformation * formatInfo = [self readFormatInformation];
  ZXQRCodeVersion * version = [self readVersion];
  ZXDataMask * dataMask = [ZXDataMask forReference:(int)[formatInfo dataMask]];
  int dimension = [bitMatrix height];
  [dataMask unmaskBitMatrix:bitMatrix dimension:dimension];
  ZXBitMatrix * functionPattern = [version buildFunctionPattern];
  BOOL readingUp = YES;
  NSMutableArray * result = [NSMutableArray array];
  int resultOffset = 0;
  int currentByte = 0;
  int bitsRead = 0;

  for (int j = dimension - 1; j > 0; j -= 2) {
    if (j == 6) {
      j--;
    }

    for (int count = 0; count < dimension; count++) {
      int i = readingUp ? dimension - 1 - count : count;

      for (int col = 0; col < 2; col++) {
        if (![functionPattern get:j - col y:i]) {
          bitsRead++;
          currentByte <<= 1;
          if ([bitMatrix get:j - col y:i]) {
            currentByte |= 1;
          }
          if (bitsRead == 8) {
            [result addObject:[NSNumber numberWithChar:(char)currentByte]];
            resultOffset++;
            bitsRead = 0;
            currentByte = 0;
          }
        }
      }

    }

    readingUp ^= YES;
  }

  if (resultOffset != [version totalCodewords]) {
    @throw [ZXFormatException formatInstance];
  }
  return result;
}

- (void) dealloc {
  [bitMatrix release];
  [parsedVersion release];
  [parsedFormatInfo release];
  [super dealloc];
}

@end
