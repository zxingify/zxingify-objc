#import "BinaryUtil.h"
#import "ExpandedInformationDecoderTest.h"
#import "ZXAbstractExpandedDecoder.h"

@implementation ExpandedInformationDecoderTest

- (void)testNoAi {
  ZXBitArray* information = [BinaryUtil buildBitArrayFromString:@" .......X ..XX..X. X.X....X .......X ...."];

  ZXAbstractExpandedDecoder* decoder = [ZXAbstractExpandedDecoder createDecoder:information];
  NSString* decoded = [decoder parseInformation];
  STAssertEqualObjects(decoded, @"(10)12A", @"Expected %@ to equal \"(10)12A\"");
}

@end
