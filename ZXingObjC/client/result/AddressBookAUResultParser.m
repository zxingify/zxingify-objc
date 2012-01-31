#import "AddressBookAUResultParser.h"
#import "AddressBookParsedResult.h"
#import "Result.h"

@implementation AddressBookAUResultParser

+ (AddressBookParsedResult *) parse:(Result *)result {
  NSString * rawText = [result text];
  if (rawText == nil || [rawText rangeOfString:@"MEMORY"] < 0 || [rawText rangeOfString:@"\r\n"] < 0) {
    return nil;
  }
  NSString * name = [self matchSinglePrefixedField:@"NAME1:" param1:rawText param2:'\r' param3:YES];
  NSString * pronunciation = [self matchSinglePrefixedField:@"NAME2:" param1:rawText param2:'\r' param3:YES];
  NSArray * phoneNumbers = [self matchMultipleValuePrefix:@"TEL" max:3 rawText:rawText trim:YES];
  NSArray * emails = [self matchMultipleValuePrefix:@"MAIL" max:3 rawText:rawText trim:YES];
  NSString * note = [self matchSinglePrefixedField:@"MEMORY:" param1:rawText param2:'\r' param3:NO];
  NSString * address = [self matchSinglePrefixedField:@"ADD:" param1:rawText param2:'\r' param3:YES];
  NSArray * addresses = address == nil ? nil : [NSArray arrayWithObjects:address, nil];
  return [[[AddressBookParsedResult alloc] init:[self maybeWrap:name] param1:pronunciation param2:phoneNumbers param3:emails param4:note param5:addresses param6:nil param7:nil param8:nil param9:nil] autorelease];
}

+ (NSArray *) matchMultipleValuePrefix:(NSString *)prefix max:(int)max rawText:(NSString *)rawText trim:(BOOL)trim {
  NSMutableArray * values = nil;

  for (int i = 1; i <= max; i++) {
    NSString * value = [self matchSinglePrefixedField:[prefix stringByAppendingString:i] + ':' param1:rawText param2:'\r' param3:trim];
    if (value == nil) {
      break;
    }
    if (values == nil) {
      values = [[[NSMutableArray alloc] init:max] autorelease];
    }
    [values addObject:value];
  }

  if (values == nil) {
    return nil;
  }
  return [self toStringArray:values];
}

@end
