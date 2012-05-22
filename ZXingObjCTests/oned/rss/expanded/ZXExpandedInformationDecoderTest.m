#import "ZXAbstractExpandedDecoder.h"
#import "ZXBinaryUtil.h"
#import "ZXExpandedInformationDecoderTest.h"

@implementation ZXExpandedInformationDecoderTest

- (void)testNoAi {
  ZXBitArray* information = [ZXBinaryUtil buildBitArrayFromString:@" .......X ..XX..X. X.X....X .......X ...."];

  ZXAbstractExpandedDecoder* decoder = [ZXAbstractExpandedDecoder createDecoder:information];
  NSString* decoded = [decoder parseInformation];
  STAssertEqualObjects(decoded, @"(10)12A", @"Expected %@ to equal \"(10)12A\"");
}

@end
