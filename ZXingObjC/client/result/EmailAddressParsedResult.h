#import "ParsedResult.h"

/**
 * @author Sean Owen
 */

@interface EmailAddressParsedResult : ParsedResult {
  NSString * emailAddress;
  NSString * subject;
  NSString * body;
  NSString * mailtoURI;
}

@property(nonatomic, retain, readonly) NSString * emailAddress;
@property(nonatomic, retain, readonly) NSString * subject;
@property(nonatomic, retain, readonly) NSString * body;
@property(nonatomic, retain, readonly) NSString * mailtoURI;
@property(nonatomic, retain, readonly) NSString * displayResult;
- (id) init:(NSString *)emailAddress subject:(NSString *)subject body:(NSString *)body mailtoURI:(NSString *)mailtoURI;
@end
