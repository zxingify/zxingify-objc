#import "BizcardResultParser.h"

@implementation BizcardResultParser

+ (AddressBookParsedResult *) parse:(Result *)result {
  NSString * rawText = [result text];
  if (rawText == nil || ![rawText hasPrefix:@"BIZCARD:"]) {
    return nil;
  }
  NSString * firstName = [self matchSingleDoCoMoPrefixedField:@"N:" param1:rawText param2:YES];
  NSString * lastName = [self matchSingleDoCoMoPrefixedField:@"X:" param1:rawText param2:YES];
  NSString * fullName = [self buildName:firstName lastName:lastName];
  NSString * title = [self matchSingleDoCoMoPrefixedField:@"T:" param1:rawText param2:YES];
  NSString * org = [self matchSingleDoCoMoPrefixedField:@"C:" param1:rawText param2:YES];
  NSArray * addresses = [self matchDoCoMoPrefixedField:@"A:" param1:rawText param2:YES];
  NSString * phoneNumber1 = [self matchSingleDoCoMoPrefixedField:@"B:" param1:rawText param2:YES];
  NSString * phoneNumber2 = [self matchSingleDoCoMoPrefixedField:@"M:" param1:rawText param2:YES];
  NSString * phoneNumber3 = [self matchSingleDoCoMoPrefixedField:@"F:" param1:rawText param2:YES];
  NSString * email = [self matchSingleDoCoMoPrefixedField:@"E:" param1:rawText param2:YES];
  return [[[AddressBookParsedResult alloc] init:[self maybeWrap:fullName] param1:nil param2:[self buildPhoneNumbers:phoneNumber1 number2:phoneNumber2 number3:phoneNumber3] param3:[self maybeWrap:email] param4:nil param5:addresses param6:org param7:nil param8:title param9:nil] autorelease];
}

+ (NSArray *) buildPhoneNumbers:(NSString *)number1 number2:(NSString *)number2 number3:(NSString *)number3 {
  NSMutableArray * numbers = [[[NSMutableArray alloc] init:3] autorelease];
  if (number1 != nil) {
    [numbers addObject:number1];
  }
  if (number2 != nil) {
    [numbers addObject:number2];
  }
  if (number3 != nil) {
    [numbers addObject:number3];
  }
  int size = [numbers count];
  if (size == 0) {
    return nil;
  }
  NSArray * result = [NSArray array];

  for (int i = 0; i < size; i++) {
    result[i] = (NSString *)[numbers objectAtIndex:i];
  }

  return result;
}

+ (NSString *) buildName:(NSString *)firstName lastName:(NSString *)lastName {
  if (firstName == nil) {
    return lastName;
  }
   else {
    return lastName == nil ? firstName : [[firstName stringByAppendingString:' '] stringByAppendingString:lastName];
  }
}

@end
