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

- (void)testDescription {
    XCTAssertEqualObjects(@"#+ \n#+#\n#+#\n", [SOURCE description]);
}

@end
