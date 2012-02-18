#import "AztecReader.h"
#import "BinaryBitmap.h"
#import "DataMatrixReader.h"
#import "DecodeHintType.h"
#import "MultiFormatOneDReader.h"
#import "MultiFormatReader.h"
#import "PDF417Reader.h"
#import "QRCodeReader.h"
#import "Result.h"

@interface MultiFormatReader ()

- (Result *) decodeInternal:(BinaryBitmap *)image;
- (void) setHints:(NSMutableDictionary *)hints;

@end

@implementation MultiFormatReader

/**
 * This version of decode honors the intent of Reader.decode(BinaryBitmap) in that it
 * passes null as a hint to the decoders. However, that makes it inefficient to call repeatedly.
 * Use setHints() followed by decodeWithState() for continuous scan applications.
 * 
 * @param image The pixel data to decode
 * @return The contents of the image
 * @throws NotFoundException Any errors which occurred
 */
- (Result *) decode:(BinaryBitmap *)image {
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
- (Result *) decode:(BinaryBitmap *)image hints:(NSMutableDictionary *)_hints {
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
- (Result *) decodeWithState:(BinaryBitmap *)image {
  if (readers == nil) {
    [self setHints:nil];
  }
  return [self decodeInternal:image];
}


/**
 * This method adds state to the MultiFormatReader. By setting the hints once, subsequent calls
 * to decodeWithState(image) can reuse the same set of readers without reallocating memory. This
 * is important for performance in continuous scan clients.
 * 
 * @param hints The set of hints to use for subsequent calls to decode(image)
 */
- (void) setHints:(NSMutableDictionary *)_hints {
  [hints release];
  hints = [_hints retain];

  BOOL tryHarder = hints != nil && [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypeTryHarder]];
  NSMutableArray * formats = hints == nil ? nil : [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypePossibleFormats]];
  readers = [[NSMutableArray alloc] init];
  if (formats != nil) {
    BOOL addOneDReader = [formats containsObject:[NSNumber numberWithInt:kBarcodeFormatUPCA]] ||
      [formats containsObject:[NSNumber numberWithInt:kBarcodeFormatUPCE]] ||
      [formats containsObject:[NSNumber numberWithInt:kBarcodeFormatEan13]] ||
      [formats containsObject:[NSNumber numberWithInt:kBarcodeFormatEan8]] ||
      [formats containsObject:[NSNumber numberWithInt:kBarcodeFormatCode39]] ||
      [formats containsObject:[NSNumber numberWithInt:kBarcodeFormatCode93]] ||
      [formats containsObject:[NSNumber numberWithInt:kBarcodeFormatCode128]] ||
      [formats containsObject:[NSNumber numberWithInt:kBarcodeFormatITF]] ||
      [formats containsObject:[NSNumber numberWithInt:kBarcodeFormatRSS14]] ||
      [formats containsObject:[NSNumber numberWithInt:kBarcodeFormatRSSExpanded]];
    if (addOneDReader && !tryHarder) {
      [readers addObject:[[[MultiFormatOneDReader alloc] initWithHints:hints] autorelease]];
    }
    if ([formats containsObject:[NSNumber numberWithInt:kBarcodeFormatQRCode]]) {
      [readers addObject:[[[QRCodeReader alloc] init] autorelease]];
    }
    if ([formats containsObject:[NSNumber numberWithInt:kBarcodeFormatDataMatrix]]) {
      [readers addObject:[[[DataMatrixReader alloc] init] autorelease]];
    }
    if ([formats containsObject:[NSNumber numberWithInt:kBarcodeFormatAztec]]) {
      [readers addObject:[[[AztecReader alloc] init] autorelease]];
    }
    if ([formats containsObject:[NSNumber numberWithInt:kBarcodeFormatPDF417]]) {
      [readers addObject:[[[PDF417Reader alloc] init] autorelease]];
    }
    if (addOneDReader && tryHarder) {
      [readers addObject:[[[MultiFormatOneDReader alloc] initWithHints:hints] autorelease]];
    }
  }
  if ([readers count] == 0) {
    if (!tryHarder) {
      [readers addObject:[[[MultiFormatOneDReader alloc] initWithHints:hints] autorelease]];
    }
    [readers addObject:[[[QRCodeReader alloc] init] autorelease]];
    [readers addObject:[[[DataMatrixReader alloc] init] autorelease]];
    [readers addObject:[[[AztecReader alloc] init] autorelease]];
    [readers addObject:[[[PDF417Reader alloc] init] autorelease]];
    if (tryHarder) {
      [readers addObject:[[[MultiFormatOneDReader alloc] initWithHints:hints] autorelease]];
    }
  }
}

- (void) reset {
  for (id<Reader> reader in readers) {
    [reader reset];
  }
}

- (Result *) decodeInternal:(BinaryBitmap *)image {
  for (id<Reader> reader in readers) {
    @try {
      return [reader decode:image hints:hints];
    }
    @catch (ReaderException * re) {
    }
  }

  @throw [NotFoundException notFoundInstance];
}

- (void) dealloc {
  [hints release];
  [readers release];
  [super dealloc];
}

@end
