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

#import "ZXTelParsedResult.h"

@interface ZXTelParsedResult ()

@property (nonatomic, copy) NSString *number;
@property (nonatomic, copy) NSString *telURI;
@property (nonatomic, copy) NSString *title;

@end

@implementation ZXTelParsedResult

@synthesize number;
@synthesize telURI;
@synthesize title;

- (id)initWithNumber:(NSString *)aNumber telURI:(NSString *)aTelURI title:(NSString *)aTitle {
  if (self = [super initWithType:kParsedResultTypeTel]) {
    self.number = aNumber;
    self.telURI = aTelURI;
    self.title = aTitle;
  }

  return self;
}

+ (id)telParsedResultWithNumber:(NSString *)number telURI:(NSString *)telURI title:(NSString *)title {
  return [[[self alloc] initWithNumber:number telURI:telURI title:title] autorelease];
}

- (void)dealloc {
  [number release];
  [telURI release];
  [title release];

  [super dealloc];
}

- (NSString *)displayResult {
  NSMutableString *result = [NSMutableString stringWithCapacity:20];
  [ZXParsedResult maybeAppend:number result:result];
  [ZXParsedResult maybeAppend:title result:result];
  return result;
}

@end
