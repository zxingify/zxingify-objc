#import "ZXBitSourceBuilder.h"
#import "ZXDecoderResult.h"
#import "ZXQRCodeDecodedBitStreamParser.h"
#import "ZXQRCodeDecodedBitStreamParserTestCase.h"
#import "ZXQRCodeVersion.h"

@implementation ZXQRCodeDecodedBitStreamParserTestCase

- (void)testSimpleByteMode {
  ZXBitSourceBuilder* builder = [[[ZXBitSourceBuilder alloc] init] autorelease];
  [builder write:0x04 numBits:4]; // Byte mode
  [builder write:0x03 numBits:8]; // 3 bytes
  [builder write:0xF1 numBits:8];
  [builder write:0xF2 numBits:8];
  [builder write:0xF3 numBits:8];
  NSString* result = [[ZXQRCodeDecodedBitStreamParser decode:[builder toByteArray] length:[builder byteArrayLength]
                                                     version:[ZXQRCodeVersion versionForNumber:1] ecLevel:nil hints:nil]text];
  NSString* expected = @"\u00f1\u00f2\u00f3";
  STAssertEqualObjects(result, expected, @"Expected %@ to equal %@", result, expected);
}

- (void)testSimpleSJIS {
  ZXBitSourceBuilder* builder = [[[ZXBitSourceBuilder alloc] init] autorelease];
  [builder write:0x04 numBits:4]; // Byte mode
  [builder write:0x04 numBits:8]; // 4 bytes
  [builder write:0xA1 numBits:8];
  [builder write:0xA2 numBits:8];
  [builder write:0xA3 numBits:8];
  [builder write:0xD0 numBits:8];
  NSString* result = [[ZXQRCodeDecodedBitStreamParser decode:[builder toByteArray] length:[builder byteArrayLength]
                                                     version:[ZXQRCodeVersion versionForNumber:1] ecLevel:nil hints:nil]text];
  NSString* expected = @"\uff61\uff62\uff63\uff90";
  STAssertEqualObjects(result, expected, @"Expected %@ to equal %@", result, expected);
}

- (void)testECI {
  ZXBitSourceBuilder* builder = [[[ZXBitSourceBuilder alloc] init] autorelease];
  [builder write:0x07 numBits:4]; // ECI mode
  [builder write:0x02 numBits:8]; // ECI 2 = CP437 encoding
  [builder write:0x04 numBits:4]; // Byte mode
  [builder write:0x03 numBits:8]; // 3 bytes
  [builder write:0xA1 numBits:8];
  [builder write:0xA2 numBits:8];
  [builder write:0xA3 numBits:8];
  NSString* result = [[ZXQRCodeDecodedBitStreamParser decode:[builder toByteArray] length:[builder byteArrayLength]
                                                     version:[ZXQRCodeVersion versionForNumber:1] ecLevel:nil hints:nil]text];
  NSString* expected = @"\u00ed\u00f3\u00fa";
  STAssertEqualObjects(result, expected, @"Expected %@ to equal %@", result, expected);
}

- (void)testHanzi {
  ZXBitSourceBuilder* builder = [[[ZXBitSourceBuilder alloc] init] autorelease];
  [builder write:0x0D numBits:4]; // Hanzi mode
  [builder write:0x01 numBits:4]; // Subset 1 = GB2312 encoding
  [builder write:0x01 numBits:8]; // 1 characters
  [builder write:0x03C1 numBits:13];
  NSString* result = [[ZXQRCodeDecodedBitStreamParser decode:[builder toByteArray] length:[builder byteArrayLength]
                                                     version:[ZXQRCodeVersion versionForNumber:1] ecLevel:nil hints:nil]text];
  NSString* expected = @"\u963f";
  STAssertEqualObjects(result, expected, @"Expected %@ to equal %@", result, expected);
}

@end
