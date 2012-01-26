
/**
 * @author Sean Owen
 */

@interface AddressBookParsedResult : ParsedResult {
  NSArray * names;
  NSString * pronunciation;
  NSArray * phoneNumbers;
  NSArray * emails;
  NSString * note;
  NSArray * addresses;
  NSString * org;
  NSString * birthday;
  NSString * title;
  NSString * url;
}

@property(nonatomic, retain, readonly) NSArray * names;
@property(nonatomic, retain, readonly) NSString * pronunciation;
@property(nonatomic, retain, readonly) NSArray * phoneNumbers;
@property(nonatomic, retain, readonly) NSArray * emails;
@property(nonatomic, retain, readonly) NSString * note;
@property(nonatomic, retain, readonly) NSArray * addresses;
@property(nonatomic, retain, readonly) NSString * title;
@property(nonatomic, retain, readonly) NSString * org;
@property(nonatomic, retain, readonly) NSString * uRL;
@property(nonatomic, retain, readonly) NSString * birthday;
@property(nonatomic, retain, readonly) NSString * displayResult;
- (id) init:(NSArray *)names pronunciation:(NSString *)pronunciation phoneNumbers:(NSArray *)phoneNumbers emails:(NSArray *)emails note:(NSString *)note addresses:(NSArray *)addresses org:(NSString *)org birthday:(NSString *)birthday title:(NSString *)title url:(NSString *)url;
@end
