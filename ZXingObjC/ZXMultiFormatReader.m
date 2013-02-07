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

#import "ZXAztecReader.h"
#import "ZXBinaryBitmap.h"
#import "ZXDataMatrixReader.h"
#import "ZXDecodeHints.h"
#import "ZXErrors.h"
#import "ZXMaxiCodeReader.h"
#import "ZXMultiFormatOneDReader.h"
#import "ZXMultiFormatReader.h"
#import "ZXPDF417Reader.h"
#import "ZXQRCodeReader.h"
#import "ZXResult.h"

@interface ZXMultiFormatReader ()

@property (nonatomic, retain) NSMutableArray *readers;

- (ZXResult *)decodeInternal:(ZXBinaryBitmap *)image error:(NSError **)error;

@end

@implementation ZXMultiFormatReader

@synthesize hints;
@synthesize readers;

- (id)init {
  if (self = [super init]) {
    self.readers = [NSMutableArray array];
  }

  return self;
}

+ (id)reader {
  return [[[ZXMultiFormatReader alloc] init] autorelease];
}

/**
 * This version of decode honors the intent of Reader.decode(BinaryBitmap) in that it
 * passes null as a hint to the decoders. However, that makes it inefficient to call repeatedly.
 * Use setHints() followed by decodeWithState() for continuous scan applications.
 */
- (ZXResult *)decode:(ZXBinaryBitmap *)image error:(NSError **)error {
  self.hints = nil;
  return [self decodeInternal:image error:error];
}


/**
 * Decode an image using the hints provided. Does not honor existing state.
 */
- (ZXResult *)decode:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)_hints error:(NSError **)error {
  self.hints = _hints;
  return [self decodeInternal:image error:error];
}


/**
 * Decode an image using the state set up by calling setHints() previously. Continuous scan
 * clients will get a <b>large</b> speed increase by using this instead of decode().
 */
- (ZXResult *)decodeWithState:(ZXBinaryBitmap *)image error:(NSError **)error {
  if (self.readers == nil) {
    self.hints = nil;
  }
  return [self decodeInternal:image error:error];
}


/**
 * This method adds state to the ZXMultiFormatReader. By setting the hints once, subsequent calls
 * to decodeWithState(image) can reuse the same set of readers without reallocating memory. This
 * is important for performance in continuous scan clients.
 */
- (void)setHints:(ZXDecodeHints *)_hints {
  [hints release];
  hints = [_hints retain];

  BOOL tryHarder = hints != nil && hints.tryHarder;
  self.readers = [NSMutableArray array];
  if (hints != nil) {
    BOOL addZXOneDReader = [hints containsFormat:kBarcodeFormatUPCA] ||
      [hints containsFormat:kBarcodeFormatUPCE] ||
      [hints containsFormat:kBarcodeFormatEan13] ||
      [hints containsFormat:kBarcodeFormatEan8] ||
      [hints containsFormat:kBarcodeFormatCodabar] ||
      [hints containsFormat:kBarcodeFormatCode39] ||
      [hints containsFormat:kBarcodeFormatCode93] ||
      [hints containsFormat:kBarcodeFormatCode128] ||
      [hints containsFormat:kBarcodeFormatITF] ||
      [hints containsFormat:kBarcodeFormatRSS14] ||
      [hints containsFormat:kBarcodeFormatRSSExpanded];
    if (addZXOneDReader && !tryHarder) {
      [self.readers addObject:[[[ZXMultiFormatOneDReader alloc] initWithHints:hints] autorelease]];
    }
    if ([hints containsFormat:kBarcodeFormatQRCode]) {
      [self.readers addObject:[[[ZXQRCodeReader alloc] init] autorelease]];
    }
    if ([hints containsFormat:kBarcodeFormatDataMatrix]) {
      [self.readers addObject:[[[ZXDataMatrixReader alloc] init] autorelease]];
    }
    if ([hints containsFormat:kBarcodeFormatAztec]) {
      [self.readers addObject:[[[ZXAztecReader alloc] init] autorelease]];
    }
    if ([hints containsFormat:kBarcodeFormatPDF417]) {
      [self.readers addObject:[[[ZXPDF417Reader alloc] init] autorelease]];
    }
    if ([hints containsFormat:kBarcodeFormatMaxiCode]) {
      [self.readers addObject:[[[ZXMaxiCodeReader alloc] init] autorelease]];
    }
    if (addZXOneDReader && tryHarder) {
      [self.readers addObject:[[[ZXMultiFormatOneDReader alloc] initWithHints:hints] autorelease]];
    }
  }
  if ([self.readers count] == 0) {
    if (!tryHarder) {
      [self.readers addObject:[[[ZXMultiFormatOneDReader alloc] initWithHints:hints] autorelease]];
    }
    [self.readers addObject:[[[ZXQRCodeReader alloc] init] autorelease]];
    [self.readers addObject:[[[ZXDataMatrixReader alloc] init] autorelease]];
    [self.readers addObject:[[[ZXAztecReader alloc] init] autorelease]];
    [self.readers addObject:[[[ZXPDF417Reader alloc] init] autorelease]];
    [self.readers addObject:[[[ZXMaxiCodeReader alloc] init] autorelease]];
    if (tryHarder) {
      [self.readers addObject:[[[ZXMultiFormatOneDReader alloc] initWithHints:hints] autorelease]];
    }
  }
}

- (void)reset {
  if (self.readers != nil) {
    for (id<ZXReader> reader in self.readers) {
      [reader reset];
    }
  }
}

- (ZXResult *)decodeInternal:(ZXBinaryBitmap *)image error:(NSError **)error {
  if (self.readers != nil) {
    for (id<ZXReader> reader in self.readers) {
      ZXResult *result = [reader decode:image hints:self.hints error:nil];
      if (result) {
        return result;
      }
    }
  }

  if (error) *error = NotFoundErrorInstance();
  return nil;
}

- (void)dealloc {
  [hints release];
  [readers release];

  [super dealloc];
}

@end
