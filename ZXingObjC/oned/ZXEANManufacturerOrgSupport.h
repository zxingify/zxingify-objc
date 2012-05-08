/**
 * Records EAN prefix to GS1 Member Organization, where the member organization
 * correlates strongly with a country. This is an imperfect means of identifying
 * a country of origin by EAN-13 barcode value. See
 * http://en.wikipedia.org/wiki/List_of_GS1_country_codes
 */

@interface ZXEANManufacturerOrgSupport : NSObject

- (NSString *)lookupCountryIdentifier:(NSString *)productCode;

@end
