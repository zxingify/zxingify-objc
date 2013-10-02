/*
 * Copyright 2013 ZXing authors
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

#import "ZXBitMatrix.h"
#import "ZXLinesSampler.h"
#import "ZXPDF417BitMatrixParser.h"
#import "ZXPDF417Decoder.h"

const int BARS_IN_SYMBOL = 8;
const int BARCODE_START_OFFSET = 2;
static float RATIOS_TABLE[ZX_PDF417_SYMBOL_TABLE_LEN * BARS_IN_SYMBOL];
//static NSMutableArray *RATIOS_TABLE = nil;

@interface ZXVoteResult : NSObject

@property (nonatomic, assign) BOOL indecisive;
@property (nonatomic, assign) int vote;

@end

@implementation ZXVoteResult

@end

@interface ZXLinesSampler ()

@property (nonatomic, strong) ZXBitMatrix *linesMatrix;
@property (nonatomic, assign) int symbolsPerLine;
@property (nonatomic, assign) int dimension;

@end

@implementation ZXLinesSampler

+ (void)initialize {
  float table[ZX_PDF417_SYMBOL_TABLE_LEN][BARS_IN_SYMBOL];
  int x = 0;
  for (int i = 0; i < ZX_PDF417_SYMBOL_TABLE_LEN; i++) {
    int currentSymbol = SYMBOL_TABLE[i];
    int currentBit = currentSymbol & 0x1;
    for (int j = 0; j < BARS_IN_SYMBOL; j++) {
      float size = 0.0f;
      while ((currentSymbol & 0x1) == currentBit) {
        size += 1.0f;
        currentSymbol >>= 1;
      }
      currentBit = currentSymbol & 0x1;
      table[i][BARS_IN_SYMBOL - j - 1] = size / ZX_PDF_MODULES_IN_SYMBOL;
    }
    for (int j = 0; j < BARS_IN_SYMBOL; j++) {
      RATIOS_TABLE[x] = table[i][j];
      x++;
    }
  }
}

- (id)initWithLinesMatrix:(ZXBitMatrix *)linesMatrix dimension:(int)dimension {
  self = [super init];
  if (self) {
    _linesMatrix = linesMatrix;
    _symbolsPerLine = dimension / ZX_PDF_MODULES_IN_SYMBOL;
    _dimension = dimension;
  }

  return self;
}

/**
 * Samples a grid from a lines matrix.
 */
- (ZXBitMatrix *)sample {
  NSArray *symbolWidths = [self findSymbolWidths];

  int **codewords = (int **)malloc(self.linesMatrix.height * sizeof(int *));
  int **clusterNumbers = (int **)malloc(self.linesMatrix.height * sizeof(int *));
  if (![self linesMatrixToCodewords:codewords clusterNumbers:clusterNumbers symbolWidths:symbolWidths]) {
    return nil;
  }

  NSArray *votes = [self distributeVotes:codewords clusterNumbers:clusterNumbers];

  for (int i = 0; i < self.linesMatrix.height; i++) {
    free(codewords[i]);
    free(clusterNumbers[i]);
  }
  free(codewords);
  free(clusterNumbers);

  NSMutableArray *detectedCodeWords = [NSMutableArray array];
  [self resize3:detectedCodeWords size:votes.count];
  for (int i = 0; i < votes.count; i++) {
    [self resize4:detectedCodeWords[i] size:[votes[i] count]];
    for (int j = 0; j < [votes[i] count]; j++) {
      if ([votes[i][j] count] > 0) {
        detectedCodeWords[i][j] = @([self getValueWithMaxVotes:votes[i][j]].vote);
      }
    }
  }

  NSMutableArray *insertLinesAt = [self findMissingLines:detectedCodeWords];

  int rowCount = [self decodeRowCount:detectedCodeWords insertLinesAt:insertLinesAt];
  [self resize3:detectedCodeWords size:rowCount];

  return [self codewordsToBitMatrix:detectedCodeWords dimension:self.dimension yDimension:[detectedCodeWords count]];
}

/**
 * Use the following property of PDF417 barcodes to detect symbols:
 * Every symbol starts with a black module and every symbol is 17 modules
 * wide, therefore there have to be columns in the line matrix that are
 * completely composed of black pixels.
 */
- (NSArray *)findSymbolWidths {
  float expectedSymbolWidth;
  if (self.symbolsPerLine > 0) {
    expectedSymbolWidth = self.linesMatrix.width / (float) self.symbolsPerLine;
  } else {
    expectedSymbolWidth = self.linesMatrix.width;
  }

  NSMutableArray *symbolWidths = [NSMutableArray array];
  int symbolStart = 0;
  BOOL lastWasSymbolStart = YES;
  int *blackCount = (int *)malloc(self.linesMatrix.width * sizeof(int));
  memset(blackCount, 0, self.linesMatrix.width * sizeof(int));
  for (int x = BARCODE_START_OFFSET; x < self.linesMatrix.width; x++) {
    for (int y = 0; y < self.linesMatrix.height; y++) {
      if ([self.linesMatrix getX:x y:y]) {
        blackCount[x]++;
      }
    }
    if (blackCount[x] == self.linesMatrix.height) {
      if (!lastWasSymbolStart) {
        float currentWidth = x - symbolStart;
        // Make sure we really found a symbol by asserting a minimal size of
        // 75% of the expected symbol width. This might break highly distorted
        // barcodes, but fixes an issue with barcodes where there is a full black
        // column from top to bottom within a symbol.
        if (currentWidth > 0.75 * expectedSymbolWidth) {
          // The actual symbol width might be slightly bigger than the expected
          // symbol width, but if we are more than half an expected symbol width
          // bigger, we assume that  we missed one or more symbols and assume that
          // they were the expected symbol width.
          while (currentWidth > 1.5 * expectedSymbolWidth) {
            [symbolWidths addObject:@(expectedSymbolWidth)];
            currentWidth -= expectedSymbolWidth;
          }
          [symbolWidths addObject:@(currentWidth)];
          lastWasSymbolStart = YES;
          symbolStart = x;
        }
      }
    } else {
      if (lastWasSymbolStart) {
        lastWasSymbolStart = false;
      }
    }
  }
  free(blackCount);

  // The last symbol ends at the right edge of the matrix, where there usually is no black bar.
  float currentWidth = self.linesMatrix.width - symbolStart;
  while (currentWidth > 1.5 * expectedSymbolWidth) {
    [symbolWidths addObject:@(expectedSymbolWidth)];
    currentWidth -= expectedSymbolWidth;
  }
  [symbolWidths addObject:@(currentWidth)];

  return symbolWidths;
}

- (BOOL)linesMatrixToCodewords:(int **)codewords clusterNumbers:(int **)clusterNumbers symbolWidths:(NSArray *)symbolWidths {
  // Not sure if this is the right way to handle this but avoids an error:
  if (self.symbolsPerLine > symbolWidths.count) {
    return NO;
  }

  for (int y = 0; y < self.linesMatrix.height; y++) {
    codewords[y] = (int *)malloc(self.symbolsPerLine * sizeof(int));
    clusterNumbers[y] = (int *)malloc(self.symbolsPerLine * sizeof(int));
    memset(codewords[y], 0, self.symbolsPerLine);
    memset(clusterNumbers[y], 0, self.symbolsPerLine);
    NSMutableArray *barWidths = [NSMutableArray array];
    // Run-length encode the bars in the scanned linesMatrix.
    // We assume that the first bar is black, as determined by the PDF417 standard.
    // Filter small white bars at the beginning of the barcode.
    // Small white bars may occur due to small deviations in scan line sampling.
    [barWidths addObject:@(BARCODE_START_OFFSET)];
    BOOL isSetBar = YES;
    for (int x = BARCODE_START_OFFSET; x < self.linesMatrix.width; x++) {
      if ([self.linesMatrix getX:x y:y]) {
        if (!isSetBar) {
          isSetBar = YES;
          [barWidths addObject:@(0)];
        }
      } else {
        if (isSetBar) {
          isSetBar = NO;
          [barWidths addObject:@(0)];
        }

      }
      int lastIndex = barWidths.count - 1;
      barWidths[lastIndex] = @([barWidths[lastIndex] intValue] + 1);
    }

    // Find the symbols in the line by counting bar lengths until we reach symbolWidth.
    // We make sure, that the last bar of a symbol is always white, as determined by the PDF417 standard.
    // This helps to reduce the amount of errors done during the symbol recognition.
    // The symbolWidth usually is not constant over the width of the barcode.
    NSMutableArray *cwStarts = [NSMutableArray arrayWithCapacity:self.symbolsPerLine];
    for (int i = 0; i < self.symbolsPerLine; i++) {
      cwStarts[i] = @0;
    }
    int cwCount = 1;
    int cwWidth = 0;
    for (int i = 0; i < barWidths.count && cwCount < self.symbolsPerLine; i++) {
      cwWidth += [barWidths[i] intValue];
      if ((float)cwWidth > [symbolWidths[cwCount - 1] floatValue]) {
        if ((i % 2) == 1) { // check if bar is white
          i++;
        }
        if (i < barWidths.count) {
          cwWidth = [barWidths[i] intValue];
        }
        cwStarts[cwCount] = @(i);
        cwCount++;
      }
    }

    float **cwRatios = (float **)malloc(self.symbolsPerLine * sizeof(float *));
    for (int i = 0; i < self.symbolsPerLine; i++) {
      cwRatios[i] = (float *)malloc(BARS_IN_SYMBOL * sizeof(float));
      memset(cwRatios[i], 0, BARS_IN_SYMBOL);
    }
    // Distribute bar widths to modules of a codeword.
    for (int i = 0; i < self.symbolsPerLine; i++) {
      int cwStart = [cwStarts[i] intValue];
      int cwEnd = (i == self.symbolsPerLine - 1) ? barWidths.count : [cwStarts[i + 1] intValue];
      int cwLength = cwEnd - cwStart;

      if (cwLength < 7 || cwLength > 9) {
        // We try to recover symbols with 7 or 9 bars and spaces with heuristics, but everything else is beyond repair.
        continue;
      }

      // For symbols with 9 bar length simply ignore the last bar.
      float cwWidthF = 0.0f;
      for (int j = 0; j < MIN(BARS_IN_SYMBOL, cwLength); ++j) {
        cwWidthF += [barWidths[cwStart + j] floatValue];
      }

      // If there were only 7 bars and spaces detected use the following heuristic:
      // Assume the length of the symbol is symbolWidth and the last (unrecognized) bar uses all remaining space.
      if (cwLength == 7) {
        for (int j = 0; j < cwLength; ++j) {
          cwRatios[i][j] = [barWidths[cwStart + j] floatValue] / [symbolWidths[i] floatValue];
        }
        cwRatios[i][7] = ([symbolWidths[i] floatValue] - cwWidthF) / [symbolWidths[i] floatValue];
      } else {
        for (int j = 0; j < BARS_IN_SYMBOL; ++j) {
          cwRatios[i][j] = [barWidths[cwStart + j] floatValue] / cwWidthF;
        }
      }

      float bestMatchError = MAXFLOAT;
      int bestMatch = 0;

      // Search for the most possible codeword by comparing the ratios of bar size to symbol width.
      // The sum of the squared differences is used as similarity metric.
      // (Picture it as the square euclidian distance in the space of eight tuples where a tuple represents the bar ratios.)
      for (int j = 0; j < ZX_PDF417_SYMBOL_TABLE_LEN; j++) {
        float error = 0.0f;
        for (int k = 0; k < BARS_IN_SYMBOL; k++) {
          float diff = RATIOS_TABLE[j * BARS_IN_SYMBOL + k] - cwRatios[i][k];
          error += diff * diff;
        }
        if (error < bestMatchError) {
          bestMatchError = error;
          bestMatch = SYMBOL_TABLE[j];
        }
      }
      codewords[y][i] = bestMatch;
      clusterNumbers[y][i] = [self calculateClusterNumber:bestMatch];
    }
    for (int i = 0; i < self.symbolsPerLine; i++) {
      free(cwRatios[i]);
    }
    free(cwRatios);
  }

  return YES;
}

- (NSArray *)distributeVotes:(int **)codewords clusterNumbers:(int **)clusterNumbers {
  // Matrix of votes for codewords which are possible at this position.
  NSMutableArray *votes = [NSMutableArray array];
  [votes addObject:[NSMutableArray array]];
  [self resize2:votes[0] size:self.symbolsPerLine];

  int currentRow = 0;
  NSMutableDictionary *clusterNumberVotes = [NSMutableDictionary dictionary];
  int lastLineClusterNumber = -1;

  for (int y = 0; y < self.linesMatrix.height; y++) {
    // Vote for the most probable cluster number for this row.
    [clusterNumberVotes removeAllObjects];
    for (int i = 0; i < self.symbolsPerLine; i++) {
      if (clusterNumbers[y][i] != -1) {
        clusterNumberVotes[@(clusterNumbers[y][i])] = @([self defaultValue:clusterNumberVotes[@(clusterNumbers[y][i])] d:0] + 1);
      }
    }

    // Ignore lines where no codeword could be read.
    if ([clusterNumberVotes count] > 0) {
      ZXVoteResult *voteResult = [self getValueWithMaxVotes:clusterNumberVotes];
      BOOL lineClusterNumberIsIndecisive = voteResult.indecisive;
      int lineClusterNumber = voteResult.vote;

      // If there are to few votes on the lines cluster number, we keep the old one.
      // This avoids switching lines because of damaged inter line readings, but
      // may cause problems for barcodes with four or less rows.
      if (lineClusterNumberIsIndecisive) {
        lineClusterNumber = lastLineClusterNumber;
      }

      if ((lineClusterNumber != ((lastLineClusterNumber + 3) % 9)) && (lastLineClusterNumber != -1)) {
        lineClusterNumber = lastLineClusterNumber;
      }

      // Ignore broken lines at the beginning of the barcode.
      if ((lineClusterNumber == 0 && lastLineClusterNumber == -1) || (lastLineClusterNumber != -1)) {
        if ((lineClusterNumber == ((lastLineClusterNumber + 3) % 9)) && (lastLineClusterNumber != -1)) {
          currentRow++;
          if ([votes count] < currentRow + 1) {
            [self resize1:votes size:currentRow + 1];
            [self resize2:votes[currentRow] size:self.symbolsPerLine];
          }
        }

        if ((lineClusterNumber == ((lastLineClusterNumber + 6) % 9)) && (lastLineClusterNumber != -1)) {
          currentRow += 2;
          if ([votes count] < currentRow + 1) {
            [self resize1:votes size:currentRow + 1];
            [self resize2:votes[currentRow] size:self.symbolsPerLine];
          }
        }

        for (int i = 0; i < self.symbolsPerLine; i++) {
          if (clusterNumbers[y][i] != -1) {
            if (clusterNumbers[y][i] == lineClusterNumber) {
              NSMutableDictionary *votesMap = votes[currentRow][i];
              votesMap[@(codewords[y][i])] = @([self defaultValue:votesMap[@(codewords[y][i])] d:0] + 1);
            } else if (clusterNumbers[y][i] == ((lineClusterNumber + 3) % 9)) {
              if ([votes count] < currentRow + 2) {
                [self resize1:votes size:currentRow + 2];
                [self resize2:votes[currentRow + 1] size:self.symbolsPerLine];
              }
              NSMutableDictionary *votesMap = votes[currentRow + 1][i];
              votesMap[@(codewords[y][i])] = @([self defaultValue:votesMap[@(codewords[y][i])] d:0] + 1);
            } else if ((clusterNumbers[y][i] == ((lineClusterNumber + 6) % 9)) && (currentRow > 0)) {
              NSMutableDictionary *votesMap = votes[currentRow - 1][i];
              votesMap[@(codewords[y][i])] = @([self defaultValue:votesMap[@(codewords[y][i])] d:0] + 1);
            }
          }
        }
        lastLineClusterNumber = lineClusterNumber;
      }
    }
  }

  return votes;
}

- (NSMutableArray *)findMissingLines:(NSMutableArray *)detectedCodeWords {
  NSMutableArray *insertLinesAt = [NSMutableArray array];
  if ([detectedCodeWords count] > 1) {
    for (int i = 0; i < [detectedCodeWords count] - 1; i++) {
      int clusterNumberRow = -1;
      for (int j = 0; j < [detectedCodeWords[i] count] && clusterNumberRow == -1; j++) {
        int clusterNumber = [self calculateClusterNumber:[detectedCodeWords[i][j] intValue]];
        if (clusterNumber != -1) {
          clusterNumberRow = clusterNumber;
        }
      }
      if (i == 0) {
        // The first line must have the cluster number 0. Insert empty lines to match this.
        if (clusterNumberRow > 0) {
          [insertLinesAt addObject:@0];
          if (clusterNumberRow > 3) {
            [insertLinesAt addObject:@0];
          }
        }
      }
      int clusterNumberNextRow = -1;
      for (int j = 0; j < [detectedCodeWords[i + 1] count] && clusterNumberNextRow == -1; j++) {
        int clusterNumber = [self calculateClusterNumber:[detectedCodeWords[i + 1][j] intValue]];
        if (clusterNumber != -1) {
          clusterNumberNextRow = clusterNumber;
        }
      }
      if ((clusterNumberRow + 3) % 9 != clusterNumberNextRow
          && clusterNumberRow != -1
          && clusterNumberNextRow != -1) {
        // The cluster numbers are not consecutive. Insert an empty line between them.
        [insertLinesAt addObject:@(i + 1)];
        if (clusterNumberRow == clusterNumberNextRow) {
          // There may be two lines missing. This is detected when two consecutive lines have the same cluster number.
          [insertLinesAt addObject:@(i + 1)];
        }
      }
    }
  }

  for (int i = 0; i < [insertLinesAt count]; i++) {
    NSMutableArray *v = [NSMutableArray array];
    for (int j = 0; j < self.symbolsPerLine; ++j) {
      [v addObject:@(0)];
    }
    [detectedCodeWords insertObject:v atIndex:[insertLinesAt[i] intValue] + i];
  }

  return insertLinesAt;
}

- (int)decodeRowCount:(NSMutableArray *)detectedCodeWords insertLinesAt:(NSMutableArray *)insertLinesAt {
  // Use the information in the first and last column to determin the number of rows and find more missing rows.
  // For missing rows insert blank space, so the error correction can try to fill them in.

  [insertLinesAt removeAllObjects];
  NSMutableDictionary *rowCountVotes = [NSMutableDictionary dictionary];
  NSMutableDictionary *ecLevelVotes = [NSMutableDictionary dictionary];
  NSMutableDictionary *rowNumberVotes = [NSMutableDictionary dictionary];
  int lastRowNumber = -1;

  for (int i = 0; i + 2 < [detectedCodeWords count]; i += 3) {
    [rowNumberVotes removeAllObjects];
    int firstCodewordDecodedLeft = -1;
    if ([detectedCodeWords[i][0] intValue] != 0) {
      firstCodewordDecodedLeft = [ZXPDF417BitMatrixParser codeword:[detectedCodeWords[i][0] intValue]];
    }
    int secondCodewordDecodedLeft = -1;
    if ([detectedCodeWords[i + 1][0] intValue] != 0) {
      secondCodewordDecodedLeft = [ZXPDF417BitMatrixParser codeword:[detectedCodeWords[i + 1][0] intValue]];
    }
    int thirdCodewordDecodedLeft = -1;
    if ([detectedCodeWords[i + 2][0] intValue] != 0) {
      thirdCodewordDecodedLeft = [ZXPDF417BitMatrixParser codeword:[detectedCodeWords[i + 2][0] intValue]];
    }

    int firstCodewordDecodedRight = -1;
    if ([detectedCodeWords[i][[detectedCodeWords[i] count] - 1] intValue] != 0) {
      firstCodewordDecodedRight = [ZXPDF417BitMatrixParser codeword:[detectedCodeWords[i][[detectedCodeWords[i] count] - 1] intValue]];
    }
    int secondCodewordDecodedRight = -1;
    if ([detectedCodeWords[i + 1][[detectedCodeWords[i + 1] count] - 1] intValue] != 0) {
      secondCodewordDecodedRight = [ZXPDF417BitMatrixParser codeword:[detectedCodeWords[i + 1][[detectedCodeWords[i + 1] count] - 1] intValue]];
    }
    int thirdCodewordDecodedRight = -1;
    if ([detectedCodeWords[i + 2][[detectedCodeWords[i + 2] count] - 1] intValue] != 0) {
      thirdCodewordDecodedRight = [ZXPDF417BitMatrixParser codeword:[detectedCodeWords[i + 2][[detectedCodeWords[i + 2] count] - 1] intValue]];
    }

    if (firstCodewordDecodedLeft != -1 && secondCodewordDecodedLeft != -1) {
      int leftRowCount = ((firstCodewordDecodedLeft % 30) * 3) + ((secondCodewordDecodedLeft % 30) % 3);
      int leftECLevel = (secondCodewordDecodedLeft % 30) / 3;

      rowCountVotes[@(leftRowCount)] = @([self defaultValue:rowCountVotes[@(leftRowCount)] d:0] + 1);
      ecLevelVotes[@(leftECLevel)] = @([self defaultValue:ecLevelVotes[@(leftECLevel)] d:0] + 1);
    }

    if (secondCodewordDecodedRight != -1 && thirdCodewordDecodedRight != -1) {
      int rightRowCount = ((secondCodewordDecodedRight % 30) * 3) + ((thirdCodewordDecodedRight % 30) % 3);
      int rightECLevel = (thirdCodewordDecodedRight % 30) / 3;

      rowCountVotes[@(rightRowCount)] = @([self defaultValue:rowCountVotes[@(rightRowCount)] d:0] + 1);
      ecLevelVotes[@(rightECLevel)] = @([self defaultValue:ecLevelVotes[@(rightECLevel)] d:0] + 1);
    }

    if (firstCodewordDecodedLeft != -1) {
      int rowNumber = firstCodewordDecodedLeft / 30;
      rowNumberVotes[@(rowNumber)] = @([self defaultValue:rowNumberVotes[@(rowNumber)] d:0] + 1);
    }
    if (secondCodewordDecodedLeft != -1) {
      int rowNumber = secondCodewordDecodedLeft / 30;
      rowNumberVotes[@(rowNumber)] = @([self defaultValue:rowNumberVotes[@(rowNumber)] d:0] + 1);
    }
    if (thirdCodewordDecodedLeft != -1) {
      int rowNumber = thirdCodewordDecodedLeft / 30;
      rowNumberVotes[@(rowNumber)] = @([self defaultValue:rowNumberVotes[@(rowNumber)] d:0] + 1);
    }
    if (firstCodewordDecodedRight != -1) {
      int rowNumber = firstCodewordDecodedRight / 30;
      rowNumberVotes[@(rowNumber)] = @([self defaultValue:rowNumberVotes[@(rowNumber)] d:0] + 1);
    }
    if (secondCodewordDecodedRight != -1) {
      int rowNumber = secondCodewordDecodedRight / 30;
      rowNumberVotes[@(rowNumber)] = @([self defaultValue:rowNumberVotes[@(rowNumber)] d:0] + 1);
    }
    if (thirdCodewordDecodedRight != -1) {
      int rowNumber = thirdCodewordDecodedRight / 30;
      rowNumberVotes[@(rowNumber)] = @([self defaultValue:rowNumberVotes[@(rowNumber)] d:0] + 1);
    }
    int rowNumber = [self getValueWithMaxVotes:rowNumberVotes].vote;
    if (lastRowNumber + 1 < rowNumber) {
      for (int j = lastRowNumber + 1; j < rowNumber; j++) {
        [insertLinesAt addObject:@(i)];
        [insertLinesAt addObject:@(i)];
        [insertLinesAt addObject:@(i)];
      }
    }
    lastRowNumber = rowNumber;
  }

  for (int i = 0; i < [insertLinesAt count]; i++) {
    NSMutableArray *v = [NSMutableArray array];
    for (int j = 0; j < self.symbolsPerLine; ++j) {
      [v addObject:@(0)];
    }
    [detectedCodeWords insertObject:v atIndex:[insertLinesAt[i] intValue] + i];
  }

  int rowCount = [self getValueWithMaxVotes:rowCountVotes].vote;
  //int ecLevel = getValueWithMaxVotes(ecLevelVotes).getVote();

  rowCount += 1;
  return rowCount;
}

- (ZXVoteResult *)getValueWithMaxVotes:(NSDictionary *)votes {
  ZXVoteResult *result = [[ZXVoteResult alloc] init];
  int maxVotes = 0;
  for (NSNumber *key in votes) {
    int value = [votes[key] intValue];
    if (value > maxVotes) {
      maxVotes = value;
      result.vote = [key intValue];
      result.indecisive = NO;
    } else if (value == maxVotes) {
      result.indecisive = YES;
    }
  }
  return result;
}

- (ZXBitMatrix *)codewordsToBitMatrix:(NSArray *)codewords dimension:(int)dimension yDimension:(int)yDimension {
  ZXBitMatrix *result = [[ZXBitMatrix alloc] initWithWidth:dimension height:yDimension];
  for (int i = 0; i < [codewords count]; i++) {
    for (int j = 0; j < [codewords[i] count]; j++) {
      int moduleOffset = j * ZX_PDF_MODULES_IN_SYMBOL;
      for (int k = 0; k < ZX_PDF_MODULES_IN_SYMBOL; k++) {
        if (([codewords[i][j] intValue] & (1 << (ZX_PDF_MODULES_IN_SYMBOL - k - 1))) > 0) {
          [result setX:moduleOffset + k y:i];
        }
      }
    }
  }
  return result;
}

- (int)calculateClusterNumber:(int)codeword {
  if (codeword == 0) {
    return -1;
  }
  int barNumber = 0;
  BOOL blackBar = YES;
  int clusterNumber = 0;
  for (int i = 0; i < ZX_PDF_MODULES_IN_SYMBOL; i++) {
    if ((codeword & (1 << i)) > 0) {
      if (!blackBar) {
        blackBar = YES;
        barNumber++;
      }
      if (barNumber % 2 == 0) {
        clusterNumber++;
      } else {
        clusterNumber--;
      }
    } else {
      if (blackBar) {
        blackBar = NO;
      }
    }
  }
  return (clusterNumber + 9) % 9;
}

- (void)resize1:(NSMutableArray *)list size:(int)size {
  // Delete some
  for (int i = size; i < [list count]; i++) {
    [list removeObjectAtIndex:i];
  }
  // Append some.
  for (int i = [list count]; i < size; i++) {
    [list addObject:[NSMutableArray array]];
  }
}

- (void)resize2:(NSMutableArray *)list size:(int)size {
  // Delete some
  for (int i = size; i < [list count]; i++) {
    [list removeObjectAtIndex:i];
  }
  // Append some.
  for (int i = [list count]; i < size; i++) {
    [list addObject:[NSMutableDictionary dictionary]];
  }
}

- (void)resize3:(NSMutableArray *)list size:(int)size {
  // Delete some
  for (int i = size; i < [list count]; i++) {
    [list removeObjectAtIndex:i];
  }
  // Append some.
  for (int i = [list count]; i < size; i++) {
    [list addObject:[NSMutableArray array]];
  }
}

- (void)resize4:(NSMutableArray *)list size:(int)size {
  // Delete some
  for (int i = size; i < [list count]; i++) {
    [list removeObjectAtIndex:i];
  }
  // Append some.
  for (int i = [list count]; i < size; i++) {
    [list addObject:@0];
  }
}

- (int)defaultValue:(NSNumber *)value d:(int)d {
  return value == nil ? d : [value intValue];
}

@end
