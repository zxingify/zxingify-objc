#import "AddressBookAUResultParser.h"
#import "AddressBookParsedResult.h"
#import "Result.h"

@interface AddressBookAUResultParser ()

+ (NSArray *) matchMultipleValuePrefix:(NSString *)prefix max:(int)max rawText:(NSString *)rawText trim:(BOOL)trim;

@end

@implementation AddressBookAUResultParser

+ (AddressBookParsedResult *) parse:(Result *)result {
  NSString * rawText = [result text];

  if (rawText == nil || [rawText rangeOfString:@"MEMORY"].location == NSNotFound || [rawText rangeOfString:@"\r\n"].location == NSNotFound) {
    return nil;
  }

  NSString * name = [self matchSinglePrefixedField:@"NAME1:" rawText:rawText endChar:'\r' trim:YES];
  NSString * pronunciation = [self matchSinglePrefixedField:@"NAME2:" rawText:rawText endChar:'\r' trim:YES];
  NSArray * phoneNumbers = [self matchMultipleValuePrefix:@"TEL" max:3 rawText:rawText trim:YES];
  NSArray * emails = [self matchMultipleValuePrefix:@"MAIL" max:3 rawText:rawText trim:YES];
  NSString * note = [self matchSinglePrefixedField:@"MEMORY:" rawText:rawText endChar:'\r' trim:NO];
  NSString * address = [self matchSinglePrefixedField:@"ADD:" rawText:rawText endChar:'\r' trim:YES];
  NSArray * addresses = address == nil ? nil : [NSArray arrayWithObjects:address, nil];
  return [[[AddressBookParsedResult alloc] init:[self maybeWrap:name]
                                  pronunciation:pronunciation
                                   phoneNumbers:phoneNumbers
                                         emails:emails
                                           note:note
                                      addresses:addresses
                                            org:nil
                                       birthday:nil
                                          title:nil
                                            url:nil] autorelease];
}

+ (NSArray *) matchMultipleValuePrefix:(NSString *)prefix max:(int)max rawText:(NSString *)rawText trim:(BOOL)trim {
  NSMutableArray * values = nil;

  for (int i = 1; i <= max; i++) {
    NSString * value = [self matchSinglePrefixedField:[NSString stringWithFormat:@"%@%d:", prefix, i]
                                              rawText:rawText
                                              endChar:'\r'
                                                 trim:trim];
    if (value == nil) {
      break;
    }
    if (values == nil) {
      values = [[[NSMutableArray alloc] initWithCapacity:max] autorelease];
    }
    [values addObject:value];
  }

  if (values == nil) {
    return nil;
  }
  return [self toStringArray:values];
}

@end
