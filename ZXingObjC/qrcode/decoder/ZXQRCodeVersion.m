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

#import "ZXBitMatrix.h"
#import "ZXErrorCorrectionLevel.h"
#import "ZXFormatInformation.h"
#import "ZXQRCodeVersion.h"

@interface ZXQRCodeECBlocks ()

@property (nonatomic, assign) int ecCodewordsPerBlock;
@property (nonatomic, assign) int numBlocks;
@property (nonatomic, assign) int totalECCodewords;
@property (nonatomic, retain) NSArray *ecBlocks;

@end

@implementation ZXQRCodeECBlocks

@synthesize ecCodewordsPerBlock;
@synthesize numBlocks;
@synthesize totalECCodewords;
@synthesize ecBlocks;

- (id)initWithEcCodewordsPerBlock:(int)anEcCodewordsPerBlock ecBlocks:(ZXQRCodeECB *)theEcBlocks {
  if (self = [super init]) {
    self.ecCodewordsPerBlock = anEcCodewordsPerBlock;
    self.ecBlocks = [NSArray arrayWithObject:theEcBlocks];
  }

  return self;
}

- (id)initWithEcCodewordsPerBlock:(int)anEcCodewordsPerBlock ecBlocks1:(ZXQRCodeECB *)ecBlocks1 ecBlocks2:(ZXQRCodeECB *)ecBlocks2 {
  if (self = [super init]) {
    self.ecCodewordsPerBlock = anEcCodewordsPerBlock;
    self.ecBlocks = [NSArray arrayWithObjects:ecBlocks1, ecBlocks2, nil];
  }

  return self;
}

- (void)dealloc {
  [ecBlocks release];

  [super dealloc];
}

+ (ZXQRCodeECBlocks *)ecBlocksWithEcCodewordsPerBlock:(int)ecCodewordsPerBlock ecBlocks:(ZXQRCodeECB *)ecBlocks {
  return [[[ZXQRCodeECBlocks alloc] initWithEcCodewordsPerBlock:ecCodewordsPerBlock ecBlocks:ecBlocks] autorelease];
}

+ (ZXQRCodeECBlocks *)ecBlocksWithEcCodewordsPerBlock:(int)ecCodewordsPerBlock ecBlocks1:(ZXQRCodeECB *)ecBlocks1 ecBlocks2:(ZXQRCodeECB *)ecBlocks2 {
  return [[[ZXQRCodeECBlocks alloc] initWithEcCodewordsPerBlock:ecCodewordsPerBlock ecBlocks1:ecBlocks1 ecBlocks2:ecBlocks2] autorelease];
}

- (int)numBlocks {
  int total = 0;

  for (ZXQRCodeECB *ecb in self.ecBlocks) {
    total += [ecb count];
  }

  return total;
}

- (int)totalECCodewords {
  return self.ecCodewordsPerBlock * [self numBlocks];
}

@end

@interface ZXQRCodeECB ()

@property (nonatomic, assign) int count;
@property (nonatomic, assign) int dataCodewords;

@end

@implementation ZXQRCodeECB

@synthesize count;
@synthesize dataCodewords;

- (id)initWithCount:(int)aCount dataCodewords:(int)aDataCodewords {
  if (self = [super init]) {
    self.count = aCount;
    self.dataCodewords = aDataCodewords;
  }

  return self;
}

+ (ZXQRCodeECB *)ecbWithCount:(int)count dataCodewords:(int)dataCodewords {
  return [[[ZXQRCodeECB alloc] initWithCount:count dataCodewords:dataCodewords] autorelease];
}

@end


/**
 * See ISO 18004:2006 Annex D.
 * Element i represents the raw version bits that specify version i + 7
 */

int const VERSION_DECODE_INFO_LEN = 34;
int const VERSION_DECODE_INFO[VERSION_DECODE_INFO_LEN] = {
  0x07C94, 0x085BC, 0x09A99, 0x0A4D3, 0x0BBF6,
  0x0C762, 0x0D847, 0x0E60D, 0x0F928, 0x10B78,
  0x1145D, 0x12A17, 0x13532, 0x149A6, 0x15683,
  0x168C9, 0x177EC, 0x18EC4, 0x191E1, 0x1AFAB,
  0x1B08E, 0x1CC1A, 0x1D33F, 0x1ED75, 0x1F250,
  0x209D5, 0x216F0, 0x228BA, 0x2379F, 0x24B0B,
  0x2542E, 0x26A64, 0x27541, 0x28C69
};

static NSArray *VERSIONS = nil;

@interface ZXQRCodeVersion ()

@property (nonatomic, assign) int versionNumber;
@property (nonatomic, retain) NSArray *alignmentPatternCenters;
@property (nonatomic, retain) NSArray *ecBlocks;
@property (nonatomic, assign) int totalCodewords;

@end

@implementation ZXQRCodeVersion

@synthesize versionNumber;
@synthesize alignmentPatternCenters;
@synthesize ecBlocks;
@synthesize totalCodewords;

- (id)initWithVersionNumber:(int)aVersionNumber alignmentPatternCenters:(NSArray *)anAlignmentPatternCenters ecBlocks1:(ZXQRCodeECBlocks *)ecBlocks1 ecBlocks2:(ZXQRCodeECBlocks *)ecBlocks2 ecBlocks3:(ZXQRCodeECBlocks *)ecBlocks3 ecBlocks4:(ZXQRCodeECBlocks *)ecBlocks4 {
  if (self = [super init]) {
    self.versionNumber = aVersionNumber;
    self.alignmentPatternCenters = anAlignmentPatternCenters;
    self.ecBlocks = [NSArray arrayWithObjects:ecBlocks1, ecBlocks2, ecBlocks3, ecBlocks4, nil];
    int total = 0;
    int ecCodewords = ecBlocks1.ecCodewordsPerBlock;

    for (ZXQRCodeECB *ecBlock in ecBlocks1.ecBlocks) {
      total += ecBlock.count * (ecBlock.dataCodewords + ecCodewords);
    }

    self.totalCodewords = total;
  }

  return self;
}

- (void)dealloc {
  [alignmentPatternCenters release];
  [ecBlocks release];

  [super dealloc];
}

+ (ZXQRCodeVersion *)ZXQRCodeVersionWithVersionNumber:(int)aVersionNumber alignmentPatternCenters:(NSArray *)anAlignmentPatternCenters ecBlocks1:(ZXQRCodeECBlocks *)ecBlocks1 ecBlocks2:(ZXQRCodeECBlocks *)ecBlocks2 ecBlocks3:(ZXQRCodeECBlocks *)ecBlocks3 ecBlocks4:(ZXQRCodeECBlocks *)ecBlocks4 {
  return [[[ZXQRCodeVersion alloc] initWithVersionNumber:aVersionNumber alignmentPatternCenters:anAlignmentPatternCenters ecBlocks1:ecBlocks1 ecBlocks2:ecBlocks2 ecBlocks3:ecBlocks3 ecBlocks4:ecBlocks4] autorelease];
}

- (int)dimensionForVersion {
  return 17 + 4 * versionNumber;
}

- (ZXQRCodeECBlocks *)ecBlocksForLevel:(ZXErrorCorrectionLevel *)ecLevel {
  return [self.ecBlocks objectAtIndex:[ecLevel ordinal]];
}


/**
 * Deduces version information purely from QR Code dimensions.
 */
+ (ZXQRCodeVersion *)provisionalVersionForDimension:(int)dimension {
  if (dimension % 4 != 1) {
    return nil;
  }

  return [self versionForNumber:(dimension - 17) >> 2];
}

+ (ZXQRCodeVersion *)versionForNumber:(int)versionNumber {
  if (versionNumber < 1 || versionNumber > 40) {
    return nil;
  }
  return [VERSIONS objectAtIndex:versionNumber - 1];
}

+ (ZXQRCodeVersion *)decodeVersionInformation:(int)versionBits {
  int bestDifference = NSIntegerMax;
  int bestVersion = 0;

  for (int i = 0; i < VERSION_DECODE_INFO_LEN; i++) {
    int targetVersion = VERSION_DECODE_INFO[i];
    if (targetVersion == versionBits) {
      return [self versionForNumber:i + 7];
    }
    int bitsDifference = [ZXFormatInformation numBitsDiffering:versionBits b:targetVersion];
    if (bitsDifference < bestDifference) {
      bestVersion = i + 7;
      bestDifference = bitsDifference;
    }
  }

  if (bestDifference <= 3) {
    return [self versionForNumber:bestVersion];
  }
  return nil;
}


/**
 * See ISO 18004:2006 Annex E
 */
- (ZXBitMatrix *)buildFunctionPattern {
  int dimension = [self dimensionForVersion];
  ZXBitMatrix *bitMatrix = [[[ZXBitMatrix alloc] initWithDimension:dimension] autorelease];
  [bitMatrix setRegionAtLeft:0 top:0 width:9 height:9];
  [bitMatrix setRegionAtLeft:dimension - 8 top:0 width:8 height:9];
  [bitMatrix setRegionAtLeft:0 top:dimension - 8 width:9 height:8];
  int max = self.alignmentPatternCenters.count;

  for (int x = 0; x < max; x++) {
    int i = [[self.alignmentPatternCenters objectAtIndex:x] intValue] - 2;

    for (int y = 0; y < max; y++) {
      if ((x == 0 && (y == 0 || y == max - 1)) || (x == max - 1 && y == 0)) {
        continue;
      }
      [bitMatrix setRegionAtLeft:[[self.alignmentPatternCenters objectAtIndex:y] intValue] - 2 top:i width:5 height:5];
    }
  }

  [bitMatrix setRegionAtLeft:6 top:9 width:1 height:dimension - 17];
  [bitMatrix setRegionAtLeft:9 top:6 width:dimension - 17 height:1];
  if (self.versionNumber > 6) {
    [bitMatrix setRegionAtLeft:dimension - 11 top:0 width:3 height:6];
    [bitMatrix setRegionAtLeft:0 top:dimension - 11 width:6 height:3];
  }
  return bitMatrix;
}

- (NSString *)description {
  return [[NSNumber numberWithInt:self.versionNumber] stringValue];
}


/**
 * See ISO 18004:2006 6.5.1 Table 9
 */
+ (void)initialize {
  VERSIONS = [[NSArray alloc] initWithObjects:
           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:1
                                     alignmentPatternCenters:[NSArray array]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:7 ecBlocks:[ZXQRCodeECB ecbWithCount:1 dataCodewords:19]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:10 ecBlocks:[ZXQRCodeECB ecbWithCount:1 dataCodewords:16]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:13 ecBlocks:[ZXQRCodeECB ecbWithCount:1 dataCodewords:13]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:17 ecBlocks:[ZXQRCodeECB ecbWithCount:1 dataCodewords:9]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:2
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:18], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:10 ecBlocks:[ZXQRCodeECB ecbWithCount:1 dataCodewords:34]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:16 ecBlocks:[ZXQRCodeECB ecbWithCount:1 dataCodewords:28]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks:[ZXQRCodeECB ecbWithCount:1 dataCodewords:22]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks:[ZXQRCodeECB ecbWithCount:1 dataCodewords:16]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:3
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:22], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:15 ecBlocks:[ZXQRCodeECB ecbWithCount:1 dataCodewords:55]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks:[ZXQRCodeECB ecbWithCount:1 dataCodewords:44]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:18 ecBlocks:[ZXQRCodeECB ecbWithCount:2 dataCodewords:17]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks:[ZXQRCodeECB ecbWithCount:2 dataCodewords:13]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:4
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:26], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:20 ecBlocks:[ZXQRCodeECB ecbWithCount:1 dataCodewords:80]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:18 ecBlocks:[ZXQRCodeECB ecbWithCount:2 dataCodewords:32]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks:[ZXQRCodeECB ecbWithCount:2 dataCodewords:24]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:16 ecBlocks:[ZXQRCodeECB ecbWithCount:4 dataCodewords:9]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:5
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:30], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks:[ZXQRCodeECB ecbWithCount:1 dataCodewords:108]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks:[ZXQRCodeECB ecbWithCount:2 dataCodewords:43]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:18 ecBlocks1:[ZXQRCodeECB ecbWithCount:2 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:2 dataCodewords:16]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks1:[ZXQRCodeECB ecbWithCount:2 dataCodewords:11] ecBlocks2:[ZXQRCodeECB ecbWithCount:2 dataCodewords:12]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:6
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:34], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:18 ecBlocks:[ZXQRCodeECB ecbWithCount:2 dataCodewords:68]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:16 ecBlocks:[ZXQRCodeECB ecbWithCount:4 dataCodewords:27]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks:[ZXQRCodeECB ecbWithCount:4 dataCodewords:19]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks:[ZXQRCodeECB ecbWithCount:4 dataCodewords:15]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:7
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:22], [NSNumber numberWithInt:38], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:20 ecBlocks:[ZXQRCodeECB ecbWithCount:2 dataCodewords:78]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:18 ecBlocks:[ZXQRCodeECB ecbWithCount:4 dataCodewords:31]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:18 ecBlocks1:[ZXQRCodeECB ecbWithCount:2 dataCodewords:14] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:15]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[ZXQRCodeECB ecbWithCount:4 dataCodewords:13] ecBlocks2:[ZXQRCodeECB ecbWithCount:1 dataCodewords:14]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:8
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:24], [NSNumber numberWithInt:42], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks:[ZXQRCodeECB ecbWithCount:2 dataCodewords:97]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks1:[ZXQRCodeECB ecbWithCount:2 dataCodewords:38] ecBlocks2:[ZXQRCodeECB ecbWithCount:2 dataCodewords:39]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks1:[ZXQRCodeECB ecbWithCount:4 dataCodewords:18] ecBlocks2:[ZXQRCodeECB ecbWithCount:2 dataCodewords:19]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[ZXQRCodeECB ecbWithCount:4 dataCodewords:14] ecBlocks2:[ZXQRCodeECB ecbWithCount:2 dataCodewords:15]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:9
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:26], [NSNumber numberWithInt:46], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks:[ZXQRCodeECB ecbWithCount:2 dataCodewords:116]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks1:[ZXQRCodeECB ecbWithCount:3 dataCodewords:36] ecBlocks2:[ZXQRCodeECB ecbWithCount:2 dataCodewords:37]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:20 ecBlocks1:[ZXQRCodeECB ecbWithCount:4 dataCodewords:16] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:17]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[ZXQRCodeECB ecbWithCount:4 dataCodewords:12] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:13]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:10
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:28], [NSNumber numberWithInt:50], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:18 ecBlocks1:[ZXQRCodeECB ecbWithCount:2 dataCodewords:68] ecBlocks2:[ZXQRCodeECB ecbWithCount:2 dataCodewords:69]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[ZXQRCodeECB ecbWithCount:4 dataCodewords:43] ecBlocks2:[ZXQRCodeECB ecbWithCount:1 dataCodewords:44]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[ZXQRCodeECB ecbWithCount:6 dataCodewords:19] ecBlocks2:[ZXQRCodeECB ecbWithCount:2 dataCodewords:20]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:6 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:2 dataCodewords:16]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:11
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:30], [NSNumber numberWithInt:54], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:20 ecBlocks:[ZXQRCodeECB ecbWithCount:4 dataCodewords:81]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:1 dataCodewords:50] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:51]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:4 dataCodewords:22] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:23]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[ZXQRCodeECB ecbWithCount:3 dataCodewords:12] ecBlocks2:[ZXQRCodeECB ecbWithCount:8 dataCodewords:13]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:12
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:32], [NSNumber numberWithInt:58], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[ZXQRCodeECB ecbWithCount:2 dataCodewords:92] ecBlocks2:[ZXQRCodeECB ecbWithCount:2 dataCodewords:93]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks1:[ZXQRCodeECB ecbWithCount:6 dataCodewords:36] ecBlocks2:[ZXQRCodeECB ecbWithCount:2 dataCodewords:37]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[ZXQRCodeECB ecbWithCount:4 dataCodewords:20] ecBlocks2:[ZXQRCodeECB ecbWithCount:6 dataCodewords:21]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:7 dataCodewords:14] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:15]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:13
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:34], [NSNumber numberWithInt:62], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks:[ZXQRCodeECB ecbWithCount:4 dataCodewords:107]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks1:[ZXQRCodeECB ecbWithCount:8 dataCodewords:37] ecBlocks2:[ZXQRCodeECB ecbWithCount:1 dataCodewords:38]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[ZXQRCodeECB ecbWithCount:8 dataCodewords:20] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:21]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks1:[ZXQRCodeECB ecbWithCount:12 dataCodewords:11] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:12]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:14
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:26], [NSNumber numberWithInt:46], [NSNumber numberWithInt:66], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:3 dataCodewords:115] ecBlocks2:[ZXQRCodeECB ecbWithCount:1 dataCodewords:116]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[ZXQRCodeECB ecbWithCount:4 dataCodewords:40] ecBlocks2:[ZXQRCodeECB ecbWithCount:5 dataCodewords:41]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:20 ecBlocks1:[ZXQRCodeECB ecbWithCount:11 dataCodewords:16] ecBlocks2:[ZXQRCodeECB ecbWithCount:5 dataCodewords:17]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[ZXQRCodeECB ecbWithCount:11 dataCodewords:12] ecBlocks2:[ZXQRCodeECB ecbWithCount:5 dataCodewords:13]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:15
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:26], [NSNumber numberWithInt:48], [NSNumber numberWithInt:70], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks1:[ZXQRCodeECB ecbWithCount:5 dataCodewords:87] ecBlocks2:[ZXQRCodeECB ecbWithCount:1 dataCodewords:88]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[ZXQRCodeECB ecbWithCount:5 dataCodewords:41] ecBlocks2:[ZXQRCodeECB ecbWithCount:5 dataCodewords:42]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:5 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:7 dataCodewords:25]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[ZXQRCodeECB ecbWithCount:11 dataCodewords:12] ecBlocks2:[ZXQRCodeECB ecbWithCount:7 dataCodewords:13]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:16
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:26], [NSNumber numberWithInt:50], [NSNumber numberWithInt:74], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[ZXQRCodeECB ecbWithCount:5 dataCodewords:98] ecBlocks2:[ZXQRCodeECB ecbWithCount:1 dataCodewords:99]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:7 dataCodewords:45] ecBlocks2:[ZXQRCodeECB ecbWithCount:3 dataCodewords:46]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[ZXQRCodeECB ecbWithCount:15 dataCodewords:19] ecBlocks2:[ZXQRCodeECB ecbWithCount:2 dataCodewords:20]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:3 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:13 dataCodewords:16]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:17
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:30], [NSNumber numberWithInt:54], [NSNumber numberWithInt:78], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:1 dataCodewords:107] ecBlocks2:[ZXQRCodeECB ecbWithCount:5 dataCodewords:108]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:10 dataCodewords:46] ecBlocks2:[ZXQRCodeECB ecbWithCount:1 dataCodewords:47]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:1 dataCodewords:22] ecBlocks2:[ZXQRCodeECB ecbWithCount:15 dataCodewords:23]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:2 dataCodewords:14] ecBlocks2:[ZXQRCodeECB ecbWithCount:17 dataCodewords:15]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:18
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:30], [NSNumber numberWithInt:56], [NSNumber numberWithInt:82], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:5 dataCodewords:120] ecBlocks2:[ZXQRCodeECB ecbWithCount:1 dataCodewords:121]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[ZXQRCodeECB ecbWithCount:9 dataCodewords:43] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:44]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:17 dataCodewords:22] ecBlocks2:[ZXQRCodeECB ecbWithCount:1 dataCodewords:23]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:2 dataCodewords:14] ecBlocks2:[ZXQRCodeECB ecbWithCount:19 dataCodewords:15]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:19
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:30], [NSNumber numberWithInt:58], [NSNumber numberWithInt:86], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:3 dataCodewords:113] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:114]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[ZXQRCodeECB ecbWithCount:3 dataCodewords:44] ecBlocks2:[ZXQRCodeECB ecbWithCount:11 dataCodewords:45]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[ZXQRCodeECB ecbWithCount:17 dataCodewords:21] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:22]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[ZXQRCodeECB ecbWithCount:9 dataCodewords:13] ecBlocks2:[ZXQRCodeECB ecbWithCount:16 dataCodewords:14]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:20
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:34], [NSNumber numberWithInt:62], [NSNumber numberWithInt:90], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:3 dataCodewords:107] ecBlocks2:[ZXQRCodeECB ecbWithCount:5 dataCodewords:108]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[ZXQRCodeECB ecbWithCount:3 dataCodewords:41] ecBlocks2:[ZXQRCodeECB ecbWithCount:13 dataCodewords:42]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:15 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:5 dataCodewords:25]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:15 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:10 dataCodewords:16]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:21
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:28], [NSNumber numberWithInt:50], [NSNumber numberWithInt:72], [NSNumber numberWithInt:94], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:4 dataCodewords:116] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:117]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks:[ZXQRCodeECB ecbWithCount:17 dataCodewords:42]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:17 dataCodewords:22] ecBlocks2:[ZXQRCodeECB ecbWithCount:6 dataCodewords:23]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:19 dataCodewords:16] ecBlocks2:[ZXQRCodeECB ecbWithCount:6 dataCodewords:17]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:22
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:26], [NSNumber numberWithInt:50], [NSNumber numberWithInt:74], [NSNumber numberWithInt:98], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:2 dataCodewords:111] ecBlocks2:[ZXQRCodeECB ecbWithCount:7 dataCodewords:112]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks:[ZXQRCodeECB ecbWithCount:17 dataCodewords:46]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:7 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:16 dataCodewords:25]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks:[ZXQRCodeECB ecbWithCount:34 dataCodewords:13]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:23
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:30], [NSNumber numberWithInt:54], [NSNumber numberWithInt:78], [NSNumber numberWithInt:102], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:4 dataCodewords:121] ecBlocks2:[ZXQRCodeECB ecbWithCount:5 dataCodewords:122]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:4 dataCodewords:47] ecBlocks2:[ZXQRCodeECB ecbWithCount:14 dataCodewords:48]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:11 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:14 dataCodewords:25]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:16 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:14 dataCodewords:16]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:24
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:28], [NSNumber numberWithInt:54], [NSNumber numberWithInt:80], [NSNumber numberWithInt:106], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:6 dataCodewords:117] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:118]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:6 dataCodewords:45] ecBlocks2:[ZXQRCodeECB ecbWithCount:14 dataCodewords:46]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:11 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:16 dataCodewords:25]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:30 dataCodewords:16] ecBlocks2:[ZXQRCodeECB ecbWithCount:2 dataCodewords:17]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:25
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:32], [NSNumber numberWithInt:58], [NSNumber numberWithInt:84], [NSNumber numberWithInt:110], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[ZXQRCodeECB ecbWithCount:8 dataCodewords:106] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:107]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:8 dataCodewords:47] ecBlocks2:[ZXQRCodeECB ecbWithCount:13 dataCodewords:48]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:7 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:22 dataCodewords:25]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:22 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:13 dataCodewords:16]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:26
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:30], [NSNumber numberWithInt:58], [NSNumber numberWithInt:86], [NSNumber numberWithInt:114], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:10 dataCodewords:114] ecBlocks2:[ZXQRCodeECB ecbWithCount:2 dataCodewords:115]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:19 dataCodewords:46] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:47]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:28 dataCodewords:22] ecBlocks2:[ZXQRCodeECB ecbWithCount:6 dataCodewords:23]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:33 dataCodewords:16] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:17]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:27
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:34], [NSNumber numberWithInt:62], [NSNumber numberWithInt:90], [NSNumber numberWithInt:118], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:8 dataCodewords:122] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:123]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:22 dataCodewords:45] ecBlocks2:[ZXQRCodeECB ecbWithCount:3 dataCodewords:46]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:8 dataCodewords:23] ecBlocks2:[ZXQRCodeECB ecbWithCount:26 dataCodewords:24]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:12 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:28 dataCodewords:16]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:28
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:26], [NSNumber numberWithInt:50], [NSNumber numberWithInt:74], [NSNumber numberWithInt:98], [NSNumber numberWithInt:122], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:3 dataCodewords:117] ecBlocks2:[ZXQRCodeECB ecbWithCount:10 dataCodewords:118]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:3 dataCodewords:45] ecBlocks2:[ZXQRCodeECB ecbWithCount:23 dataCodewords:46]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:4 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:31 dataCodewords:25]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:11 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:31 dataCodewords:16]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:29
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:30], [NSNumber numberWithInt:54], [NSNumber numberWithInt:78], [NSNumber numberWithInt:102], [NSNumber numberWithInt:126], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:7 dataCodewords:116] ecBlocks2:[ZXQRCodeECB ecbWithCount:7 dataCodewords:117]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:21 dataCodewords:45] ecBlocks2:[ZXQRCodeECB ecbWithCount:7 dataCodewords:46]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:1 dataCodewords:23] ecBlocks2:[ZXQRCodeECB ecbWithCount:37 dataCodewords:24]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:19 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:26 dataCodewords:16]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:30
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:26], [NSNumber numberWithInt:52], [NSNumber numberWithInt:78], [NSNumber numberWithInt:104], [NSNumber numberWithInt:130], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:5 dataCodewords:115] ecBlocks2:[ZXQRCodeECB ecbWithCount:10 dataCodewords:116]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:19 dataCodewords:47] ecBlocks2:[ZXQRCodeECB ecbWithCount:10 dataCodewords:48]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:15 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:25 dataCodewords:25]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:23 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:25 dataCodewords:16]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:31
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:30], [NSNumber numberWithInt:56], [NSNumber numberWithInt:82], [NSNumber numberWithInt:108], [NSNumber numberWithInt:134], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:13 dataCodewords:115] ecBlocks2:[ZXQRCodeECB ecbWithCount:3 dataCodewords:116]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:2 dataCodewords:46] ecBlocks2:[ZXQRCodeECB ecbWithCount:29 dataCodewords:47]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:42 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:1 dataCodewords:25]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:23 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:28 dataCodewords:16]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:32
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:34], [NSNumber numberWithInt:60], [NSNumber numberWithInt:86], [NSNumber numberWithInt:112], [NSNumber numberWithInt:138], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks:[ZXQRCodeECB ecbWithCount:17 dataCodewords:115]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:10 dataCodewords:46] ecBlocks2:[ZXQRCodeECB ecbWithCount:23 dataCodewords:47]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:10 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:35 dataCodewords:25]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:19 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:35 dataCodewords:16]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:33
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:30], [NSNumber numberWithInt:58], [NSNumber numberWithInt:86], [NSNumber numberWithInt:114], [NSNumber numberWithInt:142], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:17 dataCodewords:115] ecBlocks2:[ZXQRCodeECB ecbWithCount:1 dataCodewords:116]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:14 dataCodewords:46] ecBlocks2:[ZXQRCodeECB ecbWithCount:21 dataCodewords:47]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:29 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:19 dataCodewords:25]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:11 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:46 dataCodewords:16]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:34
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:34], [NSNumber numberWithInt:62], [NSNumber numberWithInt:90], [NSNumber numberWithInt:118], [NSNumber numberWithInt:146], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:13 dataCodewords:115] ecBlocks2:[ZXQRCodeECB ecbWithCount:6 dataCodewords:116]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:14 dataCodewords:46] ecBlocks2:[ZXQRCodeECB ecbWithCount:23 dataCodewords:47]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:44 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:7 dataCodewords:25]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:59 dataCodewords:16] ecBlocks2:[ZXQRCodeECB ecbWithCount:1 dataCodewords:17]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:35
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:30], [NSNumber numberWithInt:54], [NSNumber numberWithInt:78], [NSNumber numberWithInt:102], [NSNumber numberWithInt:126], [NSNumber numberWithInt:150], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:12 dataCodewords:121] ecBlocks2:[ZXQRCodeECB ecbWithCount:7 dataCodewords:122]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:12 dataCodewords:47] ecBlocks2:[ZXQRCodeECB ecbWithCount:26 dataCodewords:48]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:39 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:14 dataCodewords:25]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:22 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:41 dataCodewords:16]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:36
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:24], [NSNumber numberWithInt:50], [NSNumber numberWithInt:76], [NSNumber numberWithInt:102], [NSNumber numberWithInt:128], [NSNumber numberWithInt:154], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:6 dataCodewords:121] ecBlocks2:[ZXQRCodeECB ecbWithCount:14 dataCodewords:122]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:6 dataCodewords:47] ecBlocks2:[ZXQRCodeECB ecbWithCount:34 dataCodewords:48]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:46 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:10 dataCodewords:25]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:2 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:64 dataCodewords:16]]],

          [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:37
                                alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:28], [NSNumber numberWithInt:54], [NSNumber numberWithInt:80], [NSNumber numberWithInt:106], [NSNumber numberWithInt:132], [NSNumber numberWithInt:158], nil]
                                              ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:17 dataCodewords:122] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:123]]
                                              ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:29 dataCodewords:46] ecBlocks2:[ZXQRCodeECB ecbWithCount:14 dataCodewords:47]]
                                              ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:49 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:10 dataCodewords:25]]
                                              ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:24 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:46 dataCodewords:16]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:38
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:32], [NSNumber numberWithInt:58], [NSNumber numberWithInt:84], [NSNumber numberWithInt:110], [NSNumber numberWithInt:136], [NSNumber numberWithInt:162], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:4 dataCodewords:122] ecBlocks2:[ZXQRCodeECB ecbWithCount:18 dataCodewords:123]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:13 dataCodewords:46] ecBlocks2:[ZXQRCodeECB ecbWithCount:32 dataCodewords:47]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:48 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:14 dataCodewords:25]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:42 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:32 dataCodewords:16]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:39
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:26], [NSNumber numberWithInt:54], [NSNumber numberWithInt:82], [NSNumber numberWithInt:110], [NSNumber numberWithInt:138], [NSNumber numberWithInt:166], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:20 dataCodewords:117] ecBlocks2:[ZXQRCodeECB ecbWithCount:4 dataCodewords:118]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:40 dataCodewords:47] ecBlocks2:[ZXQRCodeECB ecbWithCount:7 dataCodewords:48]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:43 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:22 dataCodewords:25]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:10 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:67 dataCodewords:16]]],

           [ZXQRCodeVersion ZXQRCodeVersionWithVersionNumber:40
                                     alignmentPatternCenters:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:30], [NSNumber numberWithInt:58], [NSNumber numberWithInt:86], [NSNumber numberWithInt:114], [NSNumber numberWithInt:142], [NSNumber numberWithInt:170], nil]
                                                   ecBlocks1:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:19 dataCodewords:118] ecBlocks2:[ZXQRCodeECB ecbWithCount:6 dataCodewords:119]]
                                                   ecBlocks2:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[ZXQRCodeECB ecbWithCount:18 dataCodewords:47] ecBlocks2:[ZXQRCodeECB ecbWithCount:31 dataCodewords:48]]
                                                   ecBlocks3:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:34 dataCodewords:24] ecBlocks2:[ZXQRCodeECB ecbWithCount:34 dataCodewords:25]]
                                                   ecBlocks4:[ZXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[ZXQRCodeECB ecbWithCount:20 dataCodewords:15] ecBlocks2:[ZXQRCodeECB ecbWithCount:61 dataCodewords:16]]],

          nil];
}

@end
