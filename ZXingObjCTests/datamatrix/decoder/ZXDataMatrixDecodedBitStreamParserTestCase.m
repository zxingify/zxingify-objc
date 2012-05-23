#import "ZXDataMatrixDecodedBitStreamParser.h"
#import "ZXDataMatrixDecodedBitStreamParserTestCase.h"
#import "ZXDecoderResult.h"

@implementation ZXDataMatrixDecodedBitStreamParserTestCase

- (void)testAsciiStandardDecode {
  // ASCII characters 0-127 are encoded as the value + 1
  unsigned char bytes[6] = {
    (unsigned char) ('a' + 1), (unsigned char) ('b' + 1), (unsigned char) ('c' + 1),
    (unsigned char) ('A' + 1), (unsigned char) ('B' + 1), (unsigned char) ('C' + 1) };
  NSString* decodedString = [ZXDataMatrixDecodedBitStreamParser decode:bytes length:6 error:nil].text;
  NSString* expected = @"abcABC";
  STAssertEqualObjects(decodedString, expected, @"Expected \"%@\" to equal \"%@\"", decodedString, expected);
}

@end
