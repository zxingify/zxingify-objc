#import "ReedSolomonDecoderQRCodeTestCase.h"
#import "ZXGenericGF.h"
#import "ZXReedSolomonDecoder.h"
#import "ZXReedSolomonException.h"

@interface ReedSolomonDecoderQRCodeTestCase ()

@property (nonatomic, retain) ZXReedSolomonDecoder* qrRSDecoder;

- (void)checkQRRSDecode:(int*)received receivedLen:(int)receivedLen;

@end


@implementation ReedSolomonDecoderQRCodeTestCase

/** See ISO 18004, Appendix I, from which this example is taken. */
const int QR_CODE_TEST_LEN = 16;
static int QR_CODE_TEST[QR_CODE_TEST_LEN] =
  { 0x10, 0x20, 0x0C, 0x56, 0x61, 0x80, 0xEC, 0x11, 0xEC,
    0x11, 0xEC, 0x11, 0xEC, 0x11, 0xEC, 0x11 };

const int QR_CODE_TEST_WITH_EC_LEN = 26;
static int QR_CODE_TEST_WITH_EC[QR_CODE_TEST_WITH_EC_LEN] =
  { 0x10, 0x20, 0x0C, 0x56, 0x61, 0x80, 0xEC, 0x11, 0xEC,
    0x11, 0xEC, 0x11, 0xEC, 0x11, 0xEC, 0x11, 0xA5, 0x24,
    0xD4, 0xC1, 0xED, 0x36, 0xC7, 0x87, 0x2C, 0x55 };

const int QR_CODE_ECC_BYTES = QR_CODE_TEST_WITH_EC_LEN - QR_CODE_TEST_LEN;
const int QR_CODE_CORRECTABLE = QR_CODE_ECC_BYTES / 2;

@synthesize qrRSDecoder;

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  if (self = [super initWithInvocation:anInvocation]) {
    self.qrRSDecoder = [[[ZXReedSolomonDecoder alloc] initWithField:[ZXGenericGF QrCodeField256]] autorelease];
  }

  return self;
}

- (void)dealloc {
  [qrRSDecoder release];

  [super dealloc];
}

- (void)testNoError {
  int receivedLen = QR_CODE_TEST_WITH_EC_LEN;
  int received[receivedLen];
  for (int i = 0; i < receivedLen; i++) {
    received[i] = QR_CODE_TEST_WITH_EC[i];
  }
  // no errors
  [self checkQRRSDecode:received receivedLen:receivedLen];
}

- (void)testMaxErrors {
  const int receivedLen = QR_CODE_TEST_WITH_EC_LEN;
  int received[receivedLen];
  for (int i = 0; i < QR_CODE_TEST_LEN; i++) {
    for (int i = 0; i < QR_CODE_TEST_WITH_EC_LEN; i++) {
      received[i] = QR_CODE_TEST_WITH_EC[i];
    }
    [self corrupt:received receivedLen:receivedLen howMany:QR_CODE_CORRECTABLE];
    [self checkQRRSDecode:received receivedLen:receivedLen];
  }
}

- (void)testTooManyErrors {
  const int receivedLen = QR_CODE_TEST_WITH_EC_LEN;
  int received[receivedLen];
  for (int i = 0; i < QR_CODE_TEST_WITH_EC_LEN; i++) {
    received[i] = QR_CODE_TEST_WITH_EC[i];
  }
  [self corrupt:received receivedLen:receivedLen howMany:QR_CODE_CORRECTABLE + 1];
  @try {
    [self checkQRRSDecode:received receivedLen:receivedLen];
    STFail(@"Should not have decoded");
  } @catch (ZXReedSolomonException* rse) {
    // good
  }
}

- (void)checkQRRSDecode:(int*)received receivedLen:(int)receivedLen {
  [self.qrRSDecoder decode:received receivedLen:receivedLen twoS:QR_CODE_ECC_BYTES];
  for (int i = 0; i < QR_CODE_TEST_LEN; i++) {
    STAssertEquals(QR_CODE_TEST[i], received[i], @"Expected %d to equal %d", QR_CODE_TEST[i], received[i]);
  }
}

@end
