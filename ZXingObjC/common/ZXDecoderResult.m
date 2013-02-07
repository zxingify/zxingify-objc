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

#import "ZXDecoderResult.h"

@interface ZXDecoderResult ()

@property (nonatomic, assign) unsigned char *rawBytes;
@property (nonatomic, assign) int length;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) NSMutableArray *byteSegments;
@property (nonatomic, copy) NSString *ecLevel;

@end

@implementation ZXDecoderResult

@synthesize rawBytes;
@synthesize length;
@synthesize text;
@synthesize byteSegments;
@synthesize ecLevel;

- (id)initWithRawBytes:(unsigned char *)theRawBytes
                length:(unsigned int)aLength
                  text:(NSString *)theText
          byteSegments:(NSMutableArray *)theByteSegments
               ecLevel:(NSString *)anEcLevel {
  if (self = [super init]) {
    self.rawBytes = theRawBytes;
    self.length = aLength;
    self.text = theText;
    self.byteSegments = theByteSegments;
    self.ecLevel = anEcLevel;
  }

  return self;
}

- (void) dealloc {
  [text release];
  [byteSegments release];
  [ecLevel release];

  [super dealloc];
}

@end
