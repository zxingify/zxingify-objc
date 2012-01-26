#import "AbstractExpandedDecoder.h"

@implementation AbstractExpandedDecoder

- (id) initWithInformation:(BitArray *)information {
  if (self = [super init]) {
    information = information;
    generalDecoder = [[[GeneralAppIdDecoder alloc] init:information] autorelease];
  }
  return self;
}

- (NSString *) parseInformation {
}

+ (AbstractExpandedDecoder *) createDecoder:(BitArray *)information {
  if ([information get:1]) {
    return [[[AI01AndOtherAIs alloc] init:information] autorelease];
  }
   else if (![information get:2]) {
    return [[[AnyAIDecoder alloc] init:information] autorelease];
  }
  int fourBitEncodationMethod = [GeneralAppIdDecoder extractNumericValueFromBitArray:information param1:1 param2:4];

  switch (fourBitEncodationMethod) {
  case 4:
    return [[[AI013103decoder alloc] init:information] autorelease];
  case 5:
    return [[[AI01320xDecoder alloc] init:information] autorelease];
  }
  int fiveBitEncodationMethod = [GeneralAppIdDecoder extractNumericValueFromBitArray:information param1:1 param2:5];

  switch (fiveBitEncodationMethod) {
  case 12:
    return [[[AI01392xDecoder alloc] init:information] autorelease];
  case 13:
    return [[[AI01393xDecoder alloc] init:information] autorelease];
  }
  int sevenBitEncodationMethod = [GeneralAppIdDecoder extractNumericValueFromBitArray:information param1:1 param2:7];

  switch (sevenBitEncodationMethod) {
  case 56:
    return [[[AI013x0x1xDecoder alloc] init:information param1:@"310" param2:@"11"] autorelease];
  case 57:
    return [[[AI013x0x1xDecoder alloc] init:information param1:@"320" param2:@"11"] autorelease];
  case 58:
    return [[[AI013x0x1xDecoder alloc] init:information param1:@"310" param2:@"13"] autorelease];
  case 59:
    return [[[AI013x0x1xDecoder alloc] init:information param1:@"320" param2:@"13"] autorelease];
  case 60:
    return [[[AI013x0x1xDecoder alloc] init:information param1:@"310" param2:@"15"] autorelease];
  case 61:
    return [[[AI013x0x1xDecoder alloc] init:information param1:@"320" param2:@"15"] autorelease];
  case 62:
    return [[[AI013x0x1xDecoder alloc] init:information param1:@"310" param2:@"17"] autorelease];
  case 63:
    return [[[AI013x0x1xDecoder alloc] init:information param1:@"320" param2:@"17"] autorelease];
  }
  @throw [[[IllegalStateException alloc] init:[@"unknown decoder: " stringByAppendingString:information]] autorelease];
}

- (void) dealloc {
  [information release];
  [generalDecoder release];
  [super dealloc];
}

@end
