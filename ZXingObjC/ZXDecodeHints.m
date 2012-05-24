#import "ZXDecodeHints.h"
#import "ZXResultPointCallback.h"

@interface ZXDecodeHints ()

@property (nonatomic, retain) NSMutableArray* barcodeFormats;

@end

@implementation ZXDecodeHints

@synthesize assumeCode39CheckDigit;
@synthesize allowedLengths;
@synthesize barcodeFormats;
@synthesize encoding;
@synthesize other;
@synthesize pureBarcode;
@synthesize resultPointCallback;
@synthesize tryHarder;

+ (ZXDecodeHints*)hints {
  return [[[self alloc] init] autorelease];
}

- (id)init {
  if (self = [super init]) {
    self.barcodeFormats = [NSMutableArray array];
  }

  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  ZXDecodeHints *result = [[[self class] allocWithZone:zone] init];
  if (result) {
    result.assumeCode39CheckDigit = self.assumeCode39CheckDigit;
    result.allowedLengths = [[self.allowedLengths copy] autorelease];

    for (NSNumber *formatNumber in self.barcodeFormats) {
      [result addPossibleFormat:[formatNumber intValue]];
    }

    result.encoding = self.encoding;
    result.other = self.other;
    result.pureBarcode = self.pureBarcode;
    result.resultPointCallback = self.resultPointCallback;
    result.tryHarder = self.tryHarder;
  }

  return result;
}

- (void)dealloc {
  [allowedLengths release];
  [barcodeFormats release];
  [other release];
  [resultPointCallback release];

  [super dealloc];
}

- (void)addPossibleFormat:(ZXBarcodeFormat)format {
  [self.barcodeFormats addObject:[NSNumber numberWithInt:format]];
}

- (BOOL)containsFormat:(ZXBarcodeFormat)format {
  return [self.barcodeFormats containsObject:[NSNumber numberWithInt:format]];
}

- (int)numberOfPossibleFormats {
  return self.barcodeFormats.count;
}

- (void)removePossibleFormat:(ZXBarcodeFormat)format {
  [self.barcodeFormats removeObject:[NSNumber numberWithInt:format]];
}

@end