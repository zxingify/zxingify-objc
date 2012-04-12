#import "ZXAddressBookParsedResult.h"
#import "ZXBizcardResultParser.h"
#import "ZXResult.h"

@interface ZXBizcardResultParser ()

+ (NSString *) buildName:(NSString *)firstName lastName:(NSString *)lastName;
+ (NSArray *) buildPhoneNumbers:(NSString *)number1 number2:(NSString *)number2 number3:(NSString *)number3;

@end

@implementation ZXBizcardResultParser

+ (ZXAddressBookParsedResult *) parse:(ZXResult *)result {
  NSString * rawText = [result text];
  if (rawText == nil || ![rawText hasPrefix:@"BIZCARD:"]) {
    return nil;
  }
  NSString * firstName = [self matchSingleDoCoMoPrefixedField:@"N:" rawText:rawText trim:YES];
  NSString * lastName = [self matchSingleDoCoMoPrefixedField:@"X:" rawText:rawText trim:YES];
  NSString * fullName = [self buildName:firstName lastName:lastName];
  NSString * title = [self matchSingleDoCoMoPrefixedField:@"T:" rawText:rawText trim:YES];
  NSString * org = [self matchSingleDoCoMoPrefixedField:@"C:" rawText:rawText trim:YES];
  NSArray * addresses = [self matchDoCoMoPrefixedField:@"A:" rawText:rawText trim:YES];
  NSString * phoneNumber1 = [self matchSingleDoCoMoPrefixedField:@"B:" rawText:rawText trim:YES];
  NSString * phoneNumber2 = [self matchSingleDoCoMoPrefixedField:@"M:" rawText:rawText trim:YES];
  NSString * phoneNumber3 = [self matchSingleDoCoMoPrefixedField:@"F:" rawText:rawText trim:YES];
  NSString * email = [self matchSingleDoCoMoPrefixedField:@"E:" rawText:rawText trim:YES];
  return [[[ZXAddressBookParsedResult alloc] init:[self maybeWrap:fullName]
                                    pronunciation:nil
                                     phoneNumbers:[self buildPhoneNumbers:phoneNumber1 number2:phoneNumber2 number3:phoneNumber3]
                                           emails:[self maybeWrap:email]
                                             note:nil
                                        addresses:addresses
                                              org:org
                                         birthday:nil
                                            title:title
                                              url:nil] autorelease];
}

+ (NSArray *) buildPhoneNumbers:(NSString *)number1 number2:(NSString *)number2 number3:(NSString *)number3 {
  NSMutableArray * numbers = [NSMutableArray arrayWithCapacity:3];
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
  NSMutableArray * result = [NSMutableArray arrayWithCapacity:size];

  for (int i = 0; i < size; i++) {
    [result addObject:[numbers objectAtIndex:i]];
  }

  return result;
}

+ (NSString *) buildName:(NSString *)firstName lastName:(NSString *)lastName {
  if (firstName == nil) {
    return lastName;
  }
   else {
    return lastName == nil ? firstName : [[firstName stringByAppendingString:@" "] stringByAppendingString:lastName];
  }
}

@end
