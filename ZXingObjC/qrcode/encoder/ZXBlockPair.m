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

#import "ZXBlockPair.h"

@implementation ZXBlockPair

- (id)initWithData:(unsigned char *)data length:(unsigned int)length errorCorrection:(unsigned char *)errorCorrection errorCorrectionLength:(unsigned int)errorCorrectionLength {
  if (self = [super init]) {
    _dataBytes = (unsigned char *)malloc(length * sizeof(char));
    memcpy(_dataBytes, data, length * sizeof(char));
    _errorCorrectionBytes = (unsigned char *)malloc(errorCorrectionLength * sizeof(char));
    memcpy(_errorCorrectionBytes, errorCorrection, errorCorrectionLength);
    _length = length;
    _errorCorrectionLength = errorCorrectionLength;
  }

  return self;
}

- (void)dealloc {
  if (_dataBytes != NULL) {
    free(_dataBytes);
    _dataBytes = NULL;
  }

  if (_errorCorrectionBytes != NULL) {
    free(_errorCorrectionBytes);
    _errorCorrectionBytes = NULL;
  }
}

@end
