#import "ZXParsedResult.h"

@interface ZXAddressBookParsedResult : ZXParsedResult

@property (nonatomic, readonly, retain) NSArray * names;
@property (nonatomic, readonly, copy) NSString * pronunciation;
@property (nonatomic, readonly, retain) NSArray * phoneNumbers;
@property (nonatomic, readonly, retain) NSArray * emails;
@property (nonatomic, readonly, copy) NSString * note;
@property (nonatomic, readonly, retain) NSArray * addresses;
@property (nonatomic, readonly, copy) NSString * title;
@property (nonatomic, readonly, copy) NSString * org;
@property (nonatomic, readonly, copy) NSString * url;
@property (nonatomic, readonly, copy) NSString * birthday;

- (id)initWithNames:(NSArray *)names
      pronunciation:(NSString *)pronunciation
       phoneNumbers:(NSArray *)phoneNumbers
             emails:(NSArray *)emails
               note:(NSString *)note
          addresses:(NSArray *)addresses
                org:(NSString *)org
           birthday:(NSString *)birthday
              title:(NSString *)title
                url:(NSString *)url;

@end
