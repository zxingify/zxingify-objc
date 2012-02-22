#import "BitMatrix.h"
#import "ChecksumException.h"
#import "DataMatrixBitMatrixParser.h"
#import "DataMatrixDataBlock.h"
#import "DataMatrixDecodedBitStreamParser.h"
#import "DataMatrixDecoder.h"
#import "DataMatrixVersion.h"
#import "DecoderResult.h"
#import "GenericGF.h"
#import "ReedSolomonDecoder.h"
#import "ReedSolomonException.h"

@interface DataMatrixDecoder ()

- (void) correctErrors:(NSMutableArray *)codewordBytes numDataCodewords:(int)numDataCodewords;

@end

@implementation DataMatrixDecoder

- (id) init {
  if (self = [super init]) {
    rsDecoder = [[[ReedSolomonDecoder alloc] initWithField:[GenericGF DataMatrixField256]] autorelease];
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
- (DecoderResult *) decode:(BOOL*[])image {
  int dimension = sizeof((BOOL*)image) / sizeof(BOOL*);
  BitMatrix * bits = [[[BitMatrix alloc] initWithDimension:dimension] autorelease];
  for (int i = 0; i < dimension; i++) {
    for (int j = 0; j < dimension; j++) {
      if (image[i][j]) {
        [bits set:j y:i];
      }
    }
  }

  return [self decodeMatrix:bits];
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
  DataMatrixBitMatrixParser * parser = [[[DataMatrixBitMatrixParser alloc] initWithBitMatrix:bits] autorelease];
  DataMatrixVersion * version = [parser version];

  NSArray * codewords = [parser readCodewords];
  NSArray * dataBlocks = [DataMatrixDataBlock getDataBlocks:codewords version:version];

  int dataBlocksCount = [dataBlocks count];

  int totalBytes = 0;
  for (int i = 0; i < dataBlocksCount; i++) {
    totalBytes += [[dataBlocks objectAtIndex:i] numDataCodewords];
  }
  unsigned char resultBytes[totalBytes];

  for (int j = 0; j < dataBlocksCount; j++) {
    DataMatrixDataBlock * dataBlock = [dataBlocks objectAtIndex:j];
    NSMutableArray * codewordBytes = [dataBlock codewords];
    int numDataCodewords = [dataBlock numDataCodewords];
    [self correctErrors:codewordBytes numDataCodewords:numDataCodewords];
    for (int i = 0; i < numDataCodewords; i++) {
      resultBytes[i * dataBlocksCount + j] = [[codewordBytes objectAtIndex:i] charValue];
    }
  }

  return [DataMatrixDecodedBitStreamParser decode:resultBytes length:totalBytes];
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
  } @catch (ReedSolomonException * rse) {
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
