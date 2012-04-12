#import "ZXCodaBarReader.h"
#import "ZXCode128Reader.h"
#import "ZXCode39Reader.h"
#import "ZXCode93Reader.h"
#import "ZXDecodeHintType.h"
#import "ZXITFReader.h"
#import "ZXMultiFormatOneDReader.h"
#import "ZXMultiFormatUPCEANReader.h"
#import "ZXRSS14Reader.h"
#import "ZXRSSExpandedReader.h"

@implementation ZXMultiFormatOneDReader

- (id) initWithHints:(NSMutableDictionary *)hints {
  if (self = [super init]) {
    NSMutableArray * possibleFormats = hints == nil ? nil : [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypePossibleFormats]];
    BOOL useCode39CheckDigit = hints != nil && [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypeAssumeCode39CheckDigit]] != nil;
    readers = [[NSMutableArray alloc] init];
    if (possibleFormats != nil) {
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatEan13]] ||
          [possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatUPCA]] ||
          [possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatEan8]] ||
          [possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatUPCE]]) {
        [readers addObject:[[[ZXMultiFormatUPCEANReader alloc] initWithHints:hints] autorelease]];
      }
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatCode39]]) {
        [readers addObject:[[[ZXCode39Reader alloc] initUsingCheckDigit:useCode39CheckDigit] autorelease]];
      }
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatCode93]]) {
        [readers addObject:[[[ZXCode93Reader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatCode128]]) {
        [readers addObject:[[[ZXCode128Reader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatITF]]) {
        [readers addObject:[[[ZXITFReader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatCodabar]]) {
        [readers addObject:[[[ZXCodaBarReader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatRSS14]]) {
        [readers addObject:[[[ZXRSS14Reader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatRSSExpanded]]) {
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

- (ZXResult *) decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(NSMutableDictionary *)hints {
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
