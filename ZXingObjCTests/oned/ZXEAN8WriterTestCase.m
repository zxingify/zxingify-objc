#import "ZXBitMatrix.h"
#import "ZXEAN8Writer.h"
#import "ZXEAN8WriterTestCase.h"

@implementation ZXEAN8WriterTestCase

- (void)testEncode {
  NSString* testStr = @"0001010001011010111101111010110111010101001110111001010001001011100101000";
  ZXBitMatrix* result = [[[[ZXEAN8Writer alloc] init] autorelease] encode:@"96385074"
                                                                   format:kBarcodeFormatEan8
                                                                    width:testStr.length height:0
                                                                    error:nil];
  for (int i = 0; i < testStr.length; i++) {
    STAssertEquals([result getX:i y:0], (BOOL)([testStr characterAtIndex:i] == '1'), @"Element %d", i);
  }
}

@end
