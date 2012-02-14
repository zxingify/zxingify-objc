#import "AI013x0x1xDecoder.h"
#import "BitArray.h"
#import "GeneralAppIdDecoder.h"
#import "NotFoundException.h"

int const headerSize = 7 + 1;
int const weightSize = 20;
int const dateSize = 16;

@interface AI013x0x1xDecoder ()

- (void) encodeCompressedDate:(NSMutableString *)buf currentPos:(int)currentPos;

@end

@implementation AI013x0x1xDecoder

- (id) initWithInformation:(BitArray *)anInformation firstAIdigits:(NSString *)aFirstAIdigits dateCode:(NSString *)aDateCode {
  if (self = [super initWithInformation:anInformation]) {
    dateCode = [aDateCode copy];
    firstAIdigits = [aFirstAIdigits copy];
  }
  return self;
}

- (NSString *) parseInformation {
  if (information.size != headerSize + gtinSize + weightSize + dateSize) {
    @throw [NotFoundException notFoundInstance];
  }
  NSMutableString * buf = [NSMutableString string];
  [self encodeCompressedGtin:buf currentPos:headerSize];
  [self encodeCompressedWeight:buf currentPos:headerSize + gtinSize weightSize:weightSize];
  [self encodeCompressedDate:buf currentPos:headerSize + gtinSize + weightSize];
  return [buf description];
}

- (void) encodeCompressedDate:(NSMutableString *)buf currentPos:(int)currentPos {
  int numericDate = [generalDecoder extractNumericValueFromBitArray:currentPos bits:dateSize];
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
