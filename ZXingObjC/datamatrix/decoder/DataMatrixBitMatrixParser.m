#import "BitMatrix.h"
#import "DataMatrixBitMatrixParser.h"
#import "FormatException.h"
#import "QRCodeVersion.h"

@interface BitMatrixParser ()

- (QRCodeVersion *) readVersion:(BitMatrix *)bitMatrix;

@end

@implementation DataMatrixBitMatrixParser

@synthesize version;

/**
 * @param bitMatrix {@link BitMatrix} to parse
 * @throws FormatException if dimension is < 8 or > 144 or not 0 mod 2
 */
- (id) initWithBitMatrix:(BitMatrix *)bitMatrix {
  if (self = [super init]) {
    int dimension = [bitMatrix height];
    if (dimension < 8 || dimension > 144 || (dimension & 0x01) != 0) {
      @throw [FormatException formatInstance];
    }
    version = [self readVersion:bitMatrix];
    mappingBitMatrix = [self extractDataRegion:bitMatrix];
    readMappingMatrix = [[[BitMatrix alloc] initWithWidth:[mappingBitMatrix width]
                                                   height:[mappingBitMatrix height]] autorelease];
  }
  return self;
}

/**
 * <p>Creates the version object based on the dimension of the original bit matrix from 
 * the datamatrix code.</p>
 * 
 * <p>See ISO 16022:2006 Table 7 - ECC 200 symbol attributes</p>
 * 
 * @param bitMatrix Original {@link BitMatrix} including alignment patterns
 * @return {@link Version} encapsulating the Data Matrix Code's "version"
 * @throws FormatException if the dimensions of the mapping matrix are not valid
 * Data Matrix dimensions.
 */
- (QRCodeVersion *) readVersion:(BitMatrix *)bitMatrix {
  int numRows = [bitMatrix height];
  int numColumns = [bitMatrix width];
  return [QRCodeVersion getVersionForDimensions:numRows numColumns:numColumns];
}


/**
 * <p>Reads the bits in the {@link BitMatrix} representing the mapping matrix (No alignment patterns)
 * in the correct order in order to reconstitute the codewords bytes contained within the
 * Data Matrix Code.</p>
 * 
 * @return bytes encoded within the Data Matrix Code
 * @throws FormatException if the exact number of bytes expected is not read
 */
- (NSArray *) readCodewords {
  NSArray * result = [NSArray array];
  int resultOffset = 0;
  int row = 4;
  int column = 0;
  int numRows = [mappingBitMatrix height];
  int numColumns = [mappingBitMatrix width];
  BOOL corner1Read = NO;
  BOOL corner2Read = NO;
  BOOL corner3Read = NO;
  BOOL corner4Read = NO;

  do {
    if ((row == numRows) && (column == 0) && !corner1Read) {
      result[resultOffset++] = (char)[self readCorner1:numRows numColumns:numColumns];
      row -= 2;
      column += 2;
      corner1Read = YES;
    }
     else if ((row == numRows - 2) && (column == 0) && ((numColumns & 0x03) != 0) && !corner2Read) {
      result[resultOffset++] = (char)[self readCorner2:numRows numColumns:numColumns];
      row -= 2;
      column += 2;
      corner2Read = YES;
    }
     else if ((row == numRows + 4) && (column == 2) && ((numColumns & 0x07) == 0) && !corner3Read) {
      result[resultOffset++] = (char)[self readCorner3:numRows numColumns:numColumns];
      row -= 2;
      column += 2;
      corner3Read = YES;
    }
     else if ((row == numRows - 2) && (column == 0) && ((numColumns & 0x07) == 4) && !corner4Read) {
      result[resultOffset++] = (char)[self readCorner4:numRows numColumns:numColumns];
      row -= 2;
      column += 2;
      corner4Read = YES;
    }
     else {

      do {
        if ((row < numRows) && (column >= 0) && ![readMappingMatrix get:column param1:row]) {
          result[resultOffset++] = (char)[self readUtah:row column:column numRows:numRows numColumns:numColumns];
        }
        row -= 2;
        column += 2;
      }
       while ((row >= 0) && (column < numColumns));
      row += 1;
      column += 3;

      do {
        if ((row >= 0) && (column < numColumns) && ![readMappingMatrix get:column param1:row]) {
          result[resultOffset++] = (char)[self readUtah:row column:column numRows:numRows numColumns:numColumns];
        }
        row += 2;
        column -= 2;
      }
       while ((row < numRows) && (column >= 0));
      row += 3;
      column += 1;
    }
  }
   while ((row < numRows) || (column < numColumns));
  if (resultOffset != [version totalCodewords]) {
    @throw [FormatException formatInstance];
  }
  return result;
}


/**
 * <p>Reads a bit of the mapping matrix accounting for boundary wrapping.</p>
 * 
 * @param row Row to read in the mapping matrix
 * @param column Column to read in the mapping matrix
 * @param numRows Number of rows in the mapping matrix
 * @param numColumns Number of columns in the mapping matrix
 * @return value of the given bit in the mapping matrix
 */
- (BOOL) readModule:(int)row column:(int)column numRows:(int)numRows numColumns:(int)numColumns {
  if (row < 0) {
    row += numRows;
    column += 4 - ((numRows + 4) & 0x07);
  }
  if (column < 0) {
    column += numColumns;
    row += 4 - ((numColumns + 4) & 0x07);
  }
  [readMappingMatrix set:column param1:row];
  return [mappingBitMatrix get:column param1:row];
}


/**
 * <p>Reads the 8 bits of the standard Utah-shaped pattern.</p>
 * 
 * <p>See ISO 16022:2006, 5.8.1 Figure 6</p>
 * 
 * @param row Current row in the mapping matrix, anchored at the 8th bit (LSB) of the pattern
 * @param column Current column in the mapping matrix, anchored at the 8th bit (LSB) of the pattern
 * @param numRows Number of rows in the mapping matrix
 * @param numColumns Number of columns in the mapping matrix
 * @return byte from the utah shape
 */
- (int) readUtah:(int)row column:(int)column numRows:(int)numRows numColumns:(int)numColumns {
  int currentByte = 0;
  if ([self readModule:row - 2 column:column - 2 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:row - 2 column:column - 1 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:row - 1 column:column - 2 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:row - 1 column:column - 1 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:row - 1 column:column numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:row column:column - 2 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:row column:column - 1 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:row column:column numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  return currentByte;
}


/**
 * <p>Reads the 8 bits of the special corner condition 1.</p>
 * 
 * <p>See ISO 16022:2006, Figure F.3</p>
 * 
 * @param numRows Number of rows in the mapping matrix
 * @param numColumns Number of columns in the mapping matrix
 * @return byte from the Corner condition 1
 */
- (int) readCorner1:(int)numRows numColumns:(int)numColumns {
  int currentByte = 0;
  if ([self readModule:numRows - 1 column:0 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:numRows - 1 column:1 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:numRows - 1 column:2 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:0 column:numColumns - 2 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:0 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:1 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:2 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:3 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  return currentByte;
}


/**
 * <p>Reads the 8 bits of the special corner condition 2.</p>
 * 
 * <p>See ISO 16022:2006, Figure F.4</p>
 * 
 * @param numRows Number of rows in the mapping matrix
 * @param numColumns Number of columns in the mapping matrix
 * @return byte from the Corner condition 2
 */
- (int) readCorner2:(int)numRows numColumns:(int)numColumns {
  int currentByte = 0;
  if ([self readModule:numRows - 3 column:0 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:numRows - 2 column:0 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:numRows - 1 column:0 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:0 column:numColumns - 4 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:0 column:numColumns - 3 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:0 column:numColumns - 2 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:0 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:1 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  return currentByte;
}


/**
 * <p>Reads the 8 bits of the special corner condition 3.</p>
 * 
 * <p>See ISO 16022:2006, Figure F.5</p>
 * 
 * @param numRows Number of rows in the mapping matrix
 * @param numColumns Number of columns in the mapping matrix
 * @return byte from the Corner condition 3
 */
- (int) readCorner3:(int)numRows numColumns:(int)numColumns {
  int currentByte = 0;
  if ([self readModule:numRows - 1 column:0 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:numRows - 1 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:0 column:numColumns - 3 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:0 column:numColumns - 2 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:0 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:1 column:numColumns - 3 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:1 column:numColumns - 2 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:1 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  return currentByte;
}


/**
 * <p>Reads the 8 bits of the special corner condition 4.</p>
 * 
 * <p>See ISO 16022:2006, Figure F.6</p>
 * 
 * @param numRows Number of rows in the mapping matrix
 * @param numColumns Number of columns in the mapping matrix
 * @return byte from the Corner condition 4
 */
- (int) readCorner4:(int)numRows numColumns:(int)numColumns {
  int currentByte = 0;
  if ([self readModule:numRows - 3 column:0 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:numRows - 2 column:0 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:numRows - 1 column:0 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:0 column:numColumns - 2 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:0 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:1 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:2 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  currentByte <<= 1;
  if ([self readModule:3 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
    currentByte |= 1;
  }
  return currentByte;
}


/**
 * <p>Extracts the data region from a {@link BitMatrix} that contains
 * alignment patterns.</p>
 * 
 * @param bitMatrix Original {@link BitMatrix} with alignment patterns
 * @return BitMatrix that has the alignment patterns removed
 */
- (BitMatrix *) extractDataRegion:(BitMatrix *)bitMatrix {
  int symbolSizeRows = [version symbolSizeRows];
  int symbolSizeColumns = [version symbolSizeColumns];
  if ([bitMatrix height] != symbolSizeRows) {
    @throw [[[IllegalArgumentException alloc] init:@"Dimension of bitMarix must match the version size"] autorelease];
  }
  int dataRegionSizeRows = [version dataRegionSizeRows];
  int dataRegionSizeColumns = [version dataRegionSizeColumns];
  int numDataRegionsRow = symbolSizeRows / dataRegionSizeRows;
  int numDataRegionsColumn = symbolSizeColumns / dataRegionSizeColumns;
  int sizeDataRegionRow = numDataRegionsRow * dataRegionSizeRows;
  int sizeDataRegionColumn = numDataRegionsColumn * dataRegionSizeColumns;
  BitMatrix * bitMatrixWithoutAlignment = [[[BitMatrix alloc] init:sizeDataRegionColumn param1:sizeDataRegionRow] autorelease];

  for (int dataRegionRow = 0; dataRegionRow < numDataRegionsRow; ++dataRegionRow) {
    int dataRegionRowOffset = dataRegionRow * dataRegionSizeRows;

    for (int dataRegionColumn = 0; dataRegionColumn < numDataRegionsColumn; ++dataRegionColumn) {
      int dataRegionColumnOffset = dataRegionColumn * dataRegionSizeColumns;

      for (int i = 0; i < dataRegionSizeRows; ++i) {
        int readRowOffset = dataRegionRow * (dataRegionSizeRows + 2) + 1 + i;
        int writeRowOffset = dataRegionRowOffset + i;

        for (int j = 0; j < dataRegionSizeColumns; ++j) {
          int readColumnOffset = dataRegionColumn * (dataRegionSizeColumns + 2) + 1 + j;
          if ([bitMatrix get:readColumnOffset param1:readRowOffset]) {
            int writeColumnOffset = dataRegionColumnOffset + j;
            [bitMatrixWithoutAlignment set:writeColumnOffset param1:writeRowOffset];
          }
        }

      }

    }

  }

  return bitMatrixWithoutAlignment;
}

- (void) dealloc {
  [mappingBitMatrix release];
  [readMappingMatrix release];
  [version release];
  [super dealloc];
}

@end
