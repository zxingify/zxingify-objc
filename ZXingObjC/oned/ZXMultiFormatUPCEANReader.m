#import "ZXDecodeHintType.h"
#import "ZXEAN8Reader.h"
#import "ZXEAN13Reader.h"
#import "ZXMultiFormatUPCEANReader.h"
#import "ZXNotFoundException.h"
#import "ZXReaderException.h"
#import "ZXReader.h"
#import "ZXUPCAReader.h"
#import "ZXUPCEReader.h"

@implementation ZXMultiFormatUPCEANReader

- (id) initWithHints:(NSMutableDictionary *)hints {
  if (self = [super init]) {
    NSMutableArray * possibleFormats = hints == nil ? nil : [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypePossibleFormats]];
    readers = [[NSMutableArray alloc] init];
    if (possibleFormats != nil) {
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatEan13]]) {
        [readers addObject:[[[ZXEAN13Reader alloc] init] autorelease]];
      } else if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatUPCA]]) {
        [readers addObject:[[[ZXUPCAReader alloc] init] autorelease]];
      }
      if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatEan8]]) {
        [readers addObject:[[[ZXEAN8Reader alloc] init] autorelease]];
      }
    } else if ([possibleFormats containsObject:[NSNumber numberWithInt:kBarcodeFormatUPCE]]) {
        [readers addObject:[[[ZXUPCEReader alloc] init] autorelease]];
    }
    if ([readers count] == 0) {
      [readers addObject:[[[ZXEAN13Reader alloc] init] autorelease]];
      [readers addObject:[[[ZXEAN8Reader alloc] init] autorelease]];
      [readers addObject:[[[ZXUPCEReader alloc] init] autorelease]];
    }
  }
  return self;
}

- (ZXResult *) decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(NSMutableDictionary *)hints {
  NSArray * startGuardPattern = [ZXUPCEANReader findStartGuardPattern:row];
  for (ZXUPCEANReader * reader in readers) {
    ZXResult * result;
    @try {
      result = [reader decodeRow:rowNumber row:row startGuardRange:startGuardPattern hints:hints];
    }
    @catch (ZXReaderException * re) {
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
      return [[[ZXResult alloc] initWithText:[[result text] substringFromIndex:1]
                                    rawBytes:nil
                                    length:0
                                    resultPoints:[result resultPoints]
                                    format:kBarcodeFormatUPCA] autorelease];
    }
    return result;
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
