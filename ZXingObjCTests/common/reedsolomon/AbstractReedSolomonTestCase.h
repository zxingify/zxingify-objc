#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

@interface AbstractReedSolomonTestCase : SenTestCase

- (void)corrupt:(int*)received receivedLen:(int)receivedLen howMany:(int)howMany;
- (void)doTestQRCodeEncoding:(int*)dataBytes dataBytesLen:(int)dataBytesLen
             expectedECBytes:(int*)expectedECBytes expectedECBytesLen:(int)expectedECBytesLen;

@end
