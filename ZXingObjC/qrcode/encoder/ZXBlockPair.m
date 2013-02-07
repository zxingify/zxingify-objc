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

@interface ZXBlockPair ()

@property (nonatomic, assign) unsigned char *dataBytes;
@property (nonatomic, assign) unsigned char *errorCorrectionBytes;
@property (nonatomic, assign) int errorCorrectionLength;
@property (nonatomic, assign) int length;

@end

@implementation ZXBlockPair

@synthesize dataBytes;
@synthesize errorCorrectionBytes;
@synthesize errorCorrectionLength;
@synthesize length;

- (id)initWithData:(unsigned char *)data length:(unsigned int)aLength errorCorrection:(unsigned char *)errorCorrection errorCorrectionLength:(unsigned int)anErrorCorrectionLength{
  if (self = [super init]) {
    self.dataBytes = (unsigned char *)malloc(aLength * sizeof(char));
    memcpy(self.dataBytes, data, aLength * sizeof(char));
    self.errorCorrectionBytes = (unsigned char *)malloc(anErrorCorrectionLength * sizeof(char));
    memcpy(self.errorCorrectionBytes, errorCorrection, anErrorCorrectionLength);
    self.length = aLength;
    self.errorCorrectionLength = anErrorCorrectionLength;
  }

  return self;
}

- (void)dealloc {
  if (self.dataBytes != NULL) {
    free(self.dataBytes);
    self.dataBytes = NULL;
  }

  if (self.errorCorrectionBytes != NULL) {
    free(self.errorCorrectionBytes);
    self.errorCorrectionBytes = NULL;
  }

  [super dealloc];
}

@end
