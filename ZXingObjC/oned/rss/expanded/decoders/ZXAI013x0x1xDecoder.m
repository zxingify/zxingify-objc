#import "ZXAI013x0x1xDecoder.h"
#import "ZXBitArray.h"
#import "ZXGeneralAppIdDecoder.h"
#import "ZXNotFoundException.h"

int const AI013x0x1xHeaderSize = 7 + 1;
int const AI013x0x1xWeightSize = 20;
int const AI013x0x1xDateSize = 16;

@interface ZXAI013x0x1xDecoder ()

- (void) encodeCompressedDate:(NSMutableString *)buf currentPos:(int)currentPos;

@end

@implementation ZXAI013x0x1xDecoder

- (id) initWithInformation:(ZXBitArray *)anInformation firstAIdigits:(NSString *)aFirstAIdigits dateCode:(NSString *)aDateCode {
  if (self = [super initWithInformation:anInformation]) {
    dateCode = [aDateCode copy];
    firstAIdigits = [aFirstAIdigits copy];
  }
  return self;
}

- (NSString *) parseInformation {
  if (information.size != AI013x0x1xHeaderSize + gtinSize + AI013x0x1xWeightSize + AI013x0x1xDateSize) {
    @throw [ZXNotFoundException notFoundInstance];
  }
  NSMutableString * buf = [NSMutableString string];
  [self encodeCompressedGtin:buf currentPos:AI013x0x1xHeaderSize];
  [self encodeCompressedWeight:buf currentPos:AI013x0x1xHeaderSize + gtinSize weightSize:AI013x0x1xWeightSize];
  [self encodeCompressedDate:buf currentPos:AI013x0x1xHeaderSize + gtinSize + AI013x0x1xWeightSize];
  return [buf description];
}

- (void) encodeCompressedDate:(NSMutableString *)buf currentPos:(int)currentPos {
  int numericDate = [generalDecoder extractNumericValueFromBitArray:currentPos bits:AI013x0x1xDateSize];
  if (numericDate == 38400) {
    return;
  }
  [buf appendFormat:@"(%@)", dateCode];
  int day = numericDate % 32;
  numericDate /= 32;
  int month = numericDate % 12 + 1;
  numericDate /= 12;
  int year = numericDate;
  if (year / 10 == 0) {
    [buf appendString:@"0"];
  }
  [buf appendFormat:@"%d", year];
  if (month / 10 == 0) {
    [buf appendString:@"0"];
  }
  [buf appendFormat:@"%d", month];
  if (day / 10 == 0) {
    [buf appendString:@"0"];
  }
  [buf appendFormat:@"%d", day];
}

- (void) addWeightCode:(NSMutableString *)buf weight:(int)weight {
  int lastAI = weight / 100000;
  [buf appendFormat:@"(%@%d)", firstAIdigits, lastAI];
}

- (int) checkWeight:(int)weight {
  return weight % 100000;
}

- (void) dealloc {
  [dateCode release];
  [firstAIdigits release];
  [super dealloc];
}

@end
