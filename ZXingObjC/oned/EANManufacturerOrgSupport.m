#import "EANManufacturerOrgSupport.h"

@implementation EANManufacturerOrgSupport

- (void) init {
  if (self = [super init]) {
    ranges = [[[NSMutableArray alloc] init] autorelease];
    countryIdentifiers = [[[NSMutableArray alloc] init] autorelease];
  }
  return self;
}

- (NSString *) lookupCountryIdentifier:(NSString *)productCode {
  [self initIfNeeded];
  int prefix = [Integer parseInt:[productCode substringFromIndex:0 param1:3]];
  int max = [ranges count];

  for (int i = 0; i < max; i++) {
    NSArray * range = (NSArray *)[ranges objectAtIndex:i];
    int start = range[0];
    if (prefix < start) {
      return nil;
    }
    int end = range.length == 1 ? start : range[1];
    if (prefix <= end) {
      return (NSString *)[countryIdentifiers objectAtIndex:i];
    }
  }

  return nil;
}

- (void) add:(NSArray *)range id:(NSString *)id {
  [ranges addObject:range];
  [countryIdentifiers addObject:id];
}

- (void) initIfNeeded {
  if (![ranges empty]) {
    return;
  }
  [self add:[NSArray arrayWithObjects:0, 19, nil] id:@"US/CA"];
  [self add:[NSArray arrayWithObjects:30, 39, nil] id:@"US"];
  [self add:[NSArray arrayWithObjects:60, 139, nil] id:@"US/CA"];
  [self add:[NSArray arrayWithObjects:300, 379, nil] id:@"FR"];
  [self add:[NSArray arrayWithObjects:380, nil] id:@"BG"];
  [self add:[NSArray arrayWithObjects:383, nil] id:@"SI"];
  [self add:[NSArray arrayWithObjects:385, nil] id:@"HR"];
  [self add:[NSArray arrayWithObjects:387, nil] id:@"BA"];
  [self add:[NSArray arrayWithObjects:400, 440, nil] id:@"DE"];
  [self add:[NSArray arrayWithObjects:450, 459, nil] id:@"JP"];
  [self add:[NSArray arrayWithObjects:460, 469, nil] id:@"RU"];
  [self add:[NSArray arrayWithObjects:471, nil] id:@"TW"];
  [self add:[NSArray arrayWithObjects:474, nil] id:@"EE"];
  [self add:[NSArray arrayWithObjects:475, nil] id:@"LV"];
  [self add:[NSArray arrayWithObjects:476, nil] id:@"AZ"];
  [self add:[NSArray arrayWithObjects:477, nil] id:@"LT"];
  [self add:[NSArray arrayWithObjects:478, nil] id:@"UZ"];
  [self add:[NSArray arrayWithObjects:479, nil] id:@"LK"];
  [self add:[NSArray arrayWithObjects:480, nil] id:@"PH"];
  [self add:[NSArray arrayWithObjects:481, nil] id:@"BY"];
  [self add:[NSArray arrayWithObjects:482, nil] id:@"UA"];
  [self add:[NSArray arrayWithObjects:484, nil] id:@"MD"];
  [self add:[NSArray arrayWithObjects:485, nil] id:@"AM"];
  [self add:[NSArray arrayWithObjects:486, nil] id:@"GE"];
  [self add:[NSArray arrayWithObjects:487, nil] id:@"KZ"];
  [self add:[NSArray arrayWithObjects:489, nil] id:@"HK"];
  [self add:[NSArray arrayWithObjects:490, 499, nil] id:@"JP"];
  [self add:[NSArray arrayWithObjects:500, 509, nil] id:@"GB"];
  [self add:[NSArray arrayWithObjects:520, nil] id:@"GR"];
  [self add:[NSArray arrayWithObjects:528, nil] id:@"LB"];
  [self add:[NSArray arrayWithObjects:529, nil] id:@"CY"];
  [self add:[NSArray arrayWithObjects:531, nil] id:@"MK"];
  [self add:[NSArray arrayWithObjects:535, nil] id:@"MT"];
  [self add:[NSArray arrayWithObjects:539, nil] id:@"IE"];
  [self add:[NSArray arrayWithObjects:540, 549, nil] id:@"BE/LU"];
  [self add:[NSArray arrayWithObjects:560, nil] id:@"PT"];
  [self add:[NSArray arrayWithObjects:569, nil] id:@"IS"];
  [self add:[NSArray arrayWithObjects:570, 579, nil] id:@"DK"];
  [self add:[NSArray arrayWithObjects:590, nil] id:@"PL"];
  [self add:[NSArray arrayWithObjects:594, nil] id:@"RO"];
  [self add:[NSArray arrayWithObjects:599, nil] id:@"HU"];
  [self add:[NSArray arrayWithObjects:600, 601, nil] id:@"ZA"];
  [self add:[NSArray arrayWithObjects:603, nil] id:@"GH"];
  [self add:[NSArray arrayWithObjects:608, nil] id:@"BH"];
  [self add:[NSArray arrayWithObjects:609, nil] id:@"MU"];
  [self add:[NSArray arrayWithObjects:611, nil] id:@"MA"];
  [self add:[NSArray arrayWithObjects:613, nil] id:@"DZ"];
  [self add:[NSArray arrayWithObjects:616, nil] id:@"KE"];
  [self add:[NSArray arrayWithObjects:618, nil] id:@"CI"];
  [self add:[NSArray arrayWithObjects:619, nil] id:@"TN"];
  [self add:[NSArray arrayWithObjects:621, nil] id:@"SY"];
  [self add:[NSArray arrayWithObjects:622, nil] id:@"EG"];
  [self add:[NSArray arrayWithObjects:624, nil] id:@"LY"];
  [self add:[NSArray arrayWithObjects:625, nil] id:@"JO"];
  [self add:[NSArray arrayWithObjects:626, nil] id:@"IR"];
  [self add:[NSArray arrayWithObjects:627, nil] id:@"KW"];
  [self add:[NSArray arrayWithObjects:628, nil] id:@"SA"];
  [self add:[NSArray arrayWithObjects:629, nil] id:@"AE"];
  [self add:[NSArray arrayWithObjects:640, 649, nil] id:@"FI"];
  [self add:[NSArray arrayWithObjects:690, 695, nil] id:@"CN"];
  [self add:[NSArray arrayWithObjects:700, 709, nil] id:@"NO"];
  [self add:[NSArray arrayWithObjects:729, nil] id:@"IL"];
  [self add:[NSArray arrayWithObjects:730, 739, nil] id:@"SE"];
  [self add:[NSArray arrayWithObjects:740, nil] id:@"GT"];
  [self add:[NSArray arrayWithObjects:741, nil] id:@"SV"];
  [self add:[NSArray arrayWithObjects:742, nil] id:@"HN"];
  [self add:[NSArray arrayWithObjects:743, nil] id:@"NI"];
  [self add:[NSArray arrayWithObjects:744, nil] id:@"CR"];
  [self add:[NSArray arrayWithObjects:745, nil] id:@"PA"];
  [self add:[NSArray arrayWithObjects:746, nil] id:@"DO"];
  [self add:[NSArray arrayWithObjects:750, nil] id:@"MX"];
  [self add:[NSArray arrayWithObjects:754, 755, nil] id:@"CA"];
  [self add:[NSArray arrayWithObjects:759, nil] id:@"VE"];
  [self add:[NSArray arrayWithObjects:760, 769, nil] id:@"CH"];
  [self add:[NSArray arrayWithObjects:770, nil] id:@"CO"];
  [self add:[NSArray arrayWithObjects:773, nil] id:@"UY"];
  [self add:[NSArray arrayWithObjects:775, nil] id:@"PE"];
  [self add:[NSArray arrayWithObjects:777, nil] id:@"BO"];
  [self add:[NSArray arrayWithObjects:779, nil] id:@"AR"];
  [self add:[NSArray arrayWithObjects:780, nil] id:@"CL"];
  [self add:[NSArray arrayWithObjects:784, nil] id:@"PY"];
  [self add:[NSArray arrayWithObjects:785, nil] id:@"PE"];
  [self add:[NSArray arrayWithObjects:786, nil] id:@"EC"];
  [self add:[NSArray arrayWithObjects:789, 790, nil] id:@"BR"];
  [self add:[NSArray arrayWithObjects:800, 839, nil] id:@"IT"];
  [self add:[NSArray arrayWithObjects:840, 849, nil] id:@"ES"];
  [self add:[NSArray arrayWithObjects:850, nil] id:@"CU"];
  [self add:[NSArray arrayWithObjects:858, nil] id:@"SK"];
  [self add:[NSArray arrayWithObjects:859, nil] id:@"CZ"];
  [self add:[NSArray arrayWithObjects:860, nil] id:@"YU"];
  [self add:[NSArray arrayWithObjects:865, nil] id:@"MN"];
  [self add:[NSArray arrayWithObjects:867, nil] id:@"KP"];
  [self add:[NSArray arrayWithObjects:868, 869, nil] id:@"TR"];
  [self add:[NSArray arrayWithObjects:870, 879, nil] id:@"NL"];
  [self add:[NSArray arrayWithObjects:880, nil] id:@"KR"];
  [self add:[NSArray arrayWithObjects:885, nil] id:@"TH"];
  [self add:[NSArray arrayWithObjects:888, nil] id:@"SG"];
  [self add:[NSArray arrayWithObjects:890, nil] id:@"IN"];
  [self add:[NSArray arrayWithObjects:893, nil] id:@"VN"];
  [self add:[NSArray arrayWithObjects:896, nil] id:@"PK"];
  [self add:[NSArray arrayWithObjects:899, nil] id:@"ID"];
  [self add:[NSArray arrayWithObjects:900, 919, nil] id:@"AT"];
  [self add:[NSArray arrayWithObjects:930, 939, nil] id:@"AU"];
  [self add:[NSArray arrayWithObjects:940, 949, nil] id:@"AZ"];
  [self add:[NSArray arrayWithObjects:955, nil] id:@"MY"];
  [self add:[NSArray arrayWithObjects:958, nil] id:@"MO"];
}

- (void) dealloc {
  [ranges release];
  [countryIdentifiers release];
  [super dealloc];
}

@end
