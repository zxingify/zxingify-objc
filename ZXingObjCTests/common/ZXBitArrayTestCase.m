#import "ZXBitArray.h"
#import "ZXBitArrayTestCase.h"

@implementation ZXBitArrayTestCase

- (void)testGetSet {
  ZXBitArray* array = [[[ZXBitArray alloc] initWithSize:33] autorelease];
  for (int i = 0; i < 33; i++) {
    STAssertFalse([array get:i], @"Expected [array get:%d] to be false", i);
    [array set:i];
    STAssertTrue([array get:i], @"Expected [array get:%d] to be true");
  }
}

- (void)testSetBulk {
  ZXBitArray* array = [[[ZXBitArray alloc] initWithSize:64] autorelease];
  [array setBulk:32 newBits:0xFFFF0000];
  for (int i = 0; i < 48; i++) {
    STAssertFalse([array get:i], @"Expected [array get:%d] to be false", i);
  }
  for (int i = 48; i < 64; i++) {
    STAssertTrue([array get:i], @"Expected [array get:%d] to be true", i);
  }
}

- (void)testClear {
  ZXBitArray* array = [[[ZXBitArray alloc] initWithSize:32] autorelease];
  for (int i = 0; i < 32; i++) {
    [array set:i];
  }
  [array clear];
  for (int i = 0; i < 32; i++) {
    STAssertFalse([array get:i], @"Expected [array get:%d] to be false", i);
  }
}

- (void)testGetArray {
  ZXBitArray* array = [[[ZXBitArray alloc] initWithSize:64] autorelease];
  [array set:0];
  [array set:63];
  int* ints = array.bits;
  STAssertEquals(ints[0], 1, @"Expected ints[0] to equal 1");
  STAssertEquals(ints[1], (int)NSIntegerMin, @"Expected ints[1] to equal NSIntegerMin");
}

- (void)testIsRange {
  ZXBitArray* array = [[[ZXBitArray alloc] initWithSize:64] autorelease];
  STAssertTrue([array isRange:0 end:64 value:NO], @"Expected range 0-64 of NO to be true");
  STAssertFalse([array isRange:0 end:64 value:YES], @"Expected range 0-64 of YES to be false");
  [array set:32];
  STAssertTrue([array isRange:32 end:33 value:YES], @"Expected range 32-33 of YES to be true");
  [array set:31];
  STAssertTrue([array isRange:31 end:33 value:YES], @"Expected range 31-33 of YES to be true");
  [array set:34];
  STAssertFalse([array isRange:31 end:35 value:YES], @"Expected range 31-35 of YES to be false");
  for (int i = 0; i < 31; i++) {
    [array set:i];
  }
  STAssertTrue([array isRange:0 end:33 value:YES], @"Expected range 0-33 of YES to be true");
  for (int i = 33; i < 64; i++) {
    [array set:i];
  }
  STAssertTrue([array isRange:0 end:64 value:YES], @"Expected range 0-64 of YES to be true");
  STAssertFalse([array isRange:0 end:64 value:NO], @"Expected range 0-64 of YES to be false");
}

@end
