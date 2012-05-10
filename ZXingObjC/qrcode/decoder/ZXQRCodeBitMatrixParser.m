#import "ZXBitMatrix.h"
#import "ZXDataMask.h"
#import "ZXFormatException.h"
#import "ZXFormatInformation.h"
#import "ZXQRCodeBitMatrixParser.h"
#import "ZXQRCodeVersion.h"

@interface ZXQRCodeBitMatrixParser ()

@property (nonatomic, retain) ZXBitMatrix * bitMatrix;
@property (nonatomic, retain) ZXFormatInformation * parsedFormatInfo;
@property (nonatomic, retain) ZXQRCodeVersion * parsedVersion;

- (int)copyBit:(int)i j:(int)j versionBits:(int)versionBits;

@end

@implementation ZXQRCodeBitMatrixParser

@synthesize bitMatrix;
@synthesize parsedFormatInfo;
@synthesize parsedVersion;

- (id)initWithBitMatrix:(ZXBitMatrix *)aBitMatrix {
  if (self = [super init]) {
    int dimension = aBitMatrix.height;
    if (dimension < 21 || (dimension & 0x03) != 1) {
      @throw [ZXFormatException formatInstance];
    }
    self.bitMatrix = aBitMatrix;
    self.parsedFormatInfo = nil;
    self.parsedVersion = nil;
  }
  return self;
}

- (void)dealloc {
  [bitMatrix release];
  [parsedVersion release];
  [parsedFormatInfo release];

  [super dealloc];
}

/**
 * Reads format information from one of its two locations within the QR Code.
 */
- (ZXFormatInformation *)readFormatInformation {
  if (self.parsedFormatInfo != nil) {
    return self.parsedFormatInfo;
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

  int dimension = self.bitMatrix.height;
  int formatInfoBits2 = 0;
  int jMin = dimension - 7;

  for (int j = dimension - 1; j >= jMin; j--) {
    formatInfoBits2 = [self copyBit:8 j:j versionBits:formatInfoBits2];
  }


  for (int i = dimension - 8; i < dimension; i++) {
    formatInfoBits2 = [self copyBit:i j:8 versionBits:formatInfoBits2];
  }

  self.parsedFormatInfo = [ZXFormatInformation decodeFormatInformation:formatInfoBits1 maskedFormatInfo2:formatInfoBits2];
  if (self.parsedFormatInfo != nil) {
    return self.parsedFormatInfo;
  }
  @throw [ZXFormatException formatInstance];
}


/**
 * Reads version information from one of its two locations within the QR Code.
 */
- (ZXQRCodeVersion *)readVersion {
  if (self.parsedVersion != nil) {
    return self.parsedVersion;
  }
  int dimension = self.bitMatrix.height;
  int provisionalVersion = (dimension - 17) >> 2;
  if (provisionalVersion <= 6) {
    return [ZXQRCodeVersion versionForNumber:provisionalVersion];
  }
  int versionBits = 0;
  int ijMin = dimension - 11;

  for (int j = 5; j >= 0; j--) {

    for (int i = dimension - 9; i >= ijMin; i--) {
      versionBits = [self copyBit:i j:j versionBits:versionBits];
    }

  }

  self.parsedVersion = [ZXQRCodeVersion decodeVersionInformation:versionBits];
  if (self.parsedVersion != nil && [self.parsedVersion dimensionForVersion] == dimension) {
    return self.parsedVersion;
  }
  versionBits = 0;

  for (int i = 5; i >= 0; i--) {
    for (int j = dimension - 9; j >= ijMin; j--) {
      versionBits = [self copyBit:i j:j versionBits:versionBits];
    }
  }

  self.parsedVersion = [ZXQRCodeVersion decodeVersionInformation:versionBits];
  if (self.parsedVersion != nil && self.parsedVersion.dimensionForVersion == dimension) {
    return self.parsedVersion;
  }
  @throw [ZXFormatException formatInstance];
}

- (int)copyBit:(int)i j:(int)j versionBits:(int)versionBits {
  return [self.bitMatrix get:i y:j] ? (versionBits << 1) | 0x1 : versionBits << 1;
}


/**
 * Reads the bits in the {@link BitMatrix} representing the finder pattern in the
 * correct order in order to reconstitute the codewords bytes contained within the
 * QR Code.
 */
- (NSArray *)readCodewords {
  ZXFormatInformation * formatInfo = [self readFormatInformation];
  ZXQRCodeVersion * version = [self readVersion];
  ZXDataMask * dataMask = [ZXDataMask forReference:(int)[formatInfo dataMask]];
  int dimension = self.bitMatrix.height;
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
          if ([self.bitMatrix get:j - col y:i]) {
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

@end
