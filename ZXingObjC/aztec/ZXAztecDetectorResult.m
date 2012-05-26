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

#import "ZXAztecDetectorResult.h"

@interface ZXAztecDetectorResult ()

@property(nonatomic, readwrite) int nbLayers;
@property(nonatomic, readwrite) int nbDatablocks;
@property(nonatomic, readwrite) BOOL compact;

@end

@implementation ZXAztecDetectorResult

@synthesize nbLayers;
@synthesize nbDatablocks;
@synthesize compact;

- (id)initWithBits:(ZXBitMatrix *)_bits points:(NSArray *)_points compact:(BOOL)_compact
      nbDatablocks:(int)_nbDatablocks nbLayers:(int)_nbLayers {
  if (self = [super initWithBits:_bits points:_points]) {
    self.compact = _compact;
    self.nbDatablocks = _nbDatablocks;
    self.nbLayers = _nbLayers;
  }

  return self;
}

@end
