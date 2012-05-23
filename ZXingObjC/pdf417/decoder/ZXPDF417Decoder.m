#import "ZXBitMatrix.h"
#import "ZXErrors.h"
#import "ZXPDF417BitMatrixParser.h"
#import "ZXPDF417DecodedBitStreamParser.h"
#import "ZXPDF417Decoder.h"

int const MAX_ERRORS = 3;
int const MAX_EC_CODEWORDS = 512;

@interface ZXPDF417Decoder ()

- (int)correctErrors:(NSArray *)codewords erasures:(NSArray *)erasures numECCodewords:(int)numECCodewords;
- (BOOL)verifyCodewordCount:(NSMutableArray *)codewords numECCodewords:(int)numECCodewords;

@end

@implementation ZXPDF417Decoder

/**
 * Convenience method that can decode a PDF417 Code represented as a 2D array of booleans.
 * "true" is taken to mean a black module.
 */
- (ZXDecoderResult *)decode:(BOOL **)image length:(unsigned int)length error:(NSError **)error {
  int dimension = length;
  ZXBitMatrix * bits = [[[ZXBitMatrix alloc] initWithDimension:dimension] autorelease];
  for (int i = 0; i < dimension; i++) {
    for (int j = 0; j < dimension; j++) {
      if (image[j][i]) {
        [bits setX:j y:i];
      }
    }
  }
  return [self decodeMatrix:bits error:error];
}


/**
 * Decodes a PDF417 Code represented as a ZXBitMatrix.
 * A 1 or "true" is taken to mean a black module.
 */
- (ZXDecoderResult *)decodeMatrix:(ZXBitMatrix *)bits error:(NSError **)error {
  ZXPDF417BitMatrixParser * parser = [[[ZXPDF417BitMatrixParser alloc] initWithBitMatrix:bits] autorelease];
  NSMutableArray * codewords = [[[parser readCodewords] mutableCopy] autorelease];
  if (codewords == nil || [codewords count] == 0) {
    if (error) *error = FormatErrorInstance();
    return nil;
  }

  int ecLevel = parser.ecLevel;
  int numECCodewords = 1 << (ecLevel + 1);
  NSArray * erasures = parser.erasures;

  if ([self correctErrors:codewords erasures:erasures numECCodewords:numECCodewords] == -1 ||
      ![self verifyCodewordCount:codewords numECCodewords:numECCodewords]) {
    if (error) *error = FormatErrorInstance();
    return nil;
  }

  return [ZXPDF417DecodedBitStreamParser decode:codewords error:error];
}


/**
 * Verify that all is OK with the codeword array.
 */
- (BOOL)verifyCodewordCount:(NSMutableArray *)codewords numECCodewords:(int)numECCodewords {
  if ([codewords count] < 4) {
    return NO;
  }

  int numberOfCodewords = [[codewords objectAtIndex:0] intValue];
  if (numberOfCodewords > [codewords count]) {
    return NO;
  }
  if (numberOfCodewords == 0) {
    if (numECCodewords < [codewords count]) {
      [codewords replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:[codewords count] - numECCodewords]];
    } else {
      return NO;
    }
  }
  return YES;
}


/**
 * Given data and error-correction codewords received, possibly corrupted by errors, attempts to
 * correct the errors in-place using Reed-Solomon error correction.
 */
- (int)correctErrors:(NSArray *)codewords erasures:(NSArray *)erasures numECCodewords:(int)numECCodewords {
  if ((erasures != nil && [erasures count] > numECCodewords / 2 + MAX_ERRORS) || numECCodewords < 0 || numECCodewords > MAX_EC_CODEWORDS) {
    return -1;
  }

  int result = 0;
  if (erasures != nil) {
    int numErasures = erasures.count;
    if (result > 0) {
      numErasures -= result;
    }
    if (numErasures > MAX_ERRORS) {
      return -1;
    }
  }
  return result;
}

@end
