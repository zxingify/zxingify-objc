#import "EAN13Reader.h"
#import "FormatException.h"
#import "Result.h"
#import "UPCAReader.h"

@interface UPCAReader ()

- (Result *) maybeReturnResult:(Result *)result;

@end

@implementation UPCAReader

- (id) init {
  if (self = [super init]) {
    ean13Reader = [[[EAN13Reader alloc] init] autorelease];
  }
  return self;
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row startGuardRange:(NSArray *)startGuardRange hints:(NSMutableDictionary *)hints {
  return [self maybeReturnResult:[ean13Reader decodeRow:rowNumber row:row startGuardRange:startGuardRange hints:hints]];
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints {
  return [self maybeReturnResult:[ean13Reader decodeRow:rowNumber row:row hints:hints]];
}

- (Result *) decode:(BinaryBitmap *)image {
  return [self maybeReturnResult:[ean13Reader decode:image]];
}

- (Result *) decode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints {
  return [self maybeReturnResult:[ean13Reader decode:image hints:hints]];
}

- (BarcodeFormat) barcodeFormat {
  return kBarcodeFormatUPCA;
}

- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange result:(NSMutableString *)result {
  return [ean13Reader decodeMiddle:row startRange:startRange result:result];
}

- (Result *) maybeReturnResult:(Result *)result {
  NSString * text = [result text];
  if ([text characterAtIndex:0] == '0') {
    return [[[Result alloc] initWithText:[text substringFromIndex:1]
                                rawBytes:nil
                            resultPoints:[result resultPoints]
                                  format:kBarcodeFormatUPCA] autorelease];
  } else {
    @throw [FormatException formatInstance];
  }
}

- (void) dealloc {
  [ean13Reader release];
  [super dealloc];
}

@end
