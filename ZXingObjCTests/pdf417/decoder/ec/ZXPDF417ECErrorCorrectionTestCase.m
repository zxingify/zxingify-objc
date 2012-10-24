/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXPDF417ECErrorCorrection.h"
#import "ZXPDF417ECErrorCorrectionTestCase.h"

@interface ZXPDF417ECErrorCorrectionTestCase ()

@property (nonatomic, retain) ZXPDF417ECErrorCorrection* ec;

- (BOOL)checkDecode:(NSMutableArray *)received;

@end

@implementation ZXPDF417ECErrorCorrectionTestCase

static NSMutableArray *PDF417_TEST = nil;

static NSMutableArray *PDF417_TEST_WITH_EC = nil;

static int ECC_BYTES;
static int CORRECTABLE;

@synthesize ec;

+ (void)initialize {
  PDF417_TEST = [[NSMutableArray alloc] initWithObjects:
                 [NSNumber numberWithInt:5],
                 [NSNumber numberWithInt:453],
                 [NSNumber numberWithInt:178],
                 [NSNumber numberWithInt:121],
                 [NSNumber numberWithInt:239], nil];

  PDF417_TEST_WITH_EC = [[NSMutableArray alloc] initWithObjects:
                         [NSNumber numberWithInt:5],
                         [NSNumber numberWithInt:453],
                         [NSNumber numberWithInt:178],
                         [NSNumber numberWithInt:121],
                         [NSNumber numberWithInt:239],
                         [NSNumber numberWithInt:452],
                         [NSNumber numberWithInt:327],
                         [NSNumber numberWithInt:657],
                         [NSNumber numberWithInt:619], nil];

  ECC_BYTES = PDF417_TEST_WITH_EC.count - PDF417_TEST.count;
  CORRECTABLE = ECC_BYTES / 2;
}

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  if (self = [super initWithInvocation:anInvocation]) {
    self.ec = [[[ZXPDF417ECErrorCorrection alloc] init] autorelease];
  }

  return self;
}

- (void)dealloc {
  [ec release];

  [super dealloc];
}

- (void)testNoError {
  NSMutableArray *received = [NSMutableArray arrayWithArray:PDF417_TEST_WITH_EC];
  // no errors
  [self checkDecode:received];
}

- (void)testOneError {
  for (int i = 0; i < PDF417_TEST_WITH_EC.count; i++) {
    NSMutableArray *received = [NSMutableArray arrayWithArray:PDF417_TEST_WITH_EC];
    [received replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:arc4random() % 256]];
    [self checkDecode:received];
  }
}

- (void)testMaxErrors {
  for (int i = 0; i < PDF417_TEST.count; i++) {
    NSMutableArray *received = [NSMutableArray arrayWithArray:PDF417_TEST_WITH_EC];
    [self corrupt:received howMany:CORRECTABLE];
    [self checkDecode:received];
  }
}

- (void)testTooManyErrors {
  NSMutableArray *received = [NSMutableArray arrayWithArray:PDF417_TEST_WITH_EC];
  [self corrupt:received howMany:CORRECTABLE + 1];

  STAssertFalse([self checkDecode:received], @"Should not have decoded");
}

- (BOOL)checkDecode:(NSMutableArray *)received {
  if (![self.ec decode:received numECCodewords:ECC_BYTES]) {
    return NO;
  }

  for (int i = 0; i < PDF417_TEST.count; i++) {
    STAssertEqualObjects([received objectAtIndex:i], [PDF417_TEST objectAtIndex:i], @"Expected %d to equal %d", [received objectAtIndex:i], [PDF417_TEST objectAtIndex:i]);
  }
  return YES;
}

@end
