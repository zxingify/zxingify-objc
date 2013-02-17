/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXExpandedProductParsedResult.h"

NSString *const KILOGRAM = @"KG";
NSString *const POUND = @"LB";

@interface ZXExpandedProductParsedResult ()

@property (nonatomic, copy) NSString *rawText;
@property (nonatomic, copy) NSString *productID;
@property (nonatomic, copy) NSString *sscc;
@property (nonatomic, copy) NSString *lotNumber;
@property (nonatomic, copy) NSString *productionDate;
@property (nonatomic, copy) NSString *packagingDate;
@property (nonatomic, copy) NSString *bestBeforeDate;
@property (nonatomic, copy) NSString *expirationDate;
@property (nonatomic, copy) NSString *weight;
@property (nonatomic, copy) NSString *weightType;
@property (nonatomic, copy) NSString *weightIncrement;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *priceIncrement;
@property (nonatomic, copy) NSString *priceCurrency;
@property (nonatomic, retain) NSMutableDictionary *uncommonAIs;

- (BOOL)equalsOrNil:(id)o1 o2:(id)o2;

@end

@implementation ZXExpandedProductParsedResult

@synthesize rawText;
@synthesize productID;
@synthesize sscc;
@synthesize lotNumber;
@synthesize productionDate;
@synthesize packagingDate;
@synthesize bestBeforeDate;
@synthesize expirationDate;
@synthesize weight;
@synthesize weightType;
@synthesize weightIncrement;
@synthesize price;
@synthesize priceIncrement;
@synthesize priceCurrency;
@synthesize uncommonAIs;

- (id)init {
  return [self initWithRawText:@"" productID:@"" sscc:@"" lotNumber:@"" productionDate:@"" packagingDate:@"" bestBeforeDate:@""
                  expirationDate:@"" weight:@"" weightType:@"" weightIncrement:@"" price:@"" priceIncrement:@""
                   priceCurrency:@"" uncommonAIs:[NSMutableDictionary dictionary]];
}

- (id)initWithRawText:(NSString *)aRawText productID:(NSString *)aProductID sscc:(NSString *)anSscc lotNumber:(NSString *)aLotNumber
       productionDate:(NSString *)aProductionDate packagingDate:(NSString *)aPackagingDate bestBeforeDate:(NSString *)aBestBeforeDate
       expirationDate:(NSString *)anExpirationDate weight:(NSString *)aWeight weightType:(NSString *)aWeightType
      weightIncrement:(NSString *)aWeightIncrement price:(NSString *)aPrice priceIncrement:(NSString *)aPriceIncrement
        priceCurrency:(NSString *)aPriceCurrency uncommonAIs:(NSMutableDictionary *)theUncommonAIs {
  if (self = [super initWithType:kParsedResultTypeProduct]) {
    self.rawText = aRawText;
    self.productID = aProductID;
    self.sscc = anSscc;
    self.lotNumber = aLotNumber;
    self.productionDate = aProductionDate;
    self.packagingDate = aPackagingDate;
    self.bestBeforeDate = aBestBeforeDate;
    self.expirationDate = anExpirationDate;
    self.weight = aWeight;
    self.weightType = aWeightType;
    self.weightIncrement = aWeightIncrement;
    self.price = aPrice;
    self.priceIncrement = aPriceIncrement;
    self.priceCurrency = aPriceCurrency;
    self.uncommonAIs = theUncommonAIs;
  }

  return self;
}

+ (id)expandedProductParsedResultWithRawText:(NSString *)rawText productID:(NSString *)productID sscc:(NSString *)sscc lotNumber:(NSString *)lotNumber
                              productionDate:(NSString *)productionDate packagingDate:(NSString *)packagingDate bestBeforeDate:(NSString *)bestBeforeDate
                              expirationDate:(NSString *)expirationDate weight:(NSString *)weight weightType:(NSString *)weightType
                             weightIncrement:(NSString *)weightIncrement price:(NSString *)price priceIncrement:(NSString *)priceIncrement
                               priceCurrency:(NSString *)priceCurrency uncommonAIs:(NSMutableDictionary *)uncommonAIs {
  return [[[self alloc] initWithRawText:rawText productID:productID sscc:sscc lotNumber:lotNumber productionDate:productionDate
                          packagingDate:packagingDate bestBeforeDate:bestBeforeDate expirationDate:expirationDate
                                 weight:weight weightType:weightType weightIncrement:weightIncrement price:price
                         priceIncrement:priceIncrement priceCurrency:priceCurrency uncommonAIs:uncommonAIs] autorelease];
}

- (void)dealloc {
  [rawText release];
  [productID release];
  [sscc release];
  [lotNumber release];
  [productionDate release];
  [packagingDate release];
  [bestBeforeDate release];
  [expirationDate release];
  [weight release];
  [weightType release];
  [weightIncrement release];
  [price release];
  [priceIncrement release];
  [priceCurrency release];
  [uncommonAIs release];

  [super dealloc];
}

- (BOOL)isEqual:(id)o {
  if (![o isKindOfClass:[self class]]) {
    return NO;
  }

  ZXExpandedProductParsedResult *other = (ZXExpandedProductParsedResult *)o;

  return [self equalsOrNil:productID o2:other.productID]
    && [self equalsOrNil:sscc o2:other.sscc]
    && [self equalsOrNil:lotNumber o2:other.lotNumber]
    && [self equalsOrNil:productionDate o2:other.productionDate]
    && [self equalsOrNil:bestBeforeDate o2:other.bestBeforeDate]
    && [self equalsOrNil:expirationDate o2:other.expirationDate]
    && [self equalsOrNil:weight o2:other.weight]
    && [self equalsOrNil:weightType o2:other.weightType]
    && [self equalsOrNil:weightIncrement o2:other.weightIncrement]
    && [self equalsOrNil:price o2:other.price]
    && [self equalsOrNil:priceIncrement o2:other.priceIncrement]
    && [self equalsOrNil:priceCurrency o2:other.priceCurrency]
    && [self equalsOrNil:uncommonAIs o2:other.uncommonAIs];
}

- (BOOL)equalsOrNil:(id)o1 o2:(id)o2 {
  return o1 == nil ? o2 == nil : [o1 isEqual:o2];
}

- (NSUInteger)hash {
  int hash = 0;
  hash ^= [productID hash];
  hash ^= [sscc hash];
  hash ^= [lotNumber hash];
  hash ^= [productionDate hash];
  hash ^= [bestBeforeDate hash];
  hash ^= [expirationDate hash];
  hash ^= [weight hash];
  hash ^= [weightType hash];
  hash ^= [weightIncrement hash];
  hash ^= [price hash];
  hash ^= [priceIncrement hash];
  hash ^= [priceCurrency hash];
  hash ^= [uncommonAIs hash];
  return hash;
}

- (NSString *)displayResult {
  return self.rawText;
}

@end
