/*
 * Copyright 2014 ZXing authors
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

#import "ZXVINParsedResultTestCase.h"

@implementation ZXVINParsedResultTestCase

- (void)testNotVIN {
  ZXResult *fakeResult = [[ZXResult alloc] initWithText:@"1M8GDM9A1KP042788" rawBytes:nil resultPoints:nil format:kBarcodeFormatCode39];
  ZXParsedResult *result = [ZXResultParser parseResult:fakeResult];
  XCTAssertEqual(kParsedResultTypeText, result.type);
  fakeResult = [[ZXResult alloc] initWithText:@"1M8GDM9AXKP042788" rawBytes:nil resultPoints:nil format:kBarcodeFormatCode128];
  result = [ZXResultParser parseResult:fakeResult];
  XCTAssertEqual(kParsedResultTypeText, result.type);
}

- (void)testVIN {
  [self doTestWithContents:@"1M8GDM9AXKP042788" wmi:@"1M8" vds:@"GDM9AX" vis:@"KP042788" country:@"US" attributes:@"GDM9A" year:1989 plant:'P' sequential:@"042788"];
  [self doTestWithContents:@"I1M8GDM9AXKP042788" wmi:@"1M8" vds:@"GDM9AX" vis:@"KP042788" country:@"US" attributes:@"GDM9A" year:1989 plant:'P' sequential:@"042788"];
  [self doTestWithContents:@"LJCPCBLCX11000237" wmi:@"LJC" vds:@"PCBLCX" vis:@"11000237" country:@"CN" attributes:@"PCBLC" year:2001 plant:'1' sequential:@"000237"];
}

- (void)doTestWithContents:(NSString *)contents
                       wmi:(NSString *)wmi
                       vds:(NSString *)vds
                       vis:(NSString *)vis
                   country:(NSString *)country
                attributes:(NSString *)attributes
                      year:(int)year
                     plant:(unichar)plant
                sequential:(NSString *)sequential {
  ZXResult *fakeResult = [[ZXResult alloc] initWithText:contents rawBytes:nil resultPoints:nil format:kBarcodeFormatCode39];
  ZXParsedResult *result = [ZXResultParser parseResult:fakeResult];
  XCTAssertEqual(kParsedResultTypeVIN, result.type);
  ZXVINParsedResult *vinResult = (ZXVINParsedResult *) result;
  XCTAssertEqualObjects(wmi, vinResult.worldManufacturerID);
  XCTAssertEqualObjects(vds, vinResult.vehicleDescriptorSection);
  XCTAssertEqualObjects(vis, vinResult.vehicleIdentifierSection);
  XCTAssertEqualObjects(country, vinResult.countryCode);
  XCTAssertEqualObjects(attributes, vinResult.vehicleAttributes);
  XCTAssertEqual(year, vinResult.modelYear);
  XCTAssertEqual(plant, vinResult.plantCode);
  XCTAssertEqualObjects(sequential, vinResult.sequentialNumber);
}

@end
