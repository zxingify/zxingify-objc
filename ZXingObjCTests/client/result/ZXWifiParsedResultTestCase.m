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

#import "ZXWifiParsedResultTestCase.h"

@implementation ZXWifiParsedResultTestCase

- (void)testNoPassword {
  [self doTestWithContents:@"WIFI:S:NoPassword;P:;T:;;" ssid:@"NoPassword" password:nil type:@"nopass"];
  [self doTestWithContents:@"WIFI:S:No Password;P:;T:;;" ssid:@"No Password" password:nil type:@"nopass"];
}

- (void)testWep {
  [self doTestWithContents:@"WIFI:S:TenChars;P:0123456789;T:WEP;;" ssid:@"TenChars" password:@"0123456789" type:@"WEP"];
  [self doTestWithContents:@"WIFI:S:TenChars;P:abcde56789;T:WEP;;" ssid:@"TenChars" password:@"abcde56789" type:@"WEP"];
  // Non hex should not fail at this level
  [self doTestWithContents:@"WIFI:S:TenChars;P:hellothere;T:WEP;;" ssid:@"TenChars" password:@"hellothere" type:@"WEP"];

  // Escaped semicolons
  [self doTestWithContents:@"WIFI:S:Ten\\;\\;Chars;P:0123456789;T:WEP;;" ssid:@"Ten;;Chars" password:@"0123456789" type:@"WEP"];
  // Escaped colons
  [self doTestWithContents:@"WIFI:S:Ten\\:\\:Chars;P:0123456789;T:WEP;;" ssid:@"Ten::Chars" password:@"0123456789" type:@"WEP"];

  // TODO Need a test for SB as well.
}

/**
 * Put in checks for the length of the password for wep.
 */
- (void)testWpa {
  [self doTestWithContents:@"WIFI:S:TenChars;P:wow;T:WPA;;" ssid:@"TenChars" password:@"wow" type:@"WPA"];
  [self doTestWithContents:@"WIFI:S:TenChars;P:space is silent;T:WPA;;" ssid:@"TenChars" password:@"space is silent" type:@"WPA"];
  [self doTestWithContents:@"WIFI:S:TenChars;P:hellothere;T:WEP;;" ssid:@"TenChars" password:@"hellothere" type:@"WEP"];

  // Escaped semicolons
  [self doTestWithContents:@"WIFI:S:TenChars;P:hello\\;there;T:WEP;;" ssid:@"TenChars" password:@"hello;there" type:@"WEP"];
  // Escaped colons
  [self doTestWithContents:@"WIFI:S:TenChars;P:hello\\:there;T:WEP;;" ssid:@"TenChars" password:@"hello:there" type:@"WEP"];
}

/**
 * Given the string contents for the barcode, check that it matches our expectations
 */
- (void)doTestWithContents:(NSString *)contents ssid:(NSString *)ssid password:(NSString *)password type:(NSString *)type {
  ZXResult *fakeResult = [ZXResult resultWithText:contents rawBytes:nil resultPoints:nil format:kBarcodeFormatQRCode];
  ZXParsedResult *result = [ZXResultParser parseResult:fakeResult];

  // Ensure it is a wifi code
  XCTAssertEqual(result.type, kParsedResultTypeWifi, @"Types don't match");
  ZXWifiParsedResult *wifiResult = (ZXWifiParsedResult *)result;

  XCTAssertEqualObjects(wifiResult.ssid, ssid, @"Ssid's don't match");
  XCTAssertEqualObjects(wifiResult.password, password, @"Passwords don't match");
  XCTAssertEqualObjects(wifiResult.networkEncryption, type, @"Network encryption doesn't match");
}

@end
