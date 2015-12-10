//
//  ZXITFWriterTestCase.m
//  ZXingObjC
//
//  Created by Mystore on 10/12/15.
//  Copyright © 2015 zxing. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface ZXITFWriterTestCase : XCTestCase

@end

@implementation ZXITFWriterTestCase

- (void)testEncodeWithWrongFormatReturnsError {
    NSError *error;
    ZXBitMatrix *result = [[[ZXITFWriter alloc] init] encode:@""
                                                        format:kBarcodeFormatEan8
                                                         width:0
                                                        height:0
                                                         error:&error];
    XCTAssertNil(result);
    
    if (!error || error.code != ZXWriterError) {
        XCTFail(@"ZXWriterError expected");
    }
}

- (void)testEncodeWithOddContentLengthReturnsError {
    NSError *error;
    ZXBoolArray *result = [[[ZXITFWriter alloc] init] encode:@"123" error:&error];
    XCTAssertNil(result);
    
    if (!error || error.code != ZXWriterError) {
        XCTFail(@"ZXWriterError expected");
    }
}

- (void)testEncodeWithTooLongContentLengthReturnsError {
    NSError *error;
    NSString *content = [[NSString string] stringByPaddingToLength:82 withString:@"1" startingAtIndex:0];
    ZXBoolArray *result = [[[ZXITFWriter alloc] init] encode:content error:&error];
    XCTAssertNil(result);
    
    if (!error || error.code != ZXWriterError) {
        XCTFail(@"ZXWriterError expected");
    }
}

@end
