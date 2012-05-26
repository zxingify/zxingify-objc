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

#import "ZXErrorCorrectionLevel.h"
#import "ZXQRCodeVersion.h"
#import "ZXQRCodeVersionTestCase.h"

@interface ZXQRCodeVersionTestCase ()

- (void)checkVersion:(ZXQRCodeVersion*)version number:(int)number dimension:(int)dimension;

@end

@implementation ZXQRCodeVersionTestCase

- (void)testVersionForNumber {
  if ([ZXQRCodeVersion versionForNumber:0]) {
    STFail(@"Should have failed");
  }
  for (int i = 1; i <= 40; i++) {
    [self checkVersion:[ZXQRCodeVersion versionForNumber:i] number:i dimension:4*i + 17];
  }
}

- (void)checkVersion:(ZXQRCodeVersion*)version number:(int)number dimension:(int)dimension {
  STAssertNotNil(version, @"Expected version to be non-nil");
  STAssertEquals(version.versionNumber, number, @"Expected version number to be %d", number);
  STAssertNotNil(version.alignmentPatternCenters, @"Expected alignmentPatternCenters to be non-nil");
  if (number > 1) {
    STAssertTrue(version.alignmentPatternCenters.count > 0, @"Expected alignmentPatternCenters to be non-empty");
  }
  STAssertEquals(version.dimensionForVersion, dimension, @"Expected dimension to be %d");
  STAssertNotNil([version ecBlocksForLevel:[ZXErrorCorrectionLevel errorCorrectionLevelH]],
                 @"Expected ecblocks for error correction level H to be non-nil");
  STAssertNotNil([version ecBlocksForLevel:[ZXErrorCorrectionLevel errorCorrectionLevelL]],
                 @"Expected ecblocks for error correction level L to be non-nil");
  STAssertNotNil([version ecBlocksForLevel:[ZXErrorCorrectionLevel errorCorrectionLevelM]],
                 @"Expected ecblocks for error correction level M to be non-nil");
  STAssertNotNil([version ecBlocksForLevel:[ZXErrorCorrectionLevel errorCorrectionLevelQ]],
                 @"Expected ecblocks for error correction level Q to be non-nil");
  STAssertNotNil([version buildFunctionPattern], @"Expected version buildFunctionPattern to be non-nil");
}

- (void)testGetProvisionalVersionForDimension {
  for (int i = 1; i <= 40; i++) {
    STAssertEquals([ZXQRCodeVersion provisionalVersionForDimension:4*i + 17].versionNumber, i,
                   @"Expected version number to be %d", i);
  }
}

- (void)testDecodeVersionInformation {
  // Spot check
  STAssertEquals([ZXQRCodeVersion decodeVersionInformation:0x07C94].versionNumber, 7,
                 @"Expected version number to be 7");
  STAssertEquals([ZXQRCodeVersion decodeVersionInformation:0x0C762].versionNumber, 12,
                 @"Expected version number to be 12");
  STAssertEquals([ZXQRCodeVersion decodeVersionInformation:0x1145D].versionNumber, 17,
                 @"Expected version number to be 17");
  STAssertEquals([ZXQRCodeVersion decodeVersionInformation:0x168C9].versionNumber, 22,
                 @"Expected version number to be 22");
  STAssertEquals([ZXQRCodeVersion decodeVersionInformation:0x1B08E].versionNumber, 27,
                 @"Expected version number to be 27");
  STAssertEquals([ZXQRCodeVersion decodeVersionInformation:0x209D5].versionNumber, 32,
                 @"Expected version number to be 32");
}

@end
