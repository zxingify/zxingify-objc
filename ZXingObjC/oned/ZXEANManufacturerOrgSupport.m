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

#import "ZXEANManufacturerOrgSupport.h"

@interface ZXEANManufacturerOrgSupport ()

@property (nonatomic, retain) NSMutableArray *countryIdentifiers;
@property (nonatomic, retain) NSMutableArray *ranges;

- (void)add:(NSArray *)range identifier:(NSString *)identifier;
- (void)initIfNeeded;

@end

@implementation ZXEANManufacturerOrgSupport

@synthesize countryIdentifiers;
@synthesize ranges;

- (id)init {
  if (self = [super init]) {
    self.ranges = [NSMutableArray array];
    self.countryIdentifiers = [NSMutableArray array];
  }

  return self;
}

- (void)dealloc {
  [countryIdentifiers release];
  [ranges release];

  [super dealloc];
}

- (NSString *)lookupCountryIdentifier:(NSString *)productCode {
  [self initIfNeeded];
  
  int prefix = [[productCode substringToIndex:3] intValue];
  int max = self.ranges.count;

  for (int i = 0; i < max; i++) {
    NSArray *range = (NSArray *)[self.ranges objectAtIndex:i];
    int start = [[range objectAtIndex:0] intValue];
    if (prefix < start) {
      return nil;
    }
    int end = [range count] == 1 ? start : [[range objectAtIndex:1] intValue];
    if (prefix <= end) {
      return [self.countryIdentifiers objectAtIndex:i];
    }
  }

  return nil;
}

- (void)add:(NSArray *)range identifier:(NSString *)identifier {
  [self.ranges addObject:range];
  [self.countryIdentifiers addObject:identifier];
}

- (void)initIfNeeded {
  @synchronized(self.ranges) {
    if ([self.ranges count] > 0) {
      return;
    }

    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:19], nil] identifier:@"US/CA"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:30], [NSNumber numberWithInt:39], nil] identifier:@"US"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:60], [NSNumber numberWithInt:139], nil] identifier:@"US/CA"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:300], [NSNumber numberWithInt:379], nil] identifier:@"FR"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:380], nil] identifier:@"BG"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:383], nil] identifier:@"SI"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:385], nil] identifier:@"HR"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:387], nil] identifier:@"BA"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:400], [NSNumber numberWithInt:440], nil] identifier:@"DE"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:450], [NSNumber numberWithInt:459], nil] identifier:@"JP"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:460], [NSNumber numberWithInt:469], nil] identifier:@"RU"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:471], nil] identifier:@"TW"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:474], nil] identifier:@"EE"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:475], nil] identifier:@"LV"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:476], nil] identifier:@"AZ"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:477], nil] identifier:@"LT"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:478], nil] identifier:@"UZ"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:479], nil] identifier:@"LK"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:480], nil] identifier:@"PH"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:481], nil] identifier:@"BY"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:482], nil] identifier:@"UA"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:484], nil] identifier:@"MD"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:485], nil] identifier:@"AM"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:486], nil] identifier:@"GE"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:487], nil] identifier:@"KZ"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:489], nil] identifier:@"HK"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:490], [NSNumber numberWithInt:499], nil] identifier:@"JP"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:500], [NSNumber numberWithInt:509], nil] identifier:@"GB"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:520], nil] identifier:@"GR"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:528], nil] identifier:@"LB"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:529], nil] identifier:@"CY"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:531], nil] identifier:@"MK"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:535], nil] identifier:@"MT"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:539], nil] identifier:@"IE"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:540], [NSNumber numberWithInt:549], nil] identifier:@"BE/LU"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:560], nil] identifier:@"PT"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:569], nil] identifier:@"IS"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:570], [NSNumber numberWithInt:579], nil] identifier:@"DK"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:590], nil] identifier:@"PL"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:594], nil] identifier:@"RO"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:599], nil] identifier:@"HU"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:600], [NSNumber numberWithInt:601], nil] identifier:@"ZA"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:603], nil] identifier:@"GH"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:608], nil] identifier:@"BH"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:609], nil] identifier:@"MU"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:611], nil] identifier:@"MA"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:613], nil] identifier:@"DZ"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:616], nil] identifier:@"KE"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:618], nil] identifier:@"CI"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:619], nil] identifier:@"TN"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:621], nil] identifier:@"SY"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:622], nil] identifier:@"EG"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:624], nil] identifier:@"LY"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:625], nil] identifier:@"JO"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:626], nil] identifier:@"IR"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:627], nil] identifier:@"KW"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:628], nil] identifier:@"SA"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:629], nil] identifier:@"AE"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:640], [NSNumber numberWithInt:649], nil] identifier:@"FI"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:690], [NSNumber numberWithInt:695], nil] identifier:@"CN"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:700], [NSNumber numberWithInt:709], nil] identifier:@"NO"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:729], nil] identifier:@"IL"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:730], [NSNumber numberWithInt:739], nil] identifier:@"SE"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:740], nil] identifier:@"GT"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:741], nil] identifier:@"SV"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:742], nil] identifier:@"HN"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:743], nil] identifier:@"NI"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:744], nil] identifier:@"CR"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:745], nil] identifier:@"PA"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:746], nil] identifier:@"DO"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:750], nil] identifier:@"MX"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:754], [NSNumber numberWithInt:755], nil] identifier:@"CA"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:759], nil] identifier:@"VE"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:760], [NSNumber numberWithInt:769], nil] identifier:@"CH"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:770], nil] identifier:@"CO"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:773], nil] identifier:@"UY"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:775], nil] identifier:@"PE"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:777], nil] identifier:@"BO"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:779], nil] identifier:@"AR"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:780], nil] identifier:@"CL"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:784], nil] identifier:@"PY"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:785], nil] identifier:@"PE"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:786], nil] identifier:@"EC"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:789], [NSNumber numberWithInt:790], nil] identifier:@"BR"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:800], [NSNumber numberWithInt:839], nil] identifier:@"IT"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:840], [NSNumber numberWithInt:849], nil] identifier:@"ES"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:850], nil] identifier:@"CU"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:858], nil] identifier:@"SK"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:859], nil] identifier:@"CZ"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:860], nil] identifier:@"YU"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:865], nil] identifier:@"MN"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:867], nil] identifier:@"KP"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:868], [NSNumber numberWithInt:869], nil] identifier:@"TR"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:870], [NSNumber numberWithInt:879], nil] identifier:@"NL"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:880], nil] identifier:@"KR"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:885], nil] identifier:@"TH"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:888], nil] identifier:@"SG"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:890], nil] identifier:@"IN"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:893], nil] identifier:@"VN"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:896], nil] identifier:@"PK"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:899], nil] identifier:@"ID"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:900], [NSNumber numberWithInt:919], nil] identifier:@"AT"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:930], [NSNumber numberWithInt:939], nil] identifier:@"AU"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:940], [NSNumber numberWithInt:949], nil] identifier:@"AZ"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:955], nil] identifier:@"MY"];
    [self add:[NSArray arrayWithObjects:[NSNumber numberWithInt:958], nil] identifier:@"MO"];
  }
}

@end
