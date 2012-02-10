#import "DataMatrixDataBlock.h"
#import "DataMatrixVersion.h"

@implementation DataMatrixDataBlock

@synthesize codewords, numDataCodewords;

- (id) initWithNumDataCodewords:(int)theNumDataCodewords codewords:(NSMutableArray *)theCodewords {
  if (self = [super init]) {
    numDataCodewords = theNumDataCodewords;
    codewords = [theCodewords retain];
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
  ECBlocks * ecBlocks = [version ecBlocks];
  int totalBlocks = 0;
  NSArray * ecBlockArray = [ecBlocks ecBlocks];

  for (int i = 0; i < [ecBlockArray count]; i++) {
    totalBlocks += [[ecBlockArray objectAtIndex:i] count];
  }

  NSMutableArray * result = [NSMutableArray arrayWithCapacity:totalBlocks];
  int numResultBlocks = 0;

  for (ECB * ecBlock in ecBlockArray) {
    for (int i = 0; i < [ecBlock count]; i++) {
      int numDataCodewords = [ecBlock dataCodewords];
      int numBlockCodewords = [ecBlocks ecCodewords] + numDataCodewords;
      NSMutableArray *tempCodewords = [NSMutableArray arrayWithCapacity:numBlockCodewords];
      for (int j = 0; j < numBlockCodewords; j++) {
        [tempCodewords addObject:[NSNull null]];
      }
      [result addObject:[[[DataMatrixDataBlock alloc] initWithNumDataCodewords:numDataCodewords codewords:tempCodewords] autorelease]];
      numResultBlocks++;
    }
  }

  int longerBlocksTotalCodewords = [[[result objectAtIndex:0] codewords] count];
  int longerBlocksNumDataCodewords = longerBlocksTotalCodewords - [ecBlocks ecCodewords];
  int shorterBlocksNumDataCodewords = longerBlocksNumDataCodewords - 1;
  int rawCodewordsOffset = 0;

  for (int i = 0; i < shorterBlocksNumDataCodewords; i++) {
    for (int j = 0; j < numResultBlocks; j++) {
      [[[result objectAtIndex:j] codewords] replaceObjectAtIndex:i
                                                      withObject:[rawCodewords objectAtIndex:rawCodewordsOffset++]];
    }
  }

  BOOL specialVersion = [version versionNumber] == 24;
  int numLongerBlocks = specialVersion ? 8 : numResultBlocks;

  for (int j = 0; j < numLongerBlocks; j++) {
    [[[result objectAtIndex:j] codewords] replaceObjectAtIndex:longerBlocksNumDataCodewords - 1
                                                    withObject:[rawCodewords objectAtIndex:rawCodewordsOffset++]];
  }

  int max = [[[result objectAtIndex:0] codewords] count];

  for (int i = longerBlocksNumDataCodewords; i < max; i++) {
    for (int j = 0; j < numResultBlocks; j++) {
      int iOffset = specialVersion && j > 7 ? i - 1 : i;
      [[[result objectAtIndex:j] codewords] replaceObjectAtIndex:iOffset
                                                      withObject:[rawCodewords objectAtIndex:rawCodewordsOffset++]];
    }
  }

  if (rawCodewordsOffset != [rawCodewords count]) {
    [NSException raise:NSInvalidArgumentException 
                format:@"Codewords size mismatch"];
  }
  return result;
}

- (void) dealloc {
  [codewords release];
  [super dealloc];
}

@end
