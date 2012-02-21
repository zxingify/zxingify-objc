#import "AbstractExpandedDecoder.h"
#import "AI013103decoder.h"
#import "AI01320xDecoder.h"
#import "AI01392xDecoder.h"
#import "AI01393xDecoder.h"
#import "AI013x0x1xDecoder.h"
#import "AI01AndOtherAIs.h"
#import "AnyAIDecoder.h"
#import "BitArray.h"
#import "GeneralAppIdDecoder.h"

@implementation AbstractExpandedDecoder

- (id) initWithInformation:(BitArray *)anInformation {
  if (self = [super init]) {
    information = [anInformation retain];
    generalDecoder = [[GeneralAppIdDecoder alloc] initWithInformation:information];
  }
  return self;
}

- (NSString *) parseInformation {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

+ (AbstractExpandedDecoder *) createDecoder:(BitArray *)information {
  if ([information get:1]) {
    return [[[AI01AndOtherAIs alloc] initWithInformation:information] autorelease];
  } else if (![information get:2]) {
    return [[[AnyAIDecoder alloc] initWithInformation:information] autorelease];
  }

  int fourBitEncodationMethod = [GeneralAppIdDecoder extractNumericValueFromBitArray:information pos:1 bits:4];

  switch (fourBitEncodationMethod) {
  case 4:
    return [[[AI013103decoder alloc] initWithInformation:information] autorelease];
  case 5:
    return [[[AI01320xDecoder alloc] initWithInformation:information] autorelease];
  }

  int fiveBitEncodationMethod = [GeneralAppIdDecoder extractNumericValueFromBitArray:information pos:1 bits:5];
  switch (fiveBitEncodationMethod) {
  case 12:
    return [[[AI01392xDecoder alloc] initWithInformation:information] autorelease];
  case 13:
    return [[[AI01393xDecoder alloc] initWithInformation:information] autorelease];
  }
  
  int sevenBitEncodationMethod = [GeneralAppIdDecoder extractNumericValueFromBitArray:information pos:1 bits:7];
  switch (sevenBitEncodationMethod) {
  case 56:
    return [[[AI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"310" dateCode:@"11"] autorelease];
  case 57:
    return [[[AI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"320" dateCode:@"11"] autorelease];
  case 58:
    return [[[AI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"310" dateCode:@"13"] autorelease];
  case 59:
    return [[[AI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"320" dateCode:@"13"] autorelease];
  case 60:
    return [[[AI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"310" dateCode:@"15"] autorelease];
  case 61:
    return [[[AI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"320" dateCode:@"15"] autorelease];
  case 62:
    return [[[AI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"310" dateCode:@"17"] autorelease];
  case 63:
    return [[[AI013x0x1xDecoder alloc] initWithInformation:information firstAIdigits:@"320" dateCode:@"17"] autorelease];
  }

  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"unknown decoder: %@", information]
                               userInfo:nil];
}

- (void) dealloc {
  [information release];
  [generalDecoder release];
  [super dealloc];
}

@end
