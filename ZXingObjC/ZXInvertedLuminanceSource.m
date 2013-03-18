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

#import "ZXInvertedLuminanceSource.h"

@implementation ZXInvertedLuminanceSource

- (id)initWithDelegate:(ZXLuminanceSource *)delegate {
  self = [super initWithWidth:delegate.width height:delegate.height];
  if (self) {
    _delegate = [delegate retain];
  }

  return self;
}

- (void)dealloc {
  [_delegate release];

  [super dealloc];
}

- (unsigned char *)row:(int)y {
  unsigned char *row = [_delegate row:y];
  for (int i = 0; i < self.width; i++) {
    row[i] = (unsigned char) (255 - (row[i] & 0xFF));
  }
  return row;
}

- (unsigned char *)matrix {
  unsigned char *matrix = [_delegate matrix];
  int length = self.width * self.height;
  unsigned char *invertedMatrix = (unsigned char *)malloc(length * sizeof(unsigned char));
  for (int i = 0; i < length; i++) {
    invertedMatrix[i] = (unsigned char) (255 - (matrix[i] & 0xFF));
  }
  free(matrix);
  return invertedMatrix;
}

- (BOOL)cropSupported {
  return _delegate.cropSupported;
}

- (ZXLuminanceSource *)crop:(int)left top:(int)top width:(int)aWidth height:(int)aHeight {
  return [[[ZXInvertedLuminanceSource alloc] initWithDelegate:[_delegate crop:left top:top width:aWidth height:aHeight]] autorelease];
}

- (BOOL)rotateSupported {
  return _delegate.rotateSupported;
}

/**
 * Returns original delegate ZXLuminanceSource since invert undoes itself
 */
- (ZXLuminanceSource *)invert {
  return _delegate;
}

- (ZXLuminanceSource *)rotateCounterClockwise {
  return [[[ZXInvertedLuminanceSource alloc] initWithDelegate:[_delegate rotateCounterClockwise]] autorelease];
}

- (ZXLuminanceSource *)rotateCounterClockwise45 {
  return [[[ZXInvertedLuminanceSource alloc] initWithDelegate:[_delegate rotateCounterClockwise45]] autorelease];
}

@end
