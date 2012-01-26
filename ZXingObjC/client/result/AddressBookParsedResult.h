#import "ParsedResult.h"

/**
 * @author Sean Owen
 */

@interface AddressBookParsedResult : ParsedResult

@property(nonatomic, retain) NSArray * names;
@property(nonatomic, copy) NSString * pronunciation;
@property(nonatomic, retain) NSArray * phoneNumbers;
@property(nonatomic, retain) NSArray * emails;
@property(nonatomic, copy) NSString * note;
@property(nonatomic, retain) NSArray * addresses;
@property(nonatomic, copy) NSString * title;
@property(nonatomic, copy) NSString * org;
@property(nonatomic, copy) NSString * uRL;
@property(nonatomic, copy) NSString * birthday;

- (id) init:(NSArray *)names pronunciation:(NSString *)pronunciation phoneNumbers:(NSArray *)phoneNumbers emails:(NSArray *)emails note:(NSString *)note addresses:(NSArray *)addresses org:(NSString *)org birthday:(NSString *)birthday title:(NSString *)title url:(NSString *)url;

- (NSString *) displayResult;

@end
