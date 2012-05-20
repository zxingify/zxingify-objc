#import "AbstractReedSolomonTestCase.h"
#import "ZXGenericGF.h"
#import "ZXReedSolomonEncoder.h"

@interface AbstractReedSolomonTestCase ()

- (void)assertArraysEqual:(int*)expected expectedOffset:(int)expectedOffset
                   actual:(int*)actual actualOffset:(int)actualOffset length:(int)length;


@end

@implementation AbstractReedSolomonTestCase

- (void)corrupt:(int*)received receivedLen:(int)receivedLen howMany:(int)howMany {
  BOOL corrupted[receivedLen];
  for (int i = 0; i < receivedLen; i++) {
    corrupted[i] = NO;
  }

  for (int j = 0; j < howMany; j++) {
    int location = arc4random() % receivedLen;
    if (corrupted[location]) {
      j--;
    } else {
      corrupted[location] = YES;
      received[location] = (received[location] + 1 + (arc4random() % 255)) & 0xFF;
    }
  }
}

- (void)doTestQRCodeEncoding:(int*)dataBytes dataBytesLen:(int)dataBytesLen
             expectedECBytes:(int*)expectedECBytes expectedECBytesLen:(int)expectedECBytesLen {
  int toEncodeLen = dataBytesLen + expectedECBytesLen;
  int toEncode[toEncodeLen];
  for (int i = 0; i < toEncodeLen; i++) {
    if (i < dataBytesLen) {
      toEncode[i] = dataBytes[i];
    } else {
      toEncode[i] = 0;
    }
  }
  [[[[ZXReedSolomonEncoder alloc] initWithField:[ZXGenericGF QrCodeField256]] autorelease] encode:toEncode toEncodeLen:toEncodeLen ecBytes:expectedECBytesLen];
  [self assertArraysEqual:dataBytes expectedOffset:0 actual:toEncode actualOffset:0 length:dataBytesLen];
  [self assertArraysEqual:expectedECBytes expectedOffset:0 actual:toEncode actualOffset:dataBytesLen length:expectedECBytesLen];
}

- (void)assertArraysEqual:(int*)expected expectedOffset:(int)expectedOffset
                   actual:(int*)actual actualOffset:(int)actualOffset length:(int)length {
  for (int i = 0; i < length; i++) {
    STAssertEquals(actual[actualOffset + i], expected[expectedOffset + i], @"Expected %d, got %d", actual[actualOffset + i], expected[expectedOffset + i]);
  }
}

@end
