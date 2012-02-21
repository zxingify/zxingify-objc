#import "BitArray.h"
#import "BitArrayBuilder.h"
#import "DataCharacter.h"
#import "ExpandedPair.h"

@implementation BitArrayBuilder

+ (BitArray *) buildBitArray:(NSMutableArray *)pairs {
  int charNumber = ([pairs count] << 1) - 1;
  if ([((ExpandedPair *)[pairs lastObject]) rightChar] == nil) {
    charNumber -= 1;
  }

  int size = 12 * charNumber;

  BitArray * binary = [[[BitArray alloc] initWithSize:size] autorelease];
  int accPos = 0;

  ExpandedPair * firstPair = (ExpandedPair *)[pairs objectAtIndex:0];
  int firstValue = [[firstPair rightChar] value];
  for (int i = 11; i >= 0; --i) {
    if ((firstValue & (1 << i)) != 0) {
      [binary set:accPos];
    }
    accPos++;
  }

  for (int i = 1; i < [pairs count]; ++i) {
    ExpandedPair * currentPair = (ExpandedPair *)[pairs objectAtIndex:i];
    int leftValue = [[currentPair leftChar] value];

    for (int j = 11; j >= 0; --j) {
      if ((leftValue & (1 << j)) != 0) {
        [binary set:accPos];
      }
      accPos++;
    }

    if ([currentPair rightChar] != nil) {
      int rightValue = [[currentPair rightChar] value];

      for (int j = 11; j >= 0; --j) {
        if ((rightValue & (1 << j)) != 0) {
          [binary set:accPos];
        }
        accPos++;
      }
    }
  }

  return binary;
}

@end
