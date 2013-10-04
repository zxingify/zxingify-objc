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

#import "ZXPDF417BoundingBox.h"
#import "ZXPDF417Codeword.h"
#import "ZXPDF417DetectionResultColumn.h"

int const MAX_NEARBY_DISTANCE = 5;

@interface ZXPDF417DetectionResultColumn ()

@property (nonatomic, strong) ZXPDF417BoundingBox *boundingBox;
@property (nonatomic, strong) NSMutableArray *codewords;

@end

@implementation ZXPDF417DetectionResultColumn

- (id)initWithBoundingBox:(ZXPDF417BoundingBox *)boundingBox {
  self = [super init];
  if (self) {
    _boundingBox = [[ZXPDF417BoundingBox alloc] initWithBoundingBox:boundingBox];
    _codewords = [NSMutableArray array];
    for (int i = 0; i < boundingBox.maxY - boundingBox.minY + 1; i++) {
      [_codewords addObject:[NSNull null]];
    }
  }

  return self;
}

- (ZXPDF417Codeword *)codewordNearby:(int)imageRow {
  ZXPDF417Codeword *codeword = [self codeword:imageRow];
  if (codeword) {
    return codeword;
  }
  for (int i = 1; i < MAX_NEARBY_DISTANCE; i++) {
    int nearImageRow = [self codewordsIndex:imageRow] - i;
    if (nearImageRow >= 0) {
      codeword = self.codewords[nearImageRow];
      if ((id)codeword != [NSNull null]) {
        return codeword;
      }
    }
    nearImageRow = [self codewordsIndex:imageRow] + i;
    if (nearImageRow < [self.codewords count]) {
      codeword = self.codewords[nearImageRow];
      if ((id)codeword != [NSNull null]) {
        return codeword;
      }
    }
  }
  return nil;
}

- (int)codewordsIndex:(int)imageRow {
  return imageRow - self.boundingBox.minY;
}

- (int)imageRow:(int)codewordIndex {
  return self.boundingBox.minY + codewordIndex;
}

- (void)setCodeword:(int)imageRow codeword:(ZXPDF417Codeword *)codeword {
  _codewords[[self codewordsIndex:imageRow]] = codeword;
}

- (ZXPDF417Codeword *)codeword:(int)imageRow {
  NSUInteger index = [self codewordsIndex:imageRow];
  if (_codewords[index] == [NSNull null]) {
    return nil;
  }
  return _codewords[index];
}

@end
