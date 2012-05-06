#import "ZXParsedResult.h"

@interface ZXEmailAddressParsedResult : ZXParsedResult

@property (nonatomic, copy, readonly) NSString * emailAddress;
@property (nonatomic, copy, readonly) NSString * subject;
@property (nonatomic, copy, readonly) NSString * body;
@property (nonatomic, copy, readonly) NSString * mailtoURI;

- (id)initWithEmailAddress:(NSString *)emailAddress subject:(NSString *)subject body:(NSString *)body mailtoURI:(NSString *)mailtoURI;

@end
