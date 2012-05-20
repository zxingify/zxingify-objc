#import "ZXBitMatrix.h"
#import "ZXChecksumException.h"
#import "ZXDataMatrixBitMatrixParser.h"
#import "ZXDataMatrixDataBlock.h"
#import "ZXDataMatrixDecodedBitStreamParser.h"
#import "ZXDataMatrixDecoder.h"
#import "ZXDataMatrixVersion.h"
#import "ZXDecoderResult.h"
#import "ZXGenericGF.h"
#import "ZXReedSolomonDecoder.h"
#import "ZXReedSolomonException.h"

@interface ZXDataMatrixDecoder ()

@property (nonatomic, retain) ZXReedSolomonDecoder * rsDecoder;

- (void) correctErrors:(NSMutableArray *)codewordBytes numDataCodewords:(int)numDataCodewords;

@end

@implementation ZXDataMatrixDecoder

@synthesize rsDecoder;

- (id) init {
  if (self = [super init]) {
    self.rsDecoder = [[[ZXReedSolomonDecoder alloc] initWithField:[ZXGenericGF DataMatrixField256]] autorelease];
  }

  return self;
}

- (void) dealloc {
  [rsDecoder release];

  [super dealloc];
}


/**
 * Convenience method that can decode a Data Matrix Code represented as a 2D array of booleans.
 * "true" is taken to mean a black module.
 */
- (ZXDecoderResult *)decode:(BOOL**)image length:(unsigned int)length {
  int dimension = length;
  ZXBitMatrix * bits = [[[ZXBitMatrix alloc] initWithDimension:dimension] autorelease];
  for (int i = 0; i < dimension; i++) {
    for (int j = 0; j < dimension; j++) {
      if (image[i][j]) {
        [bits setX:j y:i];
      }
    }
  }

  return [self decodeMatrix:bits];
}


/**
 * Decodes a Data Matrix Code represented as a BitMatrix. A 1 or "true" is taken
 * to mean a black module.
 */
- (ZXDecoderResult *)decodeMatrix:(ZXBitMatrix *)bits {
  ZXDataMatrixBitMatrixParser * parser = [[[ZXDataMatrixBitMatrixParser alloc] initWithBitMatrix:bits] autorelease];
  ZXDataMatrixVersion * version = [parser version];

  NSArray * codewords = [parser readCodewords];
  NSArray * dataBlocks = [ZXDataMatrixDataBlock dataBlocks:codewords version:version];

  int dataBlocksCount = [dataBlocks count];

  int totalBytes = 0;
  for (int i = 0; i < dataBlocksCount; i++) {
    totalBytes += [[dataBlocks objectAtIndex:i] numDataCodewords];
  }
  unsigned char resultBytes[totalBytes];

  for (int j = 0; j < dataBlocksCount; j++) {
    ZXDataMatrixDataBlock * dataBlock = [dataBlocks objectAtIndex:j];
    NSMutableArray * codewordBytes = dataBlock.codewords;
    int numDataCodewords = [dataBlock numDataCodewords];
    [self correctErrors:codewordBytes numDataCodewords:numDataCodewords];
    for (int i = 0; i < numDataCodewords; i++) {
      resultBytes[i * dataBlocksCount + j] = [[codewordBytes objectAtIndex:i] charValue];
    }
  }

  return [ZXDataMatrixDecodedBitStreamParser decode:resultBytes length:totalBytes];
}


/**
 * Given data and error-correction codewords received, possibly corrupted by errors, attempts to
 * correct the errors in-place using Reed-Solomon error correction.
 */
- (void)correctErrors:(NSMutableArray *)codewordBytes numDataCodewords:(int)numDataCodewords {
  int numCodewords = [codewordBytes count];
  int codewordsInts[numCodewords];
  for (int i = 0; i < numCodewords; i++) {
    codewordsInts[i] = [[codewordBytes objectAtIndex:i] charValue] & 0xFF;
  }
  int numECCodewords = [codewordBytes count] - numDataCodewords;
  @try {
    [rsDecoder decode:codewordsInts receivedLen:numCodewords twoS:numECCodewords];
  } @catch (ZXReedSolomonException * rse) {
    @throw [ZXChecksumException checksumInstance];
  }

  for (int i = 0; i < numDataCodewords; i++) {
    [codewordBytes replaceObjectAtIndex:i withObject:[NSNumber numberWithChar:codewordsInts[i]]];
  }
}

@end
