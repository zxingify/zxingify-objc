#import "ZXParsedResult.h"

/**
 * @author jbreiden@google.com (Jeff Breidenbach)
 */

@interface ZXISBNParsedResult : ZXParsedResult {
  NSString * isbn;
}

@property(nonatomic, retain, readonly) NSString * isbn;
@property(nonatomic, retain, readonly) NSString * displayResult;
- (id) initWithIsbn:(NSString *)isbn;
@end
