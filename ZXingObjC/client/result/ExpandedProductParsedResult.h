/**
 * @author Antonio Manuel Benjumea Conde, Servinform, S.A.
 * @author Agustín Delgado, Servinform, S.A.
 */

extern NSString * const KILOGRAM;
extern NSString * const POUND;

@interface ExpandedProductParsedResult : ParsedResult {
  NSString * productID;
  NSString * sscc;
  NSString * lotNumber;
  NSString * productionDate;
  NSString * packagingDate;
  NSString * bestBeforeDate;
  NSString * expirationDate;
  NSString * weight;
  NSString * weightType;
  NSString * weightIncrement;
  NSString * price;
  NSString * priceIncrement;
  NSString * priceCurrency;
  NSMutableDictionary * uncommonAIs;
}

@property(nonatomic, retain, readonly) NSString * productID;
@property(nonatomic, retain, readonly) NSString * sscc;
@property(nonatomic, retain, readonly) NSString * lotNumber;
@property(nonatomic, retain, readonly) NSString * productionDate;
@property(nonatomic, retain, readonly) NSString * packagingDate;
@property(nonatomic, retain, readonly) NSString * bestBeforeDate;
@property(nonatomic, retain, readonly) NSString * expirationDate;
@property(nonatomic, retain, readonly) NSString * weight;
@property(nonatomic, retain, readonly) NSString * weightType;
@property(nonatomic, retain, readonly) NSString * weightIncrement;
@property(nonatomic, retain, readonly) NSString * price;
@property(nonatomic, retain, readonly) NSString * priceIncrement;
@property(nonatomic, retain, readonly) NSString * priceCurrency;
@property(nonatomic, retain, readonly) NSMutableDictionary * uncommonAIs;
@property(nonatomic, retain, readonly) NSString * displayResult;
- (id) init;
- (id) init:(NSString *)productID sscc:(NSString *)sscc lotNumber:(NSString *)lotNumber productionDate:(NSString *)productionDate packagingDate:(NSString *)packagingDate bestBeforeDate:(NSString *)bestBeforeDate expirationDate:(NSString *)expirationDate weight:(NSString *)weight weightType:(NSString *)weightType weightIncrement:(NSString *)weightIncrement price:(NSString *)price priceIncrement:(NSString *)priceIncrement priceCurrency:(NSString *)priceCurrency uncommonAIs:(NSMutableDictionary *)uncommonAIs;
- (BOOL) isEqualTo:(NSObject *)o;
- (int) hash;
@end
