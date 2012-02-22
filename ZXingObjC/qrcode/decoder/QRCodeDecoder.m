#import "BitMatrix.h"
#import "ChecksumException.h"
#import "DecoderResult.h"
#import "ErrorCorrectionLevel.h"
#import "FormatInformation.h"
#import "GenericGF.h"
#import "QRCodeBitMatrixParser.h"
#import "QRCodeDataBlock.h"
#import "QRCodeDecodedBitStreamParser.h"
#import "QRCodeDecoder.h"
#import "QRCodeVersion.h"
#import "ReedSolomonDecoder.h"
#import "ReedSolomonException.h"

@interface QRCodeDecoder ()

- (void) correctErrors:(NSMutableArray *)codewordBytes numDataCodewords:(int)numDataCodewords;

@end

@implementation QRCodeDecoder

- (id) init {
  if (self = [super init]) {
    rsDecoder = [[[ReedSolomonDecoder alloc] initWithField:[GenericGF QrCodeField256]] autorelease];
  }
  return self;
}

- (DecoderResult *) decode:(BOOL **)image {
  return [self decode:image hints:nil];
}


/**
 * <p>Convenience method that can decode a QR Code represented as a 2D array of booleans.
 * "true" is taken to mean a black module.</p>
 * 
 * @param image booleans representing white/black QR Code modules
 * @return text and bytes encoded within the QR Code
 * @throws FormatException if the QR Code cannot be decoded
 * @throws ChecksumException if error correction fails
 */
- (DecoderResult *) decode:(BOOL **)image hints:(NSMutableDictionary *)hints {
  int dimension = sizeof(image) / sizeof(BOOL *);
  BitMatrix * bits = [[[BitMatrix alloc] initWithDimension:dimension] autorelease];
  for (int i = 0; i < dimension; i++) {
    for (int j = 0; j < dimension; j++) {
      if (image[i][j]) {
        [bits set:j y:i];
      }
    }
  }

  return [self decodeMatrix:bits hints:hints];
}

- (DecoderResult *) decodeMatrix:(BitMatrix *)bits {
  return [self decodeMatrix:bits hints:nil];
}


/**
 * <p>Decodes a QR Code represented as a {@link BitMatrix}. A 1 or "true" is taken to mean a black module.</p>
 * 
 * @param bits booleans representing white/black QR Code modules
 * @return text and bytes encoded within the QR Code
 * @throws FormatException if the QR Code cannot be decoded
 * @throws ChecksumException if error correction fails
 */
- (DecoderResult *) decodeMatrix:(BitMatrix *)bits hints:(NSMutableDictionary *)hints {
  QRCodeBitMatrixParser * parser = [[[QRCodeBitMatrixParser alloc] initWithBitMatrix:bits] autorelease];
  QRCodeVersion * version = [parser readVersion];
  ErrorCorrectionLevel * ecLevel = [[parser readFormatInformation] errorCorrectionLevel];

  NSArray * codewords = [parser readCodewords];
  NSArray * dataBlocks = [QRCodeDataBlock getDataBlocks:codewords version:version ecLevel:ecLevel];

  int totalBytes = 0;
  for (QRCodeDataBlock *dataBlock in dataBlocks) {
    totalBytes += dataBlock.numDataCodewords;
  }

  unsigned char resultBytes[totalBytes];
  int resultOffset = 0;

  for (QRCodeDataBlock *dataBlock in dataBlocks) {
    NSMutableArray * codewordBytes = [dataBlock codewords];
    int numDataCodewords = [dataBlock numDataCodewords];
    [self correctErrors:codewordBytes numDataCodewords:numDataCodewords];
    for (int i = 0; i < numDataCodewords; i++) {
      resultBytes[resultOffset++] = [[codewordBytes objectAtIndex:i] charValue];
    }
  }

  return [QRCodeDecodedBitStreamParser decode:resultBytes length:totalBytes version:version ecLevel:ecLevel hints:hints];
}


/**
 * <p>Given data and error-correction codewords received, possibly corrupted by errors, attempts to
 * correct the errors in-place using Reed-Solomon error correction.</p>
 * 
 * @param codewordBytes data and error correction codewords
 * @param numDataCodewords number of codewords that are data bytes
 * @throws ChecksumException if error correction fails
 */
- (void) correctErrors:(NSMutableArray *)codewordBytes numDataCodewords:(int)numDataCodewords {
  int numCodewords = [codewordBytes count];
  NSMutableArray * codewordsInts = [NSMutableArray arrayWithCapacity:numCodewords];

  for (int i = 0; i < numCodewords; i++) {
    [codewordsInts addObject:[NSNumber numberWithInt:[[codewordBytes objectAtIndex:i] charValue] & 0xFF]];
  }

  int numECCodewords = [codewordBytes count] - numDataCodewords;

  @try {
    [rsDecoder decode:codewordsInts twoS:numECCodewords];
  }
  @catch (ReedSolomonException * rse) {
    @throw [ChecksumException checksumInstance];
  }

  for (int i = 0; i < numDataCodewords; i++) {
    [codewordBytes replaceObjectAtIndex:i withObject:[NSNumber numberWithChar:[[codewordsInts objectAtIndex:i] charValue]]];
  }
}

- (void) dealloc {
  [rsDecoder release];
  [super dealloc];
}

@end
