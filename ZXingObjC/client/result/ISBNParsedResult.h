#import "ParsedResult.h"

/**
 * @author jbreiden@google.com (Jeff Breidenbach)
 */

@interface ISBNParsedResult : ParsedResult {
  NSString * isbn;
}

@property(nonatomic, retain, readonly) NSString * isbn;
@property(nonatomic, retain, readonly) NSString * displayResult;
- (id) initWithIsbn:(NSString *)isbn;
@end
