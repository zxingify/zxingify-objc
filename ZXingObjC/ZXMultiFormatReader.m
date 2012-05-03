#import "ZXAztecReader.h"
#import "ZXBinaryBitmap.h"
#import "ZXDataMatrixReader.h"
#import "ZXDecodeHints.h"
#import "ZXMultiFormatOneDReader.h"
#import "ZXMultiFormatReader.h"
#import "ZXNotFoundException.h"
#import "ZXPDF417Reader.h"
#import "ZXQRCodeReader.h"
#import "ZXReaderException.h"
#import "ZXResult.h"

@interface ZXMultiFormatReader ()

- (ZXResult *) decodeInternal:(ZXBinaryBitmap *)image;
- (void) setHints:(ZXDecodeHints *)hints;

@end

@implementation ZXMultiFormatReader

/**
 * This version of decode honors the intent of Reader.decode(BinaryBitmap) in that it
 * passes null as a hint to the decoders. However, that makes it inefficient to call repeatedly.
 * Use setHints() followed by decodeWithState() for continuous scan applications.
 * 
 * @param image The pixel data to decode
 * @return The contents of the image
 * @throws NotFoundException Any errors which occurred
 */
- (ZXResult *) decode:(ZXBinaryBitmap *)image {
  [self setHints:nil];
  return [self decodeInternal:image];
}


/**
 * Decode an image using the hints provided. Does not honor existing state.
 * 
 * @param image The pixel data to decode
 * @param hints The hints to use, clearing the previous state.
 * @return The contents of the image
 * @throws NotFoundException Any errors which occurred
 */
- (ZXResult *) decode:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)_hints {
  [self setHints:_hints];
  return [self decodeInternal:image];
}


/**
 * Decode an image using the state set up by calling setHints() previously. Continuous scan
 * clients will get a <b>large</b> speed increase by using this instead of decode().
 * 
 * @param image The pixel data to decode
 * @return The contents of the image
 * @throws NotFoundException Any errors which occurred
 */
- (ZXResult *) decodeWithState:(ZXBinaryBitmap *)image {
  if (readers == nil) {
    [self setHints:nil];
  }
  return [self decodeInternal:image];
}


/**
 * This method adds state to the ZXMultiFormatReader. By setting the hints once, subsequent calls
 * to decodeWithState(image) can reuse the same set of readers without reallocating memory. This
 * is important for performance in continuous scan clients.
 * 
 * @param hints The set of hints to use for subsequent calls to decode(image)
 */
- (void) setHints:(ZXDecodeHints *)_hints {
  [hints release];
  hints = [_hints retain];

  BOOL tryHarder = hints != nil && hints.tryHarder;
  readers = [[NSMutableArray alloc] init];
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
      [readers addObject:[[[ZXMultiFormatOneDReader alloc] initWithHints:hints] autorelease]];
    }
    if ([hints containsFormat:kBarcodeFormatQRCode]) {
      [readers addObject:[[[ZXQRCodeReader alloc] init] autorelease]];
    }
    if ([hints containsFormat:kBarcodeFormatDataMatrix]) {
      [readers addObject:[[[ZXDataMatrixReader alloc] init] autorelease]];
    }
    if ([hints containsFormat:kBarcodeFormatAztec]) {
      [readers addObject:[[[ZXAztecReader alloc] init] autorelease]];
    }
    if ([hints containsFormat:kBarcodeFormatPDF417]) {
      [readers addObject:[[[ZXPDF417Reader alloc] init] autorelease]];
    }
    if (addZXOneDReader && tryHarder) {
      [readers addObject:[[[ZXMultiFormatOneDReader alloc] initWithHints:hints] autorelease]];
    }
  }
  if ([readers count] == 0) {
    if (!tryHarder) {
      [readers addObject:[[[ZXMultiFormatOneDReader alloc] initWithHints:hints] autorelease]];
    }
    [readers addObject:[[[ZXQRCodeReader alloc] init] autorelease]];
    [readers addObject:[[[ZXDataMatrixReader alloc] init] autorelease]];
    [readers addObject:[[[ZXAztecReader alloc] init] autorelease]];
    [readers addObject:[[[ZXPDF417Reader alloc] init] autorelease]];
    if (tryHarder) {
      [readers addObject:[[[ZXMultiFormatOneDReader alloc] initWithHints:hints] autorelease]];
    }
  }
}

- (void) reset {
  for (id<ZXReader> reader in readers) {
    [reader reset];
  }
}

- (ZXResult *) decodeInternal:(ZXBinaryBitmap *)image {
  for (id<ZXReader> reader in readers) {
    @try {
      return [reader decode:image hints:hints];
    }
    @catch (ZXReaderException * re) {
    }
  }

  @throw [ZXNotFoundException notFoundInstance];
}

- (void) dealloc {
  [hints release];
  [readers release];
  [super dealloc];
}

@end
