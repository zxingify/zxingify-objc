#import "ZXCodaBarReader.h"
#import "ZXCode128Reader.h"
#import "ZXCode39Reader.h"
#import "ZXCode93Reader.h"
#import "ZXDecodeHints.h"
#import "ZXITFReader.h"
#import "ZXMultiFormatOneDReader.h"
#import "ZXMultiFormatUPCEANReader.h"
#import "ZXRSS14Reader.h"
#import "ZXRSSExpandedReader.h"

@implementation ZXMultiFormatOneDReader

- (id) initWithHints:(ZXDecodeHints *)hints {
  if (self = [super init]) {
    BOOL useCode39CheckDigit = hints != nil && hints.assumeCode39CheckDigit;
    if (hints != nil) {
      readers = [[NSMutableArray alloc] init];
      if ([hints containsFormat:kBarcodeFormatEan13] ||
          [hints containsFormat:kBarcodeFormatUPCA] ||
          [hints containsFormat:kBarcodeFormatEan8] ||
          [hints containsFormat:kBarcodeFormatUPCE]) {
        [readers addObject:[[[ZXMultiFormatUPCEANReader alloc] initWithHints:hints] autorelease]];
      }

      if ([hints containsFormat:kBarcodeFormatCode39]) {
        [readers addObject:[[[ZXCode39Reader alloc] initUsingCheckDigit:useCode39CheckDigit] autorelease]];
      }

      if ([hints containsFormat:kBarcodeFormatCode93]) {
        [readers addObject:[[[ZXCode93Reader alloc] init] autorelease]];
      }

      if ([hints containsFormat:kBarcodeFormatCode128]) {
        [readers addObject:[[[ZXCode128Reader alloc] init] autorelease]];
      }

      if ([hints containsFormat:kBarcodeFormatITF]) {
        [readers addObject:[[[ZXITFReader alloc] init] autorelease]];
      }

      if ([hints containsFormat:kBarcodeFormatCodabar]) {
        [readers addObject:[[[ZXCodaBarReader alloc] init] autorelease]];
      }

      if ([hints containsFormat:kBarcodeFormatRSS14]) {
        [readers addObject:[[[ZXRSS14Reader alloc] init] autorelease]];
      }

      if ([hints containsFormat:kBarcodeFormatRSSExpanded]) {
        [readers addObject:[[[ZXRSSExpandedReader alloc] init] autorelease]];
      }
    }

    if ([readers count] == 0) {
      [readers addObject:[[[ZXMultiFormatUPCEANReader alloc] initWithHints:hints] autorelease]];
      [readers addObject:[[[ZXCode39Reader alloc] init] autorelease]];
      [readers addObject:[[[ZXCode93Reader alloc] init] autorelease]];
      [readers addObject:[[[ZXCode128Reader alloc] init] autorelease]];
      [readers addObject:[[[ZXITFReader alloc] init] autorelease]];
      [readers addObject:[[[ZXRSS14Reader alloc] init] autorelease]];
      [readers addObject:[[[ZXRSSExpandedReader alloc] init] autorelease]];
    }
  }
  return self;
}

- (ZXResult *) decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(ZXDecodeHints *)hints {
  for (ZXOneDReader * reader in readers) {
    @try {
      return [reader decodeRow:rowNumber row:row hints:hints];
    }
    @catch (ZXReaderException * re) {
    }
  }

  @throw [ZXNotFoundException notFoundInstance];
}

- (void) reset {
  for (id<ZXReader> reader in readers) {
    [reader reset];
  }
}

- (void) dealloc {
  [readers release];
  [super dealloc];
}

@end
