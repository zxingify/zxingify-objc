#import "ZXEAN13Reader.h"
#import "ZXErrors.h"
#import "ZXResult.h"
#import "ZXUPCAReader.h"

@interface ZXUPCAReader ()

@property (nonatomic, retain) ZXUPCEANReader * ean13Reader;

- (ZXResult *)maybeReturnResult:(ZXResult *)result;

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

- (ZXResult *)decodeRow:(int)rowNumber row:(ZXBitArray *)row startGuardRange:(NSArray *)startGuardRange hints:(ZXDecodeHints *)hints error:(NSError **)error {
  ZXResult* result = [self.ean13Reader decodeRow:rowNumber row:row startGuardRange:startGuardRange hints:hints error:error];
  if (result) {
    result = [self maybeReturnResult:result];
    if (!result) {
      if (error) *error = FormatErrorInstance();
      return nil;
    }
    return result;
  } else {
    return nil;
  }
}

- (ZXResult *)decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(ZXDecodeHints *)hints error:(NSError **)error {
  ZXResult* result = [self.ean13Reader decodeRow:rowNumber row:row hints:hints error:error];
  if (result) {
    result = [self maybeReturnResult:result];
    if (!result) {
      if (error) *error = FormatErrorInstance();
      return nil;
    }
    return result;
  } else {
    return nil;
  }
}

- (ZXResult *)decode:(ZXBinaryBitmap *)image error:(NSError **)error {
  ZXResult* result = [self.ean13Reader decode:image error:error];
  if (result) {
    result = [self maybeReturnResult:result];
    if (!result) {
      if (error) *error = FormatErrorInstance();
      return nil;
    }
    return result;
  } else {
    return nil;
  }
}

- (ZXResult *)decode:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints error:(NSError **)error {
  ZXResult* result = [self.ean13Reader decode:image hints:hints error:error];
  if (result) {
    result = [self maybeReturnResult:result];
    if (!result) {
      if (error) *error = FormatErrorInstance();
      return nil;
    }
    return result;
  } else {
    return nil;
  }
}

- (ZXBarcodeFormat)barcodeFormat {
  return kBarcodeFormatUPCA;
}

- (int)decodeMiddle:(ZXBitArray *)row startRange:(NSArray *)startRange result:(NSMutableString *)result error:(NSError **)error {
  return [self.ean13Reader decodeMiddle:row startRange:startRange result:result error:error];
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
    return nil;
  }
}

@end
