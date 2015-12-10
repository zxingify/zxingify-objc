//
//  ZXCode39WriterTestCase.m
//  ZXingObjC
//
//  Created by Mystore on 10/12/15.
//  Copyright © 2015 zxing. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface ZXCode39WriterTestCase : XCTestCase

@end

@implementation ZXCode39WriterTestCase

- (void)testEncodeWithWrongFormatReturnsError {
    NSError *error;
    ZXBitMatrix *result = [[[ZXCode39Writer alloc] init] encode:@""
                                                        format:kBarcodeFormatEan8
                                                         width:0
                                                        height:0
                                                         error:&error];
    XCTAssertNil(result);
    
    if (!error || error.code != ZXWriterError) {
        XCTFail(@"ZXWriterError expected");
    }
}

- (void)testEncodeWithWrongContentLengthReturnsError {
    NSError *error;
    
    NSString *content = [[NSString string] stringByPaddingToLength:81 withString:@"1" startingAtIndex:0];
    
    ZXBoolArray *result = [[[ZXCode39Writer alloc] init] encode:content error:&error];
    XCTAssertNil(result);
    
    if (!error || error.code != ZXWriterError) {
        XCTFail(@"ZXWriterError expected");
    }
}

- (void)testEncodeWithBadContentReturnsError {
    NSError *error;
    
    ZXBoolArray *result = [[[ZXCode39Writer alloc] init] encode:@"BadContents" error:&error];
    XCTAssertNil(result);
    
    if (!error || error.code != ZXWriterError) {
        XCTFail(@"ZXWriterError expected");
    }
}

@end
