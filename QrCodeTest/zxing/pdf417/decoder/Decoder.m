#import "Decoder.h"

int const MAX_ERRORS = 3;
int const MAX_EC_CODEWORDS = 512;

@implementation Decoder

- (id) init {
  if (self = [super init]) {
  }
  return self;
}


/**
 * <p>Convenience method that can decode a PDF417 Code represented as a 2D array of booleans.
 * "true" is taken to mean a black module.</p>
 * 
 * @param image booleans representing white/black PDF417 modules
 * @return text and bytes encoded within the PDF417 Code
 * @throws NotFoundException if the PDF417 Code cannot be decoded
 */
- (DecoderResult *) decode:(NSArray *)image {
  int dimension = image.length;
  BitMatrix * bits = [[[BitMatrix alloc] init:dimension] autorelease];

  for (int i = 0; i < dimension; i++) {

    for (int j = 0; j < dimension; j++) {
      if (image[j][i]) {
        [bits set:j param1:i];
      }
    }

  }

  return [self decode:bits];
}


/**
 * <p>Decodes a PDF417 Code represented as a {@link BitMatrix}.
 * A 1 or "true" is taken to mean a black module.</p>
 * 
 * @param bits booleans representing white/black PDF417 Code modules
 * @return text and bytes encoded within the PDF417 Code
 * @throws FormatException if the PDF417 Code cannot be decoded
 */
- (DecoderResult *) decode:(BitMatrix *)bits {
  BitMatrixParser * parser = [[[BitMatrixParser alloc] init:bits] autorelease];
  NSArray * codewords = [parser readCodewords];
  if (codewords == nil || codewords.length == 0) {
    @throw [FormatException formatInstance];
  }
  int ecLevel = [parser eCLevel];
  int numECCodewords = 1 << (ecLevel + 1);
  NSArray * erasures = [parser erasures];
  [self correctErrors:codewords erasures:erasures numECCodewords:numECCodewords];
  [self verifyCodewordCount:codewords numECCodewords:numECCodewords];
  return [DecodedBitStreamParser decode:codewords];
}


/**
 * Verify that all is OK with the codeword array.
 * 
 * @param codewords
 * @return an index to the first data codeword.
 * @throws FormatException
 */
+ (void) verifyCodewordCount:(NSArray *)codewords numECCodewords:(int)numECCodewords {
  if (codewords.length < 4) {
    @throw [FormatException formatInstance];
  }
  int numberOfCodewords = codewords[0];
  if (numberOfCodewords > codewords.length) {
    @throw [FormatException formatInstance];
  }
  if (numberOfCodewords == 0) {
    if (numECCodewords < codewords.length) {
      codewords[0] = codewords.length - numECCodewords;
    }
     else {
      @throw [FormatException formatInstance];
    }
  }
}


/**
 * <p>Given data and error-correction codewords received, possibly corrupted by errors, attempts to
 * correct the errors in-place using Reed-Solomon error correction.</p>
 * 
 * @param codewords   data and error correction codewords
 * @throws ChecksumException if error correction fails
 */
+ (int) correctErrors:(NSArray *)codewords erasures:(NSArray *)erasures numECCodewords:(int)numECCodewords {
  if ((erasures != nil && erasures.length > numECCodewords / 2 + MAX_ERRORS) || numECCodewords < 0 || numECCodewords > MAX_EC_CODEWORDS) {
    @throw [FormatException formatInstance];
  }
  int result = 0;
  if (erasures != nil) {
    int numErasures = erasures.length;
    if (result > 0) {
      numErasures -= result;
    }
    if (numErasures > MAX_ERRORS) {
      @throw [FormatException formatInstance];
    }
  }
  return result;
}

@end
