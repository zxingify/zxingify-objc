#import "ZXBitMatrix.h"
#import "ZXChecksumException.h"
#import "ZXDecoderResult.h"
#import "ZXErrorCorrectionLevel.h"
#import "ZXFormatInformation.h"
#import "ZXGenericGF.h"
#import "ZXQRCodeBitMatrixParser.h"
#import "ZXQRCodeDataBlock.h"
#import "ZXQRCodeDecodedBitStreamParser.h"
#import "ZXQRCodeDecoder.h"
#import "ZXQRCodeVersion.h"
#import "ZXReedSolomonDecoder.h"
#import "ZXReedSolomonException.h"

@interface ZXQRCodeDecoder ()

@property (nonatomic, retain) ZXReedSolomonDecoder * rsDecoder;

- (void) correctErrors:(NSMutableArray *)codewordBytes numDataCodewords:(int)numDataCodewords;

@end

@implementation ZXQRCodeDecoder

@synthesize rsDecoder;

- (id)init {
  if (self = [super init]) {
    self.rsDecoder = [[[ZXReedSolomonDecoder alloc] initWithField:[ZXGenericGF QrCodeField256]] autorelease];
  }

  return self;
}

- (void)dealloc {
  [rsDecoder release];

  [super dealloc];
}

- (ZXDecoderResult *)decode:(BOOL **)image length:(unsigned int)length {
  return [self decode:image length:length hints:nil];
}


/**
 * Convenience method that can decode a QR Code represented as a 2D array of booleans.
 * "true" is taken to mean a black module.
 */
- (ZXDecoderResult *)decode:(BOOL **)image length:(unsigned int)length hints:(ZXDecodeHints *)hints {
  int dimension = length;
  ZXBitMatrix * bits = [[[ZXBitMatrix alloc] initWithDimension:dimension] autorelease];
  for (int i = 0; i < dimension; i++) {
    for (int j = 0; j < dimension; j++) {
      if (image[i][j]) {
        [bits setX:j y:i];
      }
    }
  }

  return [self decodeMatrix:bits hints:hints];
}

- (ZXDecoderResult *)decodeMatrix:(ZXBitMatrix *)bits {
  return [self decodeMatrix:bits hints:nil];
}


/**
 * Decodes a QR Code represented as a {@link BitMatrix}. A 1 or "true" is taken to mean a black module.
 */
- (ZXDecoderResult *)decodeMatrix:(ZXBitMatrix *)bits hints:(ZXDecodeHints *)hints {
  ZXQRCodeBitMatrixParser * parser = [[[ZXQRCodeBitMatrixParser alloc] initWithBitMatrix:bits] autorelease];
  ZXQRCodeVersion * version = [parser readVersion];
  ZXErrorCorrectionLevel * ecLevel = [[parser readFormatInformation] errorCorrectionLevel];

  NSArray * codewords = [parser readCodewords];
  NSArray * dataBlocks = [ZXQRCodeDataBlock dataBlocks:codewords version:version ecLevel:ecLevel];

  int totalBytes = 0;
  for (ZXQRCodeDataBlock *dataBlock in dataBlocks) {
    totalBytes += dataBlock.numDataCodewords;
  }

  unsigned char resultBytes[totalBytes];
  int resultOffset = 0;

  for (ZXQRCodeDataBlock *dataBlock in dataBlocks) {
    NSMutableArray * codewordBytes = [dataBlock codewords];
    int numDataCodewords = [dataBlock numDataCodewords];
    [self correctErrors:codewordBytes numDataCodewords:numDataCodewords];
    for (int i = 0; i < numDataCodewords; i++) {
      resultBytes[resultOffset++] = [[codewordBytes objectAtIndex:i] charValue];
    }
  }

  return [ZXQRCodeDecodedBitStreamParser decode:resultBytes length:totalBytes version:version ecLevel:ecLevel hints:hints];
}


/**
 * Given data and error-correction codewords received, possibly corrupted by errors, attempts to
 * correct the errors in-place using Reed-Solomon error correction.
 */
- (void)correctErrors:(NSMutableArray *)codewordBytes numDataCodewords:(int)numDataCodewords {
  int numCodewords = [codewordBytes count];
  NSMutableArray * codewordsInts = [NSMutableArray arrayWithCapacity:numCodewords];

  for (int i = 0; i < numCodewords; i++) {
    [codewordsInts addObject:[NSNumber numberWithInt:[[codewordBytes objectAtIndex:i] charValue] & 0xFF]];
  }

  int numECCodewords = [codewordBytes count] - numDataCodewords;

  @try {
    [rsDecoder decode:codewordsInts twoS:numECCodewords];
  } @catch (ZXReedSolomonException * rse) {
    @throw [ZXChecksumException checksumInstance];
  }

  for (int i = 0; i < numDataCodewords; i++) {
    [codewordBytes replaceObjectAtIndex:i withObject:[NSNumber numberWithChar:[[codewordsInts objectAtIndex:i] charValue]]];
  }
}

@end
