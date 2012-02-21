#import "CodaBarReader.h"
#import "Code128Reader.h"
#import "Code39Reader.h"
#import "Code93Reader.h"
#import "DecodeHintType.h"
#import "ITFReader.h"
#import "MultiFormatOneDReader.h"
#import "MultiFormatUPCEANReader.h"
#import "RSS14Reader.h"
#import "RSSExpandedReader.h"

@implementation MultiFormatOneDReader

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
        [readers addObject:[[[MultiFormatUPCEANReader alloc] initWithHints:hints] autorelease]];
      }
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatCode39]]) {
        [readers addObject:[[[Code39Reader alloc] initUsingCheckDigit:useCode39CheckDigit] autorelease]];
      }
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatCode93]]) {
        [readers addObject:[[[Code93Reader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatCode128]]) {
        [readers addObject:[[[Code128Reader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatITF]]) {
        [readers addObject:[[[ITFReader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatCodabar]]) {
        [readers addObject:[[[CodaBarReader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatRSS14]]) {
        [readers addObject:[[[RSS14Reader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatRSSExpanded]]) {
        [readers addObject:[[[RSSExpandedReader alloc] init] autorelease]];
      }
    }
    if ([readers count] == 0) {
      [readers addObject:[[[MultiFormatUPCEANReader alloc] initWithHints:hints] autorelease]];
      [readers addObject:[[[Code39Reader alloc] init] autorelease]];
      [readers addObject:[[[Code93Reader alloc] init] autorelease]];
      [readers addObject:[[[Code128Reader alloc] init] autorelease]];
      [readers addObject:[[[ITFReader alloc] init] autorelease]];
      [readers addObject:[[[RSS14Reader alloc] init] autorelease]];
      [readers addObject:[[[RSSExpandedReader alloc] init] autorelease]];
    }
  }
  return self;
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints {
  for (OneDReader * reader in readers) {
    @try {
      return [reader decodeRow:rowNumber row:row hints:hints];
    }
    @catch (ReaderException * re) {
    }
  }

  @throw [NotFoundException notFoundInstance];
}

- (void) reset {
  for (id<Reader> reader in readers) {
    [reader reset];
  }
}

- (void) dealloc {
  [readers release];
  [super dealloc];
}

@end
