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

@interface ZXMultiFormatOneDReader ()

@property (nonatomic, retain) NSMutableArray * readers;

@end

@implementation ZXMultiFormatOneDReader

@synthesize readers;

- (id)initWithHints:(ZXDecodeHints *)hints {
  if (self = [super init]) {
    BOOL useCode39CheckDigit = hints != nil && hints.assumeCode39CheckDigit;
    self.readers = [NSMutableArray array];
    if (hints != nil) {
      if ([hints containsFormat:kBarcodeFormatEan13] ||
          [hints containsFormat:kBarcodeFormatUPCA] ||
          [hints containsFormat:kBarcodeFormatEan8] ||
          [hints containsFormat:kBarcodeFormatUPCE]) {
        [self.readers addObject:[[[ZXMultiFormatUPCEANReader alloc] initWithHints:hints] autorelease]];
      }

      if ([hints containsFormat:kBarcodeFormatCode39]) {
        [self.readers addObject:[[[ZXCode39Reader alloc] initUsingCheckDigit:useCode39CheckDigit] autorelease]];
      }

      if ([hints containsFormat:kBarcodeFormatCode93]) {
        [self.readers addObject:[[[ZXCode93Reader alloc] init] autorelease]];
      }

      if ([hints containsFormat:kBarcodeFormatCode128]) {
        [self.readers addObject:[[[ZXCode128Reader alloc] init] autorelease]];
      }

      if ([hints containsFormat:kBarcodeFormatITF]) {
        [self.readers addObject:[[[ZXITFReader alloc] init] autorelease]];
      }

      if ([hints containsFormat:kBarcodeFormatCodabar]) {
        [self.readers addObject:[[[ZXCodaBarReader alloc] init] autorelease]];
      }

      if ([hints containsFormat:kBarcodeFormatRSS14]) {
        [self.readers addObject:[[[ZXRSS14Reader alloc] init] autorelease]];
      }

      if ([hints containsFormat:kBarcodeFormatRSSExpanded]) {
        [self.readers addObject:[[[ZXRSSExpandedReader alloc] init] autorelease]];
      }
    }

    if ([self.readers count] == 0) {
      [self.readers addObject:[[[ZXMultiFormatUPCEANReader alloc] initWithHints:hints] autorelease]];
      [self.readers addObject:[[[ZXCode39Reader alloc] init] autorelease]];
      [self.readers addObject:[[[ZXCode93Reader alloc] init] autorelease]];
      [self.readers addObject:[[[ZXCode128Reader alloc] init] autorelease]];
      [self.readers addObject:[[[ZXITFReader alloc] init] autorelease]];
      [self.readers addObject:[[[ZXRSS14Reader alloc] init] autorelease]];
      [self.readers addObject:[[[ZXRSSExpandedReader alloc] init] autorelease]];
    }
  }

  return self;
}

- (void)dealloc {
  [readers release];

  [super dealloc];
}

- (ZXResult *)decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(ZXDecodeHints *)hints {
  for (ZXOneDReader * reader in self.readers) {
    @try {
      return [reader decodeRow:rowNumber row:row hints:hints];
    } @catch (ZXReaderException * re) {
    }
  }

  @throw [ZXNotFoundException notFoundInstance];
}

- (void)reset {
  for (id<ZXReader> reader in self.readers) {
    [reader reset];
  }
}

@end
