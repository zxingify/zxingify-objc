#import "ZXBinaryUtil.h"
#import "ZXBinaryUtilTest.h"
#import "ZXBitArray.h"

@interface ZXBinaryUtilTest ()

- (void)check:(NSString*)data;
- (void)checkWithoutSpaces:(NSString*)data;

@end

@implementation ZXBinaryUtilTest

- (void)testBuildBitArrayFromString {

  NSString* data = @" ..X..X.. ..XXX... XXXXXXXX ........";
  [self check:data];

  data = @" XXX..X..";
  [self check:data];

  data = @" XX";
  [self check:data];

  data = @" ....XX.. ..XX";
  [self check:data];

  data = @" ....XX.. ..XX..XX ....X.X. ........";
  [self check:data];
}

- (void)check:(NSString*)data {
  ZXBitArray* binary = [ZXBinaryUtil buildBitArrayFromString:data];
  STAssertEqualObjects([binary description], data, @"Expected %@ to equal %@", [binary description], data);
}

- (void)checkWithoutSpaces:(NSString*)data {
  NSString* dataWithoutSpaces = [data stringByReplacingOccurrencesOfString:@" " withString:@""];
  ZXBitArray* binary = [ZXBinaryUtil buildBitArrayFromStringWithoutSpaces:dataWithoutSpaces];
  STAssertEqualObjects([binary description], data, @"Expected %@ to equal %@", [binary description], data);
}

@end
