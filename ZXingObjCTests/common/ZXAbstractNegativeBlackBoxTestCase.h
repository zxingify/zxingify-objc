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

#import "ZXAbstractBlackBoxTestCase.h"

/**
 * This abstract class looks for negative results, i.e. it only allows a certain number of false
 * positives in images which should not decode. This helps ensure that we are not too lenient.
 */
@interface ZXAbstractNegativeBlackBoxTestCase : ZXAbstractBlackBoxTestCase

- (id)initWithInvocation:(NSInvocation *)invocation testBasePathSuffix:(NSString *)testBasePathSuffix;
- (void)addTest:(int)falsePositivesAllowed rotation:(float)rotation;
- (void)runTests;

@end
