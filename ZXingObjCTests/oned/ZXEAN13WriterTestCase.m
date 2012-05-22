#import "ZXBitMatrix.h"
#import "ZXEAN13Writer.h"
#import "ZXEAN13WriterTestCase.h"

@implementation ZXEAN13WriterTestCase

- (void)testEncode {
  NSString* testStr = @"00010100010110100111011001100100110111101001110101010110011011011001000010101110010011101000100101000";
  ZXBitMatrix* result = [[[[ZXEAN13Writer alloc] init] autorelease] encode:@"5901234123457"
                                                                    format:kBarcodeFormatEan13
                                                                     width:testStr.length height:0];
  for (int i = 0; i < testStr.length; i++) {
    STAssertEquals([result getX:i y:0], (BOOL)([testStr characterAtIndex:i] == '1'), @"Element %d", i);
  }
}

@end
