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

@interface ZXTestResult : NSObject

@property (nonatomic, readonly) int mustPassCount;
@property (nonatomic, readonly) int tryHarderCount;
@property (nonatomic, readonly) int maxMisreads;
@property (nonatomic, readonly) int maxTryHarderMisreads;
@property (nonatomic, readonly) float rotation;

- (id)initWithMustPassCount:(int)mustPassCount tryHarderCount:(int)tryHarderCount maxMisreads:(int)maxMisreads
       maxTryHarderMisreads:(int)maxTryHarderMisreads rotation:(float)rotation;

@end

