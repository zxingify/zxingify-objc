/**
 * Records EAN prefix to GS1 Member Organization, where the member organization
 * correlates strongly with a country. This is an imperfect means of identifying
 * a country of origin by EAN-13 barcode value. See
 * <a href="http://en.wikipedia.org/wiki/List_of_GS1_country_codes">
 * http://en.wikipedia.org/wiki/List_of_GS1_country_codes</a>.
 * 
 * @author Sean Owen
 */

@interface EANManufacturerOrgSupport : NSObject {
  NSMutableArray * ranges;
  NSMutableArray * countryIdentifiers;
}

- (NSString *) lookupCountryIdentifier:(NSString *)productCode;

@end
