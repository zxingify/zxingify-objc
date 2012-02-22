#import "DecodeHintType.h"
#import "EAN8Reader.h"
#import "EAN13Reader.h"
#import "MultiFormatUPCEANReader.h"
#import "NotFoundException.h"
#import "ReaderException.h"
#import "Reader.h"
#import "UPCAReader.h"
#import "UPCEReader.h"

@implementation MultiFormatUPCEANReader

- (id) initWithHints:(NSMutableDictionary *)hints {
  if (self = [super init]) {
    NSMutableArray * possibleFormats = hints == nil ? nil : [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypePossibleFormats]];
    readers = [[NSMutableArray alloc] init];
    if (possibleFormats != nil) {
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatEan13]]) {
        [readers addObject:[[[EAN13Reader alloc] init] autorelease]];
      } else if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatUPCA]]) {
        [readers addObject:[[[UPCAReader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatEan8]]) {
        [readers addObject:[[[EAN8Reader alloc] init] autorelease]];
      }
    } else if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatUPCE]]) {
        [readers addObject:[[[UPCEReader alloc] init] autorelease]];
    }
    if ([readers count] == 0) {
      [readers addObject:[[[EAN13Reader alloc] init] autorelease]];
      [readers addObject:[[[EAN8Reader alloc] init] autorelease]];
      [readers addObject:[[[UPCEReader alloc] init] autorelease]];
    }
  }
  return self;
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints {
  NSArray * startGuardPattern = [UPCEANReader findStartGuardPattern:row];
  for (UPCEANReader * reader in readers) {
    Result * result;
    @try {
      result = [reader decodeRow:rowNumber row:row startGuardRange:startGuardPattern hints:hints];
    }
    @catch (ReaderException * re) {
      continue;
    }
    // Special case: a 12-digit code encoded in UPC-A is identical to a "0"
    // followed by those 12 digits encoded as EAN-13. Each will recognize such a code,
    // UPC-A as a 12-digit string and EAN-13 as a 13-digit string starting with "0".
    // Individually these are correct and their readers will both read such a code
    // and correctly call it EAN-13, or UPC-A, respectively.
    //
    // In this case, if we've been looking for both types, we'd like to call it
    // a UPC-A code. But for efficiency we only run the EAN-13 decoder to also read
    // UPC-A. So we special case it here, and convert an EAN-13 result to a UPC-A
    // result if appropriate.
    //
    // But, don't return UPC-A if UPC-A was not a requested format!
    BOOL ean13MayBeUPCA = kBarcodeFormatEan13 == result.barcodeFormat && [[result text] characterAtIndex:0] == '0';
    NSMutableArray * possibleFormats = hints == nil ? nil : [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypePossibleFormats]];
    BOOL canReturnUPCA = possibleFormats == nil || [possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatUPCA]];
    if (ean13MayBeUPCA && canReturnUPCA) {
      return [[[Result alloc] initWithText:[[result text] substringFromIndex:1]
                                    rawBytes:nil
                                    length:0
                                    resultPoints:[result resultPoints]
                                    format:kBarcodeFormatUPCA] autorelease];
    }
    return result;
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
