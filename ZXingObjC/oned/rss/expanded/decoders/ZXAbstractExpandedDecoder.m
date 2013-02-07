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

#import "ZXAbstractExpandedDecoder.h"
#import "ZXAI013103decoder.h"
#import "ZXAI01320xDecoder.h"
#import "ZXAI01392xDecoder.h"
#import "ZXAI01393xDecoder.h"
#import "ZXAI013x0x1xDecoder.h"
#import "ZXAI01AndOtherAIs.h"
#import "ZXAnyAIDecoder.h"
#import "ZXBitArray.h"
#import "ZXGeneralAppIdDecoder.h"

@interface ZXAbstractExpandedDecoder ()

@property (nonatomic, retain) ZXGeneralAppIdDecoder *generalDecoder;
@property (nonatomic, retain) ZXBitArray *information;

@end

@implementation ZXAbstractExpandedDecoder

@synthesize generalDecoder;
@synthesize information;

- (id)initWithInformation:(ZXBitArray *)anInformation {
  if (self = [super init]) {
    self.information = anInformation;
    self.generalDecoder = [[[ZXGeneralAppIdDecoder alloc] initWithInformation:anInformation] autorelease];
  }

  return self;
}

- (void)dealloc {
  [information release];
  [generalDecoder release];

  [super dealloc];
}

- (NSString *)parseInformationWithError:(NSError **)error {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

+ (ZXAbstractExpandedDecoder *)createDecoder:(ZXBitArray *)information {
  if ([information get:1]) {
    return [[[ZXAI01AndOtherAIs alloc] initWithInformation:information] autorelease];
  }
  if (![information get:2]) {
    return [[[ZXAnyAIDecoder alloc] initWithInformation:information] autorelease];
  }

  int fourBitEncodationMethod = [ZXGeneralAppIdDecoder extractNumericValueFromBitArray:information pos:1 bits:4];

  switch (fourBitEncodationMethod) {
  case 4:
    return [[[ZXAI013103decoder alloc] initWithInformation:information] autorelease];
  case 5:
    return [[[ZXAI01320xDecoder alloc] initWithInformation:information] autorelease];
  }

  int fiveBitEncodationMethod = [ZXGeneralAppIdDecoder extractNumericValueFromBitArray:information pos:1 bits:5];
  switch (fiveBitEncodationMethod) {
  case 12:
    return [[[ZXAI01392xDecoder alloc] initWithInformation:information] autorelease];
  case 13:
    return [[[ZXAI01393xDecoder alloc] initWithInformation:information] autorelease];
  }
  
  int sevenBitEncodationMethod = [ZXGeneralAppIdDecoder extractNumericValueFromBitArray:information pos:1 bits:7];
  switch (sevenBitEncodationMethod) {
  case 56:
    return [[[ZXAI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"310" dateCode:@"11"] autorelease];
  case 57:
    return [[[ZXAI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"320" dateCode:@"11"] autorelease];
  case 58:
    return [[[ZXAI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"310" dateCode:@"13"] autorelease];
  case 59:
    return [[[ZXAI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"320" dateCode:@"13"] autorelease];
  case 60:
    return [[[ZXAI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"310" dateCode:@"15"] autorelease];
  case 61:
    return [[[ZXAI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"320" dateCode:@"15"] autorelease];
  case 62:
    return [[[ZXAI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"310" dateCode:@"17"] autorelease];
  case 63:
    return [[[ZXAI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"320" dateCode:@"17"] autorelease];
  }

  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"unknown decoder: %@", information]
                               userInfo:nil];
}

@end
