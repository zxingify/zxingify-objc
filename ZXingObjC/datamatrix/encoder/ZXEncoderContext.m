/*
 * Copyright 2013 ZXing authors
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

#import "ZXEncoderContext.h"
#import "ZXSymbolInfo.h"
#import "ZXSymbolShapeHint.h"

@interface ZXEncoderContext ()

@property (nonatomic, retain) ZXDimension *maxSize;
@property (nonatomic, retain) ZXDimension *minSize;

@end

@implementation ZXEncoderContext

@synthesize codewords = _codewords;
@synthesize message = _message;
@synthesize symbolShape = _symbolShape;
@synthesize newEncoding = _newEncoding;
@synthesize maxSize = _maxSize;
@synthesize minSize = _minSize;
@synthesize skipAtEnd = _skipAtEnd;
@synthesize pos = _pos;
@synthesize symbolInfo = _symbolInfo;

- (id)initWithMessage:(NSString *)msg {
  if (self = [super init]) {
    //From this point on Strings are not Unicode anymore!
    NSData *msgData = [msg dataUsingEncoding:NSISOLatin1StringEncoding];
    if (!msgData) {
      [NSException raise:NSInvalidArgumentException format:@"Message contains characters outside ISO-8859-1 encoding."];
    }
    const char *msgBinary = [msgData bytes];
    NSMutableString *sb = [NSMutableString string];
    for (int i = 0, c = msg.length; i < c; i++) {
      unichar ch = (unichar) (msgBinary[i] & 0xff);
      [sb appendFormat:@"%C", ch];
    }

    _message = [[NSString alloc] initWithString:sb];
    _symbolShape = [[ZXSymbolShapeHint forceNone] retain];
    _codewords = [[NSMutableString alloc] initWithCapacity:msg.length];
    _newEncoding = -1;
  }

  return self;
}

- (void)dealloc {
  [_codewords release];
  [_maxSize release];
  [_message release];
  [_minSize release];
  [_symbolInfo release];
  [_symbolShape release];

  [super dealloc];
}

- (void)setSizeConstraints:(ZXDimension *)minSize maxSize:(ZXDimension *)maxSize {
  self.minSize = minSize;
  self.maxSize = maxSize;
}

- (unichar)currentChar {
  return [self.message characterAtIndex:self.pos];
}

- (unichar)current {
  return [self.message characterAtIndex:self.pos];
}

- (void)writeCodewords:(NSString *)codewords {
  [self.codewords appendString:codewords];
}

- (void)writeCodeword:(unichar)codeword {
  [self.codewords appendFormat:@"%C", codeword];
}

- (int)codewordCount {
  return self.codewords.length;
}

- (void)signalEncoderChange:(int)encoding {
  self.newEncoding = encoding;
}

- (void)resetEncoderSignal {
  self.newEncoding = -1;
}

- (BOOL)hasMoreCharacters {
  return self.pos < [self totalMessageCharCount];
}

- (int)totalMessageCharCount {
  return self.message.length - self.skipAtEnd;
}

- (int)remainingCharacters {
  return [self totalMessageCharCount] - self.pos;
}

- (void)updateSymbolInfo {
  [self updateSymbolInfoWithLength:[self codewordCount]];
}

- (void)updateSymbolInfoWithLength:(int)len {
  if (self.symbolInfo == nil || len > self.symbolInfo.dataCapacity) {
    self.symbolInfo = [ZXSymbolInfo lookup:len shape:self.symbolShape minSize:self.minSize maxSize:self.maxSize fail:YES];
  }
}

- (void)resetSymbolInfo {
  self.symbolInfo = nil;
}

@end
