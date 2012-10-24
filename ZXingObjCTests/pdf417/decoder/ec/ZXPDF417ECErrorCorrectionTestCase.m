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
- (BOOL)checkDecode:(NSMutableArray *)received erasures:(NSArray *)erasures;

@end

@implementation ZXPDF417ECErrorCorrectionTestCase

static NSMutableArray *PDF417_TEST = nil;
static NSMutableArray *PDF417_TEST_WITH_EC = nil;
static int ECC_BYTES;
// Example is EC level 1 (s=1). The number of erasures (l) and substitutions (f) must obey:
// l + 2f <= 2^(s+1) - 3
const int EC_LEVEL = 5;
const int ERROR_LIMIT = (1 << (EC_LEVEL + 1)) - 3;
const int MAX_ERRORS = ERROR_LIMIT / 2;
//const int MAX_ERASURES = ERROR_LIMIT;

@synthesize ec;

+ (void)initialize {
//  PDF417_TEST = [[NSMutableArray alloc] initWithObjects:
//                 [NSNumber numberWithInt:5],
//                 [NSNumber numberWithInt:453],
//                 [NSNumber numberWithInt:178],
//                 [NSNumber numberWithInt:121],
//                 [NSNumber numberWithInt:239], nil];
//
//  PDF417_TEST_WITH_EC = [[NSMutableArray alloc] initWithObjects:
//                         [NSNumber numberWithInt:5],
//                         [NSNumber numberWithInt:453],
//                         [NSNumber numberWithInt:178],
//                         [NSNumber numberWithInt:121],
//                         [NSNumber numberWithInt:239],
//                         [NSNumber numberWithInt:452],
//                         [NSNumber numberWithInt:327],
//                         [NSNumber numberWithInt:657],
//                         [NSNumber numberWithInt:619], nil];

  PDF417_TEST = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:48], [NSNumber numberWithInt:901],
                 [NSNumber numberWithInt:56], [NSNumber numberWithInt:141], [NSNumber numberWithInt:627], [NSNumber numberWithInt:856],
                 [NSNumber numberWithInt:330], [NSNumber numberWithInt:69], [NSNumber numberWithInt:244], [NSNumber numberWithInt:900],
                 [NSNumber numberWithInt:852], [NSNumber numberWithInt:169], [NSNumber numberWithInt:843], [NSNumber numberWithInt:895],
                 [NSNumber numberWithInt:852], [NSNumber numberWithInt:895], [NSNumber numberWithInt:913], [NSNumber numberWithInt:154],
                 [NSNumber numberWithInt:845], [NSNumber numberWithInt:778], [NSNumber numberWithInt:387], [NSNumber numberWithInt:89],
                 [NSNumber numberWithInt:869], [NSNumber numberWithInt:901], [NSNumber numberWithInt:219], [NSNumber numberWithInt:474],
                 [NSNumber numberWithInt:543], [NSNumber numberWithInt:650], [NSNumber numberWithInt:169], [NSNumber numberWithInt:201],
                 [NSNumber numberWithInt:9], [NSNumber numberWithInt:160], [NSNumber numberWithInt:35], [NSNumber numberWithInt:70],
                 [NSNumber numberWithInt:900], [NSNumber numberWithInt:900], [NSNumber numberWithInt:900], [NSNumber numberWithInt:900],
                 [NSNumber numberWithInt:900], [NSNumber numberWithInt:900], [NSNumber numberWithInt:900], [NSNumber numberWithInt:900],
                 [NSNumber numberWithInt:900], [NSNumber numberWithInt:900], [NSNumber numberWithInt:900], [NSNumber numberWithInt:900],
                 [NSNumber numberWithInt:900],  [NSNumber numberWithInt:900], nil];

  PDF417_TEST_WITH_EC = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:48], [NSNumber numberWithInt:901],
                         [NSNumber numberWithInt:56], [NSNumber numberWithInt:141], [NSNumber numberWithInt:627],
                         [NSNumber numberWithInt:856], [NSNumber numberWithInt:330], [NSNumber numberWithInt:69],
                         [NSNumber numberWithInt:244], [NSNumber numberWithInt:900], [NSNumber numberWithInt:852],
                         [NSNumber numberWithInt:169], [NSNumber numberWithInt:843], [NSNumber numberWithInt:895],
                         [NSNumber numberWithInt:852], [NSNumber numberWithInt:895], [NSNumber numberWithInt:913],
                         [NSNumber numberWithInt:154], [NSNumber numberWithInt:845], [NSNumber numberWithInt:778],
                         [NSNumber numberWithInt:387], [NSNumber numberWithInt:89], [NSNumber numberWithInt:869],
                         [NSNumber numberWithInt:901], [NSNumber numberWithInt:219], [NSNumber numberWithInt:474],
                         [NSNumber numberWithInt:543], [NSNumber numberWithInt:650], [NSNumber numberWithInt:169],
                         [NSNumber numberWithInt:201], [NSNumber numberWithInt:9], [NSNumber numberWithInt:160],
                         [NSNumber numberWithInt:35], [NSNumber numberWithInt:70], [NSNumber numberWithInt:900],
                         [NSNumber numberWithInt:900], [NSNumber numberWithInt:900], [NSNumber numberWithInt:900],
                         [NSNumber numberWithInt:900], [NSNumber numberWithInt:900], [NSNumber numberWithInt:900],
                         [NSNumber numberWithInt:900], [NSNumber numberWithInt:900], [NSNumber numberWithInt:900],
                         [NSNumber numberWithInt:900], [NSNumber numberWithInt:900], [NSNumber numberWithInt:900],
                         [NSNumber numberWithInt:900], [NSNumber numberWithInt:769], [NSNumber numberWithInt:843],
                         [NSNumber numberWithInt:591], [NSNumber numberWithInt:910], [NSNumber numberWithInt:605],
                         [NSNumber numberWithInt:206], [NSNumber numberWithInt:706], [NSNumber numberWithInt:917],
                         [NSNumber numberWithInt:371], [NSNumber numberWithInt:469], [NSNumber numberWithInt:79],
                         [NSNumber numberWithInt:718], [NSNumber numberWithInt:47], [NSNumber numberWithInt:777],
                         [NSNumber numberWithInt:249], [NSNumber numberWithInt:262], [NSNumber numberWithInt:193],
                         [NSNumber numberWithInt:620], [NSNumber numberWithInt:597], [NSNumber numberWithInt:477],
                         [NSNumber numberWithInt:450], [NSNumber numberWithInt:806], [NSNumber numberWithInt:908],
                         [NSNumber numberWithInt:309], [NSNumber numberWithInt:153], [NSNumber numberWithInt:871],
                         [NSNumber numberWithInt:686], [NSNumber numberWithInt:838], [NSNumber numberWithInt:185],
                         [NSNumber numberWithInt:674], [NSNumber numberWithInt:68], [NSNumber numberWithInt:679],
                         [NSNumber numberWithInt:691], [NSNumber numberWithInt:794], [NSNumber numberWithInt:497],
                         [NSNumber numberWithInt:479], [NSNumber numberWithInt:234], [NSNumber numberWithInt:250],
                         [NSNumber numberWithInt:496], [NSNumber numberWithInt:43], [NSNumber numberWithInt:347],
                         [NSNumber numberWithInt:582], [NSNumber numberWithInt:882], [NSNumber numberWithInt:536],
                         [NSNumber numberWithInt:322], [NSNumber numberWithInt:317], [NSNumber numberWithInt:273],
                         [NSNumber numberWithInt:194], [NSNumber numberWithInt:917], [NSNumber numberWithInt:237],
                         [NSNumber numberWithInt:420], [NSNumber numberWithInt:859], [NSNumber numberWithInt:340],
                         [NSNumber numberWithInt:115], [NSNumber numberWithInt:222], [NSNumber numberWithInt:808],
                         [NSNumber numberWithInt:866], [NSNumber numberWithInt:836], [NSNumber numberWithInt:417],
                         [NSNumber numberWithInt:121], [NSNumber numberWithInt:833], [NSNumber numberWithInt:459],
                         [NSNumber numberWithInt:64], [NSNumber numberWithInt:159], nil];

  ECC_BYTES = PDF417_TEST_WITH_EC.count - PDF417_TEST.count;
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
  for (int i = 0; i < PDF417_TEST.count; i++) { // # iterations is kind of arbitrary
    NSMutableArray *received = [NSMutableArray arrayWithArray:PDF417_TEST_WITH_EC];
    [self corrupt:received howMany:MAX_ERRORS];
    [self checkDecode:received];
  }
}

- (void)testTooManyErrors {
  NSMutableArray *received = [NSMutableArray arrayWithArray:PDF417_TEST_WITH_EC];
  [self corrupt:received howMany:MAX_ERRORS + 3]; // +3 since the algo can actually correct 2 more than it should here

  STAssertFalse([self checkDecode:received], @"Should not have decoded");
}

/*
- (void)testMaxErasures {
  for (int i = 0; i < PDF417_TEST.count; i++) { // # iterations is kind of arbitrary
    NSMutableArray *received = [NSMutableArray arrayWithArray:PDF417_TEST_WITH_EC];
    NSArray *erasures = [self erase:received howMany:MAX_ERASURES];
    [self checkDecode:received erasures:erasures];
  }
}

- (void)testTooManyErasures {
  NSMutableArray *received = [NSMutableArray arrayWithArray:PDF417_TEST_WITH_EC];
  NSArray *erasures = [self erase:received howMany:MAX_ERASURES + 1];

  STAssertFalse([self checkDecode:received erasures:erasures], @"Should not have decoded");
}
*/

- (BOOL)checkDecode:(NSMutableArray *)received {
  return [self checkDecode:received erasures:[NSArray array]];
}

- (BOOL)checkDecode:(NSMutableArray *)received erasures:(NSArray *)erasures {
  if (![self.ec decode:received numECCodewords:ECC_BYTES erasures:erasures]) {
    return NO;
  }

  for (int i = 0; i < PDF417_TEST.count; i++) {
    STAssertEquals([[received objectAtIndex:i] intValue], [[PDF417_TEST objectAtIndex:i] intValue], @"Expected %@ to equal %@", [received objectAtIndex:i], [PDF417_TEST objectAtIndex:i]);
  }
  return YES;
}

@end
