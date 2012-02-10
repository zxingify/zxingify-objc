#import "UPCAReader.h"

@implementation UPCAReader

- (void) init {
  if (self = [super init]) {
    ean13Reader = [[[EAN13Reader alloc] init] autorelease];
  }
  return self;
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row startGuardRange:(NSArray *)startGuardRange hints:(NSMutableDictionary *)hints {
  return [self maybeReturnResult:[ean13Reader decodeRow:rowNumber param1:row param2:startGuardRange param3:hints]];
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints {
  return [self maybeReturnResult:[ean13Reader decodeRow:rowNumber param1:row param2:hints]];
}

- (Result *) decode:(BinaryBitmap *)image {
  return [self maybeReturnResult:[ean13Reader decode:image]];
}

- (Result *) decode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints {
  return [self maybeReturnResult:[ean13Reader decode:image param1:hints]];
}

- (BarcodeFormat *) getBarcodeFormat {
  return BarcodeFormat.UPC_A;
}

- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange resultString:(NSMutableString *)resultString {
  return [ean13Reader decodeMiddle:row param1:startRange param2:resultString];
}

+ (Result *) maybeReturnResult:(Result *)result {
  NSString * text = [result text];
  if ([text characterAtIndex:0] == '0') {
    return [[[Result alloc] init:[text substringFromIndex:1] param1:nil param2:[result resultPoints] param3:BarcodeFormat.UPC_A] autorelease];
  }
   else {
    @throw [FormatException formatInstance];
  }
}

- (void) dealloc {
  [ean13Reader release];
  [super dealloc];
}

@end
