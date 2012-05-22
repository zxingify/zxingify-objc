#import "UPCAWriterTestCase.h"
#import "ZXBitMatrix.h"
#import "ZXUPCAWriter.h"

@implementation UPCAWriterTestCase

- (void)testEncode {
  NSString* testStr = @"00010101000110110111011000100010110101111011110101010111001011101001001110110011011011001011100101000";
  ZXBitMatrix* result = [[[[ZXUPCAWriter alloc] init] autorelease] encode:@"485963095124" format:kBarcodeFormatUPCA
                                                                    width:testStr.length height:0];
  for (int i = 0; i < testStr.length; i++) {
    BOOL expected = [testStr characterAtIndex:i] == '1';
    STAssertEquals([result getX:i y:0], expected, @"Expected (%d, 0) to be %d", i, expected);
  }
}

- (void)testAddChecksumAndEncode {
  NSString* testStr = @"00010100110010010011011110101000110110001010111101010100010010010001110100111001011001101101100101000";
  ZXBitMatrix* result = [[[[ZXUPCAWriter alloc] init] autorelease] encode:@"12345678901" format:kBarcodeFormatUPCA
                                                                    width:testStr.length height:0];
  for (int i = 0; i < testStr.length; i++) {
    BOOL expected = [testStr characterAtIndex:i] == '1';
    STAssertEquals([result getX:i y:0], expected, @"Expected (%d, 0) to be %d", i, expected);
  }
}

@end
