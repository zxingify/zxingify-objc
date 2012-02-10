#import "DataBlock.h"
#import "DataMatrixVersion.h"

@implementation DataBlock

- (id) init:(int)numDataCodewords codewords:(NSArray *)codewords {
  if (self = [super init]) {
    numDataCodewords = numDataCodewords;
    codewords = codewords;
  }
  return self;
}


/**
 * <p>When Data Matrix Codes use multiple data blocks, they actually interleave the bytes of each of them.
 * That is, the first byte of data block 1 to n is written, then the second bytes, and so on. This
 * method will separate the data into original blocks.</p>
 * 
 * @param rawCodewords bytes as read directly from the Data Matrix Code
 * @param version version of the Data Matrix Code
 * @return DataBlocks containing original bytes, "de-interleaved" from representation in the
 * Data Matrix Code
 */
+ (NSArray *) getDataBlocks:(NSArray *)rawCodewords version:(DataMatrixVersion *)version {
  ECBlocks * ecBlocks = [version eCBlocks];
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
      int numBlockCodewords = [ecBlocks eCCodewords] + numDataCodewords;
      result[numResultBlocks++] = [[[DataBlock alloc] init:numDataCodewords param1:[NSArray array]] autorelease];
    }

  }

  int longerBlocksTotalCodewords = result[0].codewords.length;
  int longerBlocksNumDataCodewords = longerBlocksTotalCodewords - [ecBlocks eCCodewords];
  int shorterBlocksNumDataCodewords = longerBlocksNumDataCodewords - 1;
  int rawCodewordsOffset = 0;

  for (int i = 0; i < shorterBlocksNumDataCodewords; i++) {

    for (int j = 0; j < numResultBlocks; j++) {
      result[j].codewords[i] = rawCodewords[rawCodewordsOffset++];
    }

  }

  BOOL specialVersion = [version versionNumber] == 24;
  int numLongerBlocks = specialVersion ? 8 : numResultBlocks;

  for (int j = 0; j < numLongerBlocks; j++) {
    result[j].codewords[longerBlocksNumDataCodewords - 1] = rawCodewords[rawCodewordsOffset++];
  }

  int max = result[0].codewords.length;

  for (int i = longerBlocksNumDataCodewords; i < max; i++) {

    for (int j = 0; j < numResultBlocks; j++) {
      int iOffset = specialVersion && j > 7 ? i - 1 : i;
      result[j].codewords[iOffset] = rawCodewords[rawCodewordsOffset++];
    }

  }

  if (rawCodewordsOffset != rawCodewords.length) {
    @throw [[[IllegalArgumentException alloc] init] autorelease];
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
