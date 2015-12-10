//
//  ZXOneDimensionalCodeWriterTestCase.m
//  ZXingObjC
//
//  Created by Mystore on 10/12/15.
//  Copyright © 2015 zxing. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface ZXOneDimensionalCodeWriterTestCase : XCTestCase

@end

@implementation ZXOneDimensionalCodeWriterTestCase

- (void)testEncodeWithEmptyContentsReturnsError {
    NSError *error;
    ZXBitMatrix *result = [[[ZXOneDimensionalCodeWriter alloc] init] encode:@""
                                                        format:kBarcodeFormatEan8
                                                         width:0
                                                        height:0
                                                         error:&error];
    XCTAssertNil(result);
    
    if (!error || error.code != ZXWriterError) {
        XCTFail(@"ZXWriterError expected");
    }
}

- (void)testEncodeWithNegativeWidthReturnsError {
    NSError *error;
    ZXBitMatrix *result = [[[ZXOneDimensionalCodeWriter alloc] init] encode:@"1"
                                                                     format:kBarcodeFormatEan8
                                                                      width:-1
                                                                     height:0
                                                                      error:&error];
    XCTAssertNil(result);
    
    if (!error || error.code != ZXWriterError) {
        XCTFail(@"ZXWriterError expected");
    }
}

- (void)testEncodeWithNegativeHeightReturnsError {
    NSError *error;
    ZXBitMatrix *result = [[[ZXOneDimensionalCodeWriter alloc] init] encode:@"1"
                                                                     format:kBarcodeFormatEan8
                                                                      width:0
                                                                     height:-1
                                                                      error:&error];
    XCTAssertNil(result);
    
    if (!error || error.code != ZXWriterError) {
        XCTFail(@"ZXWriterError expected");
    }
}

- (void)testThrowsExceptionIfCalled {
    
    XCTAssertThrows([[[ZXOneDimensionalCodeWriter alloc] init] encode:@"" error:nil]);
}

@end
