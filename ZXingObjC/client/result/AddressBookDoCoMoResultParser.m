#import "AddressBookDoCoMoResultParser.h"

@implementation AddressBookDoCoMoResultParser

+ (AddressBookParsedResult *) parse:(Result *)result {
  NSString * rawText = [result text];
  if (rawText == nil || ![rawText hasPrefix:@"MECARD:"]) {
    return nil;
  }
  NSArray * rawName = [self matchDoCoMoPrefixedField:@"N:" param1:rawText param2:YES];
  if (rawName == nil) {
    return nil;
  }
  NSString * name = [self parseName:rawName[0]];
  NSString * pronunciation = [self matchSingleDoCoMoPrefixedField:@"SOUND:" param1:rawText param2:YES];
  NSArray * phoneNumbers = [self matchDoCoMoPrefixedField:@"TEL:" param1:rawText param2:YES];
  NSArray * emails = [self matchDoCoMoPrefixedField:@"EMAIL:" param1:rawText param2:YES];
  NSString * note = [self matchSingleDoCoMoPrefixedField:@"NOTE:" param1:rawText param2:NO];
  NSArray * addresses = [self matchDoCoMoPrefixedField:@"ADR:" param1:rawText param2:YES];
  NSString * birthday = [self matchSingleDoCoMoPrefixedField:@"BDAY:" param1:rawText param2:YES];
  if (birthday != nil && ![self isStringOfDigits:birthday param1:8]) {
    birthday = nil;
  }
  NSString * url = [self matchSingleDoCoMoPrefixedField:@"URL:" param1:rawText param2:YES];
  NSString * org = [self matchSingleDoCoMoPrefixedField:@"ORG:" param1:rawText param2:YES];
  return [[[AddressBookParsedResult alloc] init:[self maybeWrap:name] param1:pronunciation param2:phoneNumbers param3:emails param4:note param5:addresses param6:org param7:birthday param8:nil param9:url] autorelease];
}

+ (NSString *) parseName:(NSString *)name {
  int comma = [name rangeOfString:(int)','];
  if (comma >= 0) {
    return [name substringFromIndex:comma + 1] + ' ' + [name substringFromIndex:0 param1:comma];
  }
  return name;
}

@end
