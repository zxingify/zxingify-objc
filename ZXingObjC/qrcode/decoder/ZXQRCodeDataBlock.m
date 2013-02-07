/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXErrorCorrectionLevel.h"
#import "ZXQRCodeDataBlock.h"
#import "ZXQRCodeVersion.h"

@interface ZXQRCodeDataBlock ()

@property (nonatomic, retain) NSMutableArray *codewords;
@property (nonatomic, assign) int numDataCodewords;

@end

@implementation ZXQRCodeDataBlock

@synthesize codewords;
@synthesize numDataCodewords;

- (id)initWithNumDataCodewords:(int)theNumDataCodewords codewords:(NSMutableArray *)theCodewords {
  if (self = [super init]) {
    self.numDataCodewords = theNumDataCodewords;
    self.codewords = theCodewords;
  }

  return self;
}

- (void)dealloc {
  [codewords release];

  [super dealloc];
}


/**
 * When QR Codes use multiple data blocks, they are actually interleaved.
 * That is, the first byte of data block 1 to n is written, then the second bytes, and so on. This
 * method will separate the data into original blocks.
 */
+ (NSArray *)dataBlocks:(NSArray *)rawCodewords version:(ZXQRCodeVersion *)version ecLevel:(ZXErrorCorrectionLevel *)ecLevel {
  if (rawCodewords.count != version.totalCodewords) {
    [NSException raise:NSInvalidArgumentException format:@"Invalid codewords count"];
  }

  ZXQRCodeECBlocks *ecBlocks = [version ecBlocksForLevel:ecLevel];

  int totalBlocks = 0;
  NSArray *ecBlockArray = ecBlocks.ecBlocks;
  for (ZXQRCodeECB *ecBlock in ecBlockArray) {
    totalBlocks += ecBlock.count;
  }

  NSMutableArray *result = [NSMutableArray arrayWithCapacity:totalBlocks];
  for (ZXQRCodeECB *ecBlock in ecBlockArray) {
    for (int i = 0; i < ecBlock.count; i++) {
      int numDataCodewords = ecBlock.dataCodewords;
      int numBlockCodewords = ecBlocks.ecCodewordsPerBlock + numDataCodewords;
      NSMutableArray *newCodewords = [NSMutableArray arrayWithCapacity:numBlockCodewords];
      for (int j = 0; j < numBlockCodewords; j++) {
        [newCodewords addObject:[NSNull null]];
      }

      [result addObject:[[[ZXQRCodeDataBlock alloc] initWithNumDataCodewords:numDataCodewords codewords:newCodewords] autorelease]];
    }
  }

  int shorterBlocksTotalCodewords = [[[result objectAtIndex:0] codewords] count];
  int longerBlocksStartAt = [result count] - 1;

  while (longerBlocksStartAt >= 0) {
    int numCodewords = [[[result objectAtIndex:longerBlocksStartAt] codewords] count];
    if (numCodewords == shorterBlocksTotalCodewords) {
      break;
    }
    longerBlocksStartAt--;
  }

  longerBlocksStartAt++;
  int shorterBlocksNumDataCodewords = shorterBlocksTotalCodewords - ecBlocks.ecCodewordsPerBlock;
  int rawCodewordsOffset = 0;
  int numResultBlocks = [result count];

  for (int i = 0; i < shorterBlocksNumDataCodewords; i++) {
    for (int j = 0; j < numResultBlocks; j++) {
      [[[result objectAtIndex:j] codewords] replaceObjectAtIndex:i withObject:[rawCodewords objectAtIndex:rawCodewordsOffset++]];
    }
  }

  for (int j = longerBlocksStartAt; j < numResultBlocks; j++) {
    [[[result objectAtIndex:j] codewords] replaceObjectAtIndex:shorterBlocksNumDataCodewords withObject:[rawCodewords objectAtIndex:rawCodewordsOffset++]];
  }

  int max = [[[result objectAtIndex:0] codewords] count];
  for (int i = shorterBlocksNumDataCodewords; i < max; i++) {
    for (int j = 0; j < numResultBlocks; j++) {
      int iOffset = j < longerBlocksStartAt ? i : i + 1;
      [[[result objectAtIndex:j] codewords] replaceObjectAtIndex:iOffset withObject:[rawCodewords objectAtIndex:rawCodewordsOffset++]];
    }
  }

  return result;
}

@end
