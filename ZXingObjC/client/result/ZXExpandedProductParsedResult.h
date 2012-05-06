#import "ZXParsedResult.h"

extern NSString * const KILOGRAM;
extern NSString * const POUND;

@interface ZXExpandedProductParsedResult : ZXParsedResult

@property (nonatomic, copy, readonly) NSString * productID;
@property (nonatomic, copy, readonly) NSString * sscc;
@property (nonatomic, copy, readonly) NSString * lotNumber;
@property (nonatomic, copy, readonly) NSString * productionDate;
@property (nonatomic, copy, readonly) NSString * packagingDate;
@property (nonatomic, copy, readonly) NSString * bestBeforeDate;
@property (nonatomic, copy, readonly) NSString * expirationDate;
@property (nonatomic, copy, readonly) NSString * weight;
@property (nonatomic, copy, readonly) NSString * weightType;
@property (nonatomic, copy, readonly) NSString * weightIncrement;
@property (nonatomic, copy, readonly) NSString * price;
@property (nonatomic, copy, readonly) NSString * priceIncrement;
@property (nonatomic, copy, readonly) NSString * priceCurrency;
@property (nonatomic, retain, readonly) NSMutableDictionary * uncommonAIs;

- (id)initWithProductID:(NSString *)productID
                   sscc:(NSString *)sscc
              lotNumber:(NSString *)lotNumber
        productionDate:(NSString *)productionDate
          packagingDate:(NSString *)packagingDate
        bestBeforeDate:(NSString *)bestBeforeDate
        expirationDate:(NSString *)expirationDate
                weight:(NSString *)weight
            weightType:(NSString *)weightType
        weightIncrement:(NSString *)weightIncrement
                  price:(NSString *)price
        priceIncrement:(NSString *)priceIncrement
          priceCurrency:(NSString *)priceCurrency
            uncommonAIs:(NSMutableDictionary *)uncommonAIs;

@end
