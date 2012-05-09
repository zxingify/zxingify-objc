#import "ZXEAN13Reader.h"
#import "ZXFormatException.h"
#import "ZXResult.h"
#import "ZXUPCAReader.h"

@interface ZXUPCAReader ()

@property (nonatomic, retain) ZXUPCEANReader * ean13Reader;

- (ZXResult *) maybeReturnResult:(ZXResult *)result;

@end

@implementation ZXUPCAReader

@synthesize ean13Reader;

- (id)init {
  if (self = [super init]) {
    self.ean13Reader = [[[ZXEAN13Reader alloc] init] autorelease];
  }

  return self;
}

- (void)dealloc {
  [ean13Reader release];

  [super dealloc];
}

- (ZXResult *)decodeRow:(int)rowNumber row:(ZXBitArray *)row startGuardRange:(NSArray *)startGuardRange hints:(ZXDecodeHints *)hints {
  return [self maybeReturnResult:[self.ean13Reader decodeRow:rowNumber row:row startGuardRange:startGuardRange hints:hints]];
}

- (ZXResult *)decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(ZXDecodeHints *)hints {
  return [self maybeReturnResult:[self.ean13Reader decodeRow:rowNumber row:row hints:hints]];
}

- (ZXResult *)decode:(ZXBinaryBitmap *)image {
  return [self maybeReturnResult:[self.ean13Reader decode:image]];
}

- (ZXResult *)decode:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints {
  return [self maybeReturnResult:[self.ean13Reader decode:image hints:hints]];
}

- (ZXBarcodeFormat)barcodeFormat {
  return kBarcodeFormatUPCA;
}

- (int)decodeMiddle:(ZXBitArray *)row startRange:(NSArray *)startRange result:(NSMutableString *)result {
  return [self.ean13Reader decodeMiddle:row startRange:startRange result:result];
}

- (ZXResult *)maybeReturnResult:(ZXResult *)result {
  NSString * text = result.text;
  if ([text characterAtIndex:0] == '0') {
    return [[[ZXResult alloc] initWithText:[text substringFromIndex:1]
                                  rawBytes:NULL
                                    length:0
                              resultPoints:result.resultPoints
                                    format:kBarcodeFormatUPCA] autorelease];
  } else {
    @throw [ZXFormatException formatInstance];
  }
}

@end
