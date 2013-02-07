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

#import "ZXBarcodeRow.h"

@interface ZXBarcodeRow ()

@property (nonatomic, assign) int currentLocation;
@property (nonatomic, assign) unsigned char *row;
@property (nonatomic, assign) int rowLength;

@end

@implementation ZXBarcodeRow

@synthesize currentLocation;
@synthesize row;
@synthesize rowLength;

+ (ZXBarcodeRow *)barcodeRowWithWidth:(int)width {
  return [[[ZXBarcodeRow alloc] initWithWidth:width] autorelease];
}

- (id)initWithWidth:(int)width {
  if (self = [super init]) {
    self.rowLength = width;
    self.row = (unsigned char *)malloc(self.rowLength * sizeof(unsigned char));
    memset(self.row, 0, self.rowLength * sizeof(unsigned char));
    self.currentLocation = 0;
  }
  return self;
}

- (void)dealloc {
  if (self.row != NULL) {
    free(self.row);
    self.row = NULL;
  }

  [super dealloc];
}

- (void)setX:(int)x value:(unsigned char)value {
  self.row[x] = value;
}

- (void)setX:(int)x black:(BOOL)black {
  self.row[x] = (unsigned char)(black ? 1 : 0);
}

- (void)addBar:(BOOL)black width:(int)width {
  for (int ii = 0; ii < width; ii++) {
    [self setX:self.currentLocation++ black:black];
  }
}

- (unsigned char *)scaledRow:(int)scale {
  unsigned char *output = (unsigned char *)malloc(self.rowLength * scale);
  for (int i = 0; i < self.rowLength * scale; i++) {
    output[i] = row[i / scale];
  }
  return output;
}

@end
