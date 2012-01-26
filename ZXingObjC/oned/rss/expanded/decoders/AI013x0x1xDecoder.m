#import "AI013x0x1xDecoder.h"

int const headerSize = 7 + 1;
int const weightSize = 20;
int const dateSize = 16;

@implementation AI013x0x1xDecoder

- (id) init:(BitArray *)information firstAIdigits:(NSString *)firstAIdigits dateCode:(NSString *)dateCode {
  if (self = [super init:information]) {
    dateCode = dateCode;
    firstAIdigits = firstAIdigits;
  }
  return self;
}

- (NSString *) parseInformation {
  if (information.size != headerSize + gtinSize + weightSize + dateSize) {
    @throw [NotFoundException notFoundInstance];
  }
  StringBuffer * buf = [[[StringBuffer alloc] init] autorelease];
  [self encodeCompressedGtin:buf param1:headerSize];
  [self encodeCompressedWeight:buf param1:headerSize + gtinSize param2:weightSize];
  [self encodeCompressedDate:buf currentPos:headerSize + gtinSize + weightSize];
  return [buf description];
}

- (void) encodeCompressedDate:(StringBuffer *)buf currentPos:(int)currentPos {
  int numericDate = [generalDecoder extractNumericValueFromBitArray:currentPos param1:dateSize];
  if (numericDate == 38400) {
    return;
  }
  [buf append:'('];
  [buf append:dateCode];
  [buf append:')'];
  int day = numericDate % 32;
  numericDate /= 32;
  int month = numericDate % 12 + 1;
  numericDate /= 12;
  int year = numericDate;
  if (year / 10 == 0) {
    [buf append:'0'];
  }
  [buf append:year];
  if (month / 10 == 0) {
    [buf append:'0'];
  }
  [buf append:month];
  if (day / 10 == 0) {
    [buf append:'0'];
  }
  [buf append:day];
}

- (void) addWeightCode:(StringBuffer *)buf weight:(int)weight {
  int lastAI = weight / 100000;
  [buf append:'('];
  [buf append:firstAIdigits];
  [buf append:lastAI];
  [buf append:')'];
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
