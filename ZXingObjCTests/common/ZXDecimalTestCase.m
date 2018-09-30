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

#import "ZXDecimalTestCase.h"
#import "ZXDecimal.h"

@implementation ZXDecimalTestCase

- (void)testInitializer {
  ZXDecimal *decimal = [ZXDecimal decimalWithString:@"10"];
  XCTAssertEqual(10, [decimal.value intValue]);
  
  decimal = [ZXDecimal decimalWithInt:10];
  XCTAssertEqual(10, [decimal.value intValue]);
  
  decimal = [ZXDecimal decimalWithDecimalNumber:[[NSDecimalNumber alloc] initWithInt:10]];
  XCTAssertEqual(10, [decimal.value intValue]);
}

- (void)testZero {
  ZXDecimal *decimal = [ZXDecimal decimalWithInt:0];
  XCTAssertEqualObjects(decimal,[ZXDecimal decimalWithInt:0]);
  XCTAssertEqualObjects([decimal decimalByMultiplyingBy:decimal], [ZXDecimal decimalWithInt:0]);
  XCTAssertEqualObjects([decimal decimalByAdding:decimal], [ZXDecimal decimalWithInt:0]);
    
    
  decimal = [ZXDecimal decimalWithString:@""];
  XCTAssertEqualObjects(decimal, [ZXDecimal decimalWithInt:0]);
  XCTAssertEqualObjects([ZXDecimal zero], [ZXDecimal decimalWithInt:0]);
}

- (void)testSimpleAddition {
  ZXDecimal *decimal1 = [ZXDecimal decimalWithString:@"10"];
  ZXDecimal *decimal2 = [ZXDecimal decimalWithString:@"10"];
  XCTAssertEqual(20, [[decimal1 decimalByAdding:decimal2].value intValue]);

  decimal1 = [ZXDecimal decimalWithString:@"4"];
  decimal2 = [ZXDecimal decimalWithString:@"4"];
  XCTAssertEqual(8, [[decimal1 decimalByAdding:decimal2].value intValue]);

  decimal1 = [ZXDecimal decimalWithString:@"4000"];
  decimal2 = [ZXDecimal decimalWithString:@"44"];
  XCTAssertEqual(4044, [[decimal1 decimalByAdding:decimal2].value intValue]);

  decimal1 = [ZXDecimal decimalWithString:@"231"];
  decimal2 = [ZXDecimal decimalWithString:@"999999876"];
  XCTAssertEqual(1000000107, [[decimal1 decimalByAdding:decimal2].value intValue]);
}

- (void)testAdditionWithLarge {
  ZXDecimal *decimal1 = [ZXDecimal decimalWithString:@"231"];
  ZXDecimal *decimal2 = [ZXDecimal decimalWithString:@"999999876"];
  XCTAssertEqual(1000000107, [[decimal1 decimalByAdding:decimal2].value intValue]);
}

- (void)testSimpleMultiply {
  ZXDecimal *decimal1 = [ZXDecimal decimalWithString:@"10"];
  ZXDecimal *decimal2 = [ZXDecimal decimalWithString:@"10"];
  XCTAssertEqual(100, [[decimal1 decimalByMultiplyingBy:decimal2].value intValue]);

  decimal1 = [ZXDecimal decimalWithString:@"4"];
  decimal2 = [ZXDecimal decimalWithString:@"4"];
  XCTAssertEqual(16, [[decimal1 decimalByMultiplyingBy:decimal2].value intValue]);
}

- (void)testEnhancedMultiply {
  ZXDecimal *decimal1 = [ZXDecimal decimalWithString:@"10"];
  ZXDecimal *decimal2 = [ZXDecimal decimalWithString:@"20"];
  XCTAssertEqual(200, [[decimal1 decimalByMultiplyingBy:decimal2].value intValue]);

  decimal1 = [ZXDecimal decimalWithString:@"12"];
  decimal2 = [ZXDecimal decimalWithString:@"22"];
  XCTAssertEqual(264, [[decimal1 decimalByMultiplyingBy:decimal2].value intValue]);

  decimal1 = [ZXDecimal decimalWithString:@"10"];
  decimal2 = [ZXDecimal decimalWithString:@"100"];
  XCTAssertEqual(1000, [[decimal1 decimalByMultiplyingBy:decimal2].value intValue]);
}

- (void)testEnhancedMultiplyWithLargeNumber {
  ZXDecimal *decimal1 = [ZXDecimal decimalWithString:@"521"];
  ZXDecimal *decimal2 = [ZXDecimal decimalWithString:@"321"];
  XCTAssertEqual(167241, [[decimal1 decimalByMultiplyingBy:decimal2].value intValue]);

  decimal1 = [ZXDecimal decimalWithString:@"5589723"];
  decimal2 = [ZXDecimal decimalWithString:@"99987652"];
  XCTAssertEqualObjects(@"558903278100396", [decimal1 decimalByMultiplyingBy:decimal2].value);

  decimal1 = [ZXDecimal decimalWithString:@"989898989898981"];
  decimal2 = [ZXDecimal decimalWithString:@"999988885555533"];
  XCTAssertEqualObjects(@"989887987721629828381735611873", [decimal1 decimalByMultiplyingBy:decimal2].value);
}

@end
