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

#import "ZXRGBLuminanceSource.h"
#import "ZXRGBLuminanceSourceTestCase.h"

@implementation ZXRGBLuminanceSourceTestCase

static ZXRGBLuminanceSource *SOURCE = nil;

+ (void)initialize {
    int pixels[9] = {
        0x000000, 0x7F7F7F, 0xFFFFFF,
        0xFF0000, 0x00FF00, 0x0000FF,
        0x0000FF, 0x00FF00, 0xFF0000
    };
    SOURCE = [[ZXRGBLuminanceSource alloc] initWithWidth:3 height:3 pixels:pixels pixelsLen:sizeof(int32_t)];
}

- (void)testCrop {
    XCTAssertTrue([SOURCE cropSupported]);
    ZXLuminanceSource *crop = [SOURCE crop:1 top:1 width:1 height:1];
    XCTAssertEqual(1, crop.width);
    XCTAssertEqual(1, crop.height);
    ZXByteArray *row = [crop rowAtY:0 row:nil];
    XCTAssertEqual(0x7F, row.array[0]);
}

- (void)testMatrix {
  ZXByteArray *matrix = [SOURCE matrix];
  int8_t pixels[9] = {
    0x00, 0x7F, 0xFF, 0x3F, 0x7F, 0x3F, 0x3F, 0x7F, 0x3F
  };
  for (int i = 0; i < matrix.length; i++) {
    XCTAssertEqual(matrix.array[i], pixels[i]);
  }
}

- (void)testCropFullWidth {
  ZXLuminanceSource *croppedFullWidth = [SOURCE crop:0 top:1 width:3 height:2];
  ZXByteArray *matrix = [croppedFullWidth matrix];
  int8_t pixels[6] = {
    0x3F, 0x7F, 0x3F, 0x3F, 0x7F, 0x3F
  };
  for (int i = 0; i < matrix.length; i++) {
    XCTAssertEqual(matrix.array[i], pixels[i]);
  }
}

- (void)testCropCorner {
  ZXLuminanceSource *croppedCorner = [SOURCE crop:1 top:1 width:2 height:2];
  ZXByteArray *matrix = [croppedCorner matrix];
  int8_t pixels[4] = {
    0x7F, 0x3F, 0x7F, 0x3F
  };
  for (int i = 0; i < matrix.length; i++) {
    XCTAssertEqual(matrix.array[i], pixels[i]);
  }
}

- (void)testGetRow {
    ZXByteArray *row = [SOURCE rowAtY:2 row:nil];
    int8_t pixels[3] = {
        0x3F, 0x7F, 0x3F
    };
    for (int i = 0; i < row.length; i++) {
        XCTAssertEqual(row.array[i], pixels[i]);
    }
}

- (void)testDescription {
    XCTAssertEqualObjects(@"#+ \n#+#\n#+#\n", [SOURCE description]);
}

@end
