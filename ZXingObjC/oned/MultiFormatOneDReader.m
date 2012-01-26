#import "MultiFormatOneDReader.h"

@implementation MultiFormatOneDReader

- (id) initWithHints:(NSMutableDictionary *)hints {
  if (self = [super init]) {
    NSMutableArray * possibleFormats = hints == nil ? nil : (NSMutableArray *)[hints objectForKey:DecodeHintType.POSSIBLE_FORMATS];
    BOOL useCode39CheckDigit = hints != nil && [hints objectForKey:DecodeHintType.ASSUME_CODE_39_CHECK_DIGIT] != nil;
    readers = [[[NSMutableArray alloc] init] autorelease];
    if (possibleFormats != nil) {
      if ([possibleFormats containsObject:BarcodeFormat.EAN_13] || [possibleFormats containsObject:BarcodeFormat.UPC_A] || [possibleFormats containsObject:BarcodeFormat.EAN_8] || [possibleFormats containsObject:BarcodeFormat.UPC_E]) {
        [readers addObject:[[[MultiFormatUPCEANReader alloc] init:hints] autorelease]];
      }
      if ([possibleFormats containsObject:BarcodeFormat.CODE_39]) {
        [readers addObject:[[[Code39Reader alloc] init:useCode39CheckDigit] autorelease]];
      }
      if ([possibleFormats containsObject:BarcodeFormat.CODE_93]) {
        [readers addObject:[[[Code93Reader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:BarcodeFormat.CODE_128]) {
        [readers addObject:[[[Code128Reader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:BarcodeFormat.ITF]) {
        [readers addObject:[[[ITFReader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:BarcodeFormat.CODABAR]) {
        [readers addObject:[[[CodaBarReader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:BarcodeFormat.RSS_14]) {
        [readers addObject:[[[RSS14Reader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:BarcodeFormat.RSS_EXPANDED]) {
        [readers addObject:[[[RSSExpandedReader alloc] init] autorelease]];
      }
    }
    if ([readers empty]) {
      [readers addObject:[[[MultiFormatUPCEANReader alloc] init:hints] autorelease]];
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
  int size = [readers count];

  for (int i = 0; i < size; i++) {
    OneDReader * reader = (OneDReader *)[readers objectAtIndex:i];

    @try {
      return [reader decodeRow:rowNumber param1:row param2:hints];
    }
    @catch (ReaderException * re) {
    }
  }

  @throw [NotFoundException notFoundInstance];
}

- (void) reset {
  int size = [readers count];

  for (int i = 0; i < size; i++) {
    Reader * reader = (Reader *)[readers objectAtIndex:i];
    [reader reset];
  }

}

- (void) dealloc {
  [readers release];
  [super dealloc];
}

@end
