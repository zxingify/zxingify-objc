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

#import "ZXPDF417BarcodeMatrix.h"
#import "ZXPDF417BarcodeValue.h"

@interface ZXPDF417BarcodeMatrix ()

@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, assign) int maxRow;
@property (nonatomic, assign) int maxColumn;

@end

@implementation ZXPDF417BarcodeMatrix

- (id)init {
  self = [super init];
  if (self) {
    _values = [NSMutableDictionary dictionary];
    _maxRow = -1;
    _maxColumn = -1;
  }

  return self;
}

- (NSString *)key:(int)barcodeRow barcodeColumn:(int)barcodeColumn {
  return [NSString stringWithFormat:@"%d,%d", barcodeRow, barcodeColumn];
}

- (void)setValue:(int)row column:(int)column value:(int)value {
  self.maxRow = MAX(self.maxRow, row);
  self.maxColumn = MAX(self.maxColumn, column);
  NSString *key = [self key:row barcodeColumn:column];
  ZXPDF417BarcodeValue *barcodeValue = self.values[key];
  if (!barcodeValue) {
    barcodeValue = [[ZXPDF417BarcodeValue alloc] init];
    self.values[key] = barcodeValue;
  }
  [barcodeValue setValue:value];
}

- (NSNumber *)value:(int)row column:(int)column {
  ZXPDF417BarcodeValue *barcodeValue = self.values[[self key:row barcodeColumn:column]];
  if (!barcodeValue) {
    return nil;
  }
  return [barcodeValue value];
}

@end
