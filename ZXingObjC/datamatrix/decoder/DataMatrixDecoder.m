#import "DataMatrixDecoder.h"

@implementation DataMatrixDecoder

- (id) init {
  if (self = [super init]) {
    rsDecoder = [[[ReedSolomonDecoder alloc] init:GenericGF.DATA_MATRIX_FIELD_256] autorelease];
  }
  return self;
}


/**
 * <p>Convenience method that can decode a Data Matrix Code represented as a 2D array of booleans.
 * "true" is taken to mean a black module.</p>
 * 
 * @param image booleans representing white/black Data Matrix Code modules
 * @return text and bytes encoded within the Data Matrix Code
 * @throws FormatException if the Data Matrix Code cannot be decoded
 * @throws ChecksumException if error correction fails
 */
- (DecoderResult *) decode:(NSArray *)image {
  int dimension = image.length;
  BitMatrix * bits = [[[BitMatrix alloc] init:dimension] autorelease];

  for (int i = 0; i < dimension; i++) {

    for (int j = 0; j < dimension; j++) {
      if (image[i][j]) {
        [bits set:j param1:i];
      }
    }

  }

  return [self decode:bits];
}


/**
 * <p>Decodes a Data Matrix Code represented as a {@link BitMatrix}. A 1 or "true" is taken
 * to mean a black module.</p>
 * 
 * @param bits booleans representing white/black Data Matrix Code modules
 * @return text and bytes encoded within the Data Matrix Code
 * @throws FormatException if the Data Matrix Code cannot be decoded
 * @throws ChecksumException if error correction fails
 */
- (DecoderResult *) decodeMatrix:(BitMatrix *)bits {
  BitMatrixParser * parser = [[[BitMatrixParser alloc] init:bits] autorelease];
  Version * version = [parser version];
  NSArray * codewords = [parser readCodewords];
  NSArray * dataBlocks = [DataBlock getDataBlocks:codewords param1:version];
  int dataBlocksCount = dataBlocks.length;
  int totalBytes = 0;

  for (int i = 0; i < dataBlocksCount; i++) {
    totalBytes += [dataBlocks[i] numDataCodewords];
  }

  NSArray * resultBytes = [NSArray array];

  for (int j = 0; j < dataBlocksCount; j++) {
    DataBlock * dataBlock = dataBlocks[j];
    NSArray * codewordBytes = [dataBlock codewords];
    int numDataCodewords = [dataBlock numDataCodewords];
    [self correctErrors:codewordBytes numDataCodewords:numDataCodewords];

    for (int i = 0; i < numDataCodewords; i++) {
      resultBytes[i * dataBlocksCount + j] = codewordBytes[i];
    }

  }

  return [DecodedBitStreamParser decode:resultBytes];
}


/**
 * <p>Given data and error-correction codewords received, possibly corrupted by errors, attempts to
 * correct the errors in-place using Reed-Solomon error correction.</p>
 * 
 * @param codewordBytes data and error correction codewords
 * @param numDataCodewords number of codewords that are data bytes
 * @throws ChecksumException if error correction fails
 */
- (void) correctErrors:(NSArray *)codewordBytes numDataCodewords:(int)numDataCodewords {
  int numCodewords = codewordBytes.length;
  NSArray * codewordsInts = [NSArray array];

  for (int i = 0; i < numCodewords; i++) {
    codewordsInts[i] = codewordBytes[i] & 0xFF;
  }

  int numECCodewords = codewordBytes.length - numDataCodewords;

  @try {
    [rsDecoder decode:codewordsInts param1:numECCodewords];
  }
  @catch (ReedSolomonException * rse) {
    @throw [ChecksumException checksumInstance];
  }

  for (int i = 0; i < numDataCodewords; i++) {
    codewordBytes[i] = (char)codewordsInts[i];
  }

}

- (void) dealloc {
  [rsDecoder release];
  [super dealloc];
}

@end
