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

#import "ZXPerspectiveTransformTestCase.h"

@implementation ZXPerspectiveTransformTestCase

static float EPSILON = 0.0001f;

- (void)testSquareToQuadrilateral {
  ZXPerspectiveTransform *pt = [ZXPerspectiveTransform squareToQuadrilateral:2.0f y0:3.0f
                                                                          x1:10.0f y1:4.0f
                                                                          x2:16.0f y2:15.0f
                                                                          x3:4.0f y3:9.0f];
  [self assertPointEqualsExpectedX:2.0f expectedY:3.0f sourceX:0.0f sourceY:0.0f pt:pt];
  [self assertPointEqualsExpectedX:10.0f expectedY:4.0f sourceX:1.0f sourceY:0.0f pt:pt];
  [self assertPointEqualsExpectedX:4.0f expectedY:9.0f sourceX:0.0f sourceY:1.0f pt:pt];
  [self assertPointEqualsExpectedX:16.0f expectedY:15.0f sourceX:1.0f sourceY:1.0f pt:pt];
  [self assertPointEqualsExpectedX:6.535211f expectedY:6.8873234f sourceX:0.5f sourceY:0.5f pt:pt];
  [self assertPointEqualsExpectedX:48.0f expectedY:42.42857f sourceX:1.5f sourceY:1.5f pt:pt];
}

- (void)testQuadrilateralToQuadrilateral {
  ZXPerspectiveTransform *pt = [ZXPerspectiveTransform quadrilateralToQuadrilateral:2.0f y0:3.0f
                                                                                 x1:10.0f y1:4.0f
                                                                                 x2:16.0f y2:15.0f
                                                                                 x3:4.0f y3:9.0f
                                                                                x0p:103.0f y0p:110.0f
                                                                                x1p:300.0f y1p:120.0f
                                                                                x2p:290.0f y2p:270.0f
                                                                                x3p:150.0f y3p:280.0f];
  [self assertPointEqualsExpectedX:103.0f expectedY:110.0f sourceX:2.0f sourceY:3.0f pt:pt];
  [self assertPointEqualsExpectedX:300.0f expectedY:120.0f sourceX:10.0f sourceY:4.0f pt:pt];
  [self assertPointEqualsExpectedX:290.0f expectedY:270.0f sourceX:16.0f sourceY:15.0f pt:pt];
  [self assertPointEqualsExpectedX:150.0f expectedY:280.0f sourceX:4.0f sourceY:9.0f pt:pt];
  [self assertPointEqualsExpectedX:7.1516876f expectedY:-64.60185f sourceX:0.5f sourceY:0.5f pt:pt];
  [self assertPointEqualsExpectedX:328.09116f expectedY:334.16385f sourceX:50.0f sourceY:50.0f pt:pt];
}

- (void)assertPointEqualsExpectedX:(float)expectedX
                         expectedY:(float)expectedY
                           sourceX:(float)sourceX
                           sourceY:(float)sourceY
                                pt:(ZXPerspectiveTransform *)pt {
  float points[2] = {sourceX, sourceY};
  [pt transformPoints:points pointsLen:2];
  XCTAssertEqualWithAccuracy(expectedX, points[0], EPSILON);
  XCTAssertEqualWithAccuracy(expectedY, points[1], EPSILON);
}

@end
