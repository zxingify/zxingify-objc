#import "MultiFormatReader.h"

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
- (Result *) decode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints {
  [self setHints:hints];
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
- (void) setHints:(NSMutableDictionary *)hints {
  hints = hints;
  BOOL tryHarder = hints != nil && [hints containsKey:DecodeHintType.TRY_HARDER];
  NSMutableArray * formats = hints == nil ? nil : (NSMutableArray *)[hints objectForKey:DecodeHintType.POSSIBLE_FORMATS];
  readers = [[[NSMutableArray alloc] init] autorelease];
  if (formats != nil) {
    BOOL addOneDReader = [formats containsObject:BarcodeFormat.UPC_A] || [formats containsObject:BarcodeFormat.UPC_E] || [formats containsObject:BarcodeFormat.EAN_13] || [formats containsObject:BarcodeFormat.EAN_8] || [formats containsObject:BarcodeFormat.CODE_39] || [formats containsObject:BarcodeFormat.CODE_93] || [formats containsObject:BarcodeFormat.CODE_128] || [formats containsObject:BarcodeFormat.ITF] || [formats containsObject:BarcodeFormat.RSS_14] || [formats containsObject:BarcodeFormat.RSS_EXPANDED];
    if (addOneDReader && !tryHarder) {
      [readers addObject:[[[MultiFormatOneDReader alloc] init:hints] autorelease]];
    }
    if ([formats containsObject:BarcodeFormat.QR_CODE]) {
      [readers addObject:[[[QRCodeReader alloc] init] autorelease]];
    }
    if ([formats containsObject:BarcodeFormat.DATA_MATRIX]) {
      [readers addObject:[[[DataMatrixReader alloc] init] autorelease]];
    }
    if ([formats containsObject:BarcodeFormat.AZTEC]) {
      [readers addObject:[[[AztecReader alloc] init] autorelease]];
    }
    if ([formats containsObject:BarcodeFormat.PDF_417]) {
      [readers addObject:[[[PDF417Reader alloc] init] autorelease]];
    }
    if (addOneDReader && tryHarder) {
      [readers addObject:[[[MultiFormatOneDReader alloc] init:hints] autorelease]];
    }
  }
  if ([readers empty]) {
    if (!tryHarder) {
      [readers addObject:[[[MultiFormatOneDReader alloc] init:hints] autorelease]];
    }
    [readers addObject:[[[QRCodeReader alloc] init] autorelease]];
    [readers addObject:[[[DataMatrixReader alloc] init] autorelease]];
    [readers addObject:[[[AztecReader alloc] init] autorelease]];
    [readers addObject:[[[PDF417Reader alloc] init] autorelease]];
    if (tryHarder) {
      [readers addObject:[[[MultiFormatOneDReader alloc] init:hints] autorelease]];
    }
  }
}

- (void) reset {
  int size = [readers count];

  for (int i = 0; i < size; i++) {
    Reader * reader = (Reader *)[readers objectAtIndex:i];
    [reader reset];
  }

}

- (Result *) decodeInternal:(BinaryBitmap *)image {
  int size = [readers count];

  for (int i = 0; i < size; i++) {
    Reader * reader = (Reader *)[readers objectAtIndex:i];

    @try {
      return [reader decode:image param1:hints];
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
