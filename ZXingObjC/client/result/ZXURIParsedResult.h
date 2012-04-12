#import "ZXParsedResult.h"

/**
 * @author Sean Owen
 */

@interface ZXURIParsedResult : ZXParsedResult {
  NSString * uri;
  NSString * title;
}

@property(nonatomic, retain, readonly) NSString * uri;
@property(nonatomic, retain, readonly) NSString * title;
@property(nonatomic, readonly) BOOL possiblyMaliciousURI;
@property(nonatomic, retain, readonly) NSString * displayResult;

- (id) initWithUri:(NSString *)uri title:(NSString *)title;

@end
