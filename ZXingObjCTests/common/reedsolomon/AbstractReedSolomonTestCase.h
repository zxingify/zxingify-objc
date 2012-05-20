#import <SenTestingKit/SenTestingKit.h>

@interface AbstractReedSolomonTestCase : SenTestCase

- (void)corrupt:(int*)received receivedLen:(int)receivedLen howMany:(int)howMany;
- (void)doTestQRCodeEncoding:(int*)dataBytes dataBytesLen:(int)dataBytesLen
             expectedECBytes:(int*)expectedECBytes expectedECBytesLen:(int)expectedECBytesLen;
- (void)assertArraysEqual:(int*)expected expectedOffset:(int)expectedOffset
                   actual:(int*)actual actualOffset:(int)actualOffset length:(int)length;

@end
