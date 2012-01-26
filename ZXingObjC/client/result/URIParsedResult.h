
/**
 * @author Sean Owen
 */

@interface URIParsedResult : ParsedResult {
  NSString * uri;
  NSString * title;
}

@property(nonatomic, retain, readonly) NSString * uRI;
@property(nonatomic, retain, readonly) NSString * title;
@property(nonatomic, readonly) BOOL possiblyMaliciousURI;
@property(nonatomic, retain, readonly) NSString * displayResult;
- (id) init:(NSString *)uri title:(NSString *)title;
@end
