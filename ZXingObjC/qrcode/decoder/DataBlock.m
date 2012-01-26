#import "DataBlock.h"

@implementation DataBlock

- (id) init:(int)numDataCodewords codewords:(NSArray *)codewords {
  if (self = [super init]) {
    numDataCodewords = numDataCodewords;
    codewords = codewords;
  }
  return self;
}


/**
 * <p>When QR Codes use multiple data blocks, they are actually interleaved.
 * That is, the first byte of data block 1 to n is written, then the second bytes, and so on. This
 * method will separate the data into original blocks.</p>
 * 
 * @param rawCodewords bytes as read directly from the QR Code
 * @param version version of the QR Code
 * @param ecLevel error-correction level of the QR Code
 * @return DataBlocks containing original bytes, "de-interleaved" from representation in the
 * QR Code
 */
+ (NSArray *) getDataBlocks:(NSArray *)rawCodewords version:(Version *)version ecLevel:(ErrorCorrectionLevel *)ecLevel {
  if (rawCodewords.length != [version totalCodewords]) {
    @throw [[[IllegalArgumentException alloc] init] autorelease];
  }
  ECBlocks * ecBlocks = [version getECBlocksForLevel:ecLevel];
  int totalBlocks = 0;
  NSArray * ecBlockArray = [ecBlocks eCBlocks];

  for (int i = 0; i < ecBlockArray.length; i++) {
    totalBlocks += [ecBlockArray[i] count];
  }

  NSArray * result = [NSArray array];
  int numResultBlocks = 0;

  for (int j = 0; j < ecBlockArray.length; j++) {
    ECB * ecBlock = ecBlockArray[j];

    for (int i = 0; i < [ecBlock count]; i++) {
      int numDataCodewords = [ecBlock dataCodewords];
      int numBlockCodewords = [ecBlocks eCCodewordsPerBlock] + numDataCodewords;
      result[numResultBlocks++] = [[[DataBlock alloc] init:numDataCodewords param1:[NSArray array]] autorelease];
    }

  }

  int shorterBlocksTotalCodewords = result[0].codewords.length;
  int longerBlocksStartAt = result.length - 1;

  while (longerBlocksStartAt >= 0) {
    int numCodewords = result[longerBlocksStartAt].codewords.length;
    if (numCodewords == shorterBlocksTotalCodewords) {
      break;
    }
    longerBlocksStartAt--;
  }

  longerBlocksStartAt++;
  int shorterBlocksNumDataCodewords = shorterBlocksTotalCodewords - [ecBlocks eCCodewordsPerBlock];
  int rawCodewordsOffset = 0;

  for (int i = 0; i < shorterBlocksNumDataCodewords; i++) {

    for (int j = 0; j < numResultBlocks; j++) {
      result[j].codewords[i] = rawCodewords[rawCodewordsOffset++];
    }

  }


  for (int j = longerBlocksStartAt; j < numResultBlocks; j++) {
    result[j].codewords[shorterBlocksNumDataCodewords] = rawCodewords[rawCodewordsOffset++];
  }

  int max = result[0].codewords.length;

  for (int i = shorterBlocksNumDataCodewords; i < max; i++) {

    for (int j = 0; j < numResultBlocks; j++) {
      int iOffset = j < longerBlocksStartAt ? i : i + 1;
      result[j].codewords[iOffset] = rawCodewords[rawCodewordsOffset++];
    }

  }

  return result;
}

- (int) getNumDataCodewords {
  return numDataCodewords;
}

- (NSArray *) getCodewords {
  return codewords;
}

- (void) dealloc {
  [codewords release];
  [super dealloc];
}

@end
