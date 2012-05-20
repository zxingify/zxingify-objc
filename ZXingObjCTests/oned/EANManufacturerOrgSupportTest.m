#import "EANManufacturerOrgSupportTest.h"
#import "ZXEANManufacturerOrgSupport.h"

@implementation EANManufacturerOrgSupportTest

- (void)testEncode {
  ZXEANManufacturerOrgSupport* support = [[[ZXEANManufacturerOrgSupport alloc] init] autorelease];
  STAssertNil([support lookupCountryIdentifier:@"472000"], @"Expected country identifier to be nil");
  STAssertEqualObjects([support lookupCountryIdentifier:@"000000"], @"US/CA", @"Expected country identifier to be US/CA");
  STAssertEqualObjects([support lookupCountryIdentifier:@"958000"], @"MO", @"Expected country identifier to be MO");
  STAssertEqualObjects([support lookupCountryIdentifier:@"500000"], @"GB", @"Expected country identifier to be GB");
  STAssertEqualObjects([support lookupCountryIdentifier:@"509000"], @"GB", @"Expected country identifier to be GB");
}

@end
