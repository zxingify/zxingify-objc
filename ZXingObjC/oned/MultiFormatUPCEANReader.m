#import "MultiFormatUPCEANReader.h"

@implementation MultiFormatUPCEANReader

- (id) initWithHints:(NSMutableDictionary *)hints {
  if (self = [super init]) {
    NSMutableArray * possibleFormats = hints == nil ? nil : (NSMutableArray *)[hints objectForKey:DecodeHintType.POSSIBLE_FORMATS];
    readers = [[[NSMutableArray alloc] init] autorelease];
    if (possibleFormats != nil) {
      if ([possibleFormats containsObject:BarcodeFormat.EAN_13]) {
        [readers addObject:[[[EAN13Reader alloc] init] autorelease]];
      }
       else if ([possibleFormats containsObject:BarcodeFormat.UPC_A]) {
        [readers addObject:[[[UPCAReader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:BarcodeFormat.EAN_8]) {
        [readers addObject:[[[EAN8Reader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:BarcodeFormat.UPC_E]) {
        [readers addObject:[[[UPCEReader alloc] init] autorelease]];
      }
    }
    if ([readers empty]) {
      [readers addObject:[[[EAN13Reader alloc] init] autorelease]];
      [readers addObject:[[[EAN8Reader alloc] init] autorelease]];
      [readers addObject:[[[UPCEReader alloc] init] autorelease]];
    }
  }
  return self;
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints {
  NSArray * startGuardPattern = [UPCEANReader findStartGuardPattern:row];
  int size = [readers count];

  for (int i = 0; i < size; i++) {
    UPCEANReader * reader = (UPCEANReader *)[readers objectAtIndex:i];
    Result * result;

    @try {
      result = [reader decodeRow:rowNumber param1:row param2:startGuardPattern param3:hints];
    }
    @catch (ReaderException * re) {
      continue;
    }
    BOOL ean13MayBeUPCA = [BarcodeFormat.EAN_13 isEqualTo:[result barcodeFormat]] && [[result text] charAt:0] == '0';
    NSMutableArray * possibleFormats = hints == nil ? nil : (NSMutableArray *)[hints objectForKey:DecodeHintType.POSSIBLE_FORMATS];
    BOOL canReturnUPCA = possibleFormats == nil || [possibleFormats containsObject:BarcodeFormat.UPC_A];
    if (ean13MayBeUPCA && canReturnUPCA) {
      return [[[Result alloc] init:[[result text] substring:1] param1:nil param2:[result resultPoints] param3:BarcodeFormat.UPC_A] autorelease];
    }
    return result;
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
