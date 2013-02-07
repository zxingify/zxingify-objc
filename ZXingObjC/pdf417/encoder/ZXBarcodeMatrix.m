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

#import "ZXBarcodeMatrix.h"
#import "ZXBarcodeRow.h"

@interface ZXBarcodeMatrix ()

@property (nonatomic, assign) int currentRowIndex;
@property (nonatomic, assign) int height;
@property (nonatomic, retain) NSArray *rowMatrix;
@property (nonatomic, assign) int width;

@end

@implementation ZXBarcodeMatrix

@synthesize currentRowIndex;
@synthesize height;
@synthesize rowMatrix;
@synthesize width;

- (id)initWithHeight:(int)aHeight width:(int)aWidth {
  if (self = [super init]) {
    NSMutableArray *_matrix = [NSMutableArray array];
    for (int i = 0, matrixLength = aHeight + 2; i < matrixLength; i++) {
      [_matrix addObject:[ZXBarcodeRow barcodeRowWithWidth:(aWidth + 4) * 17 + 1]];
    }
    self.rowMatrix = _matrix;
    self.width = aWidth * 17;
    self.height = aHeight + 2;
    self.currentRowIndex = 0;
  }

  return self;
}

- (void)dealloc {
  [rowMatrix release];

  [super dealloc];
}

- (void)setX:(int)x y:(int)y value:(unsigned char)value {
  [[self.rowMatrix objectAtIndex:y] setX:x value:value];
}

- (void)setMatrixX:(int)x y:(int)y black:(BOOL)black {
  [self setX:x y:y value:(unsigned char)(black ? 1 : 0)];
}

- (void)startRow {
  ++self.currentRowIndex;
}

- (ZXBarcodeRow *)currentRow {
  return [self.rowMatrix objectAtIndex:self.currentRowIndex];
}

- (unsigned char **)matrixWithHeight:(int *)pHeight width:(int *)pWidth {
  return [self scaledMatrixWithHeight:pHeight width:pWidth xScale:1 yScale:1];
}

- (unsigned char **)scaledMatrixWithHeight:(int *)pHeight width:(int *)pWidth scale:(int)scale {
  return [self scaledMatrixWithHeight:pHeight width:pWidth xScale:scale yScale:scale];
}

- (unsigned char **)scaledMatrixWithHeight:(int *)pHeight width:(int *)pWidth xScale:(int)xScale yScale:(int)yScale {
  int matrixHeight = self.height * yScale;

  if (pHeight) *pHeight = matrixHeight;
  if (pWidth) *pWidth = (self.width + 69) * xScale;

  unsigned char **matrixOut = (unsigned char **)malloc(matrixHeight * sizeof(unsigned char *));
  int yMax = self.height * yScale;
  for (int ii = 0; ii < yMax; ii++) {
    matrixOut[yMax - ii - 1] = [[self.rowMatrix objectAtIndex:ii / yScale] scaledRow:xScale];
  }
  return matrixOut;
}

@end
