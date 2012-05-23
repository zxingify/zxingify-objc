#import "ZXAztecReader.h"
#import "ZXBinaryBitmap.h"
#import "ZXDataMatrixReader.h"
#import "ZXDecodeHints.h"
#import "ZXErrors.h"
#import "ZXMultiFormatOneDReader.h"
#import "ZXMultiFormatReader.h"
#import "ZXPDF417Reader.h"
#import "ZXQRCodeReader.h"
#import "ZXResult.h"

@interface ZXMultiFormatReader ()

@property (nonatomic, retain) NSMutableArray * readers;

- (ZXResult *)decodeInternal:(ZXBinaryBitmap *)image error:(NSError **)error;

@end

@implementation ZXMultiFormatReader

@synthesize hints;
@synthesize readers;

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
    if (tryHarder) {
      [self.readers addObject:[[[ZXMultiFormatOneDReader alloc] initWithHints:hints] autorelease]];
    }
  }
}

- (void)reset {
  for (id<ZXReader> reader in self.readers) {
    [reader reset];
  }
}

- (ZXResult *)decodeInternal:(ZXBinaryBitmap *)image error:(NSError **)error {
  for (id<ZXReader> reader in self.readers) {
    ZXResult* result = [reader decode:image hints:self.hints error:nil];
    if (result) {
      return result;
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
