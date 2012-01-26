#import "Version.h"

@implementation ECBlocks

@synthesize eCCodewordsPerBlock;
@synthesize numBlocks;
@synthesize totalECCodewords;
@synthesize eCBlocks;

- (id) init:(int)ecCodewordsPerBlock ecBlocks:(ECB *)ecBlocks {
  if (self = [super init]) {
    ecCodewordsPerBlock = ecCodewordsPerBlock;
    ecBlocks = [NSArray arrayWithObjects:ecBlocks, nil];
  }
  return self;
}

- (id) init:(int)ecCodewordsPerBlock ecBlocks1:(ECB *)ecBlocks1 ecBlocks2:(ECB *)ecBlocks2 {
  if (self = [super init]) {
    ecCodewordsPerBlock = ecCodewordsPerBlock;
    ecBlocks = [NSArray arrayWithObjects:ecBlocks1, ecBlocks2, nil];
  }
  return self;
}

- (int) numBlocks {
  int total = 0;

  for (int i = 0; i < ecBlocks.length; i++) {
    total += [ecBlocks[i] count];
  }

  return total;
}

- (int) totalECCodewords {
  return ecCodewordsPerBlock * [self numBlocks];
}

- (void) dealloc {
  [ecBlocks release];
  [super dealloc];
}

@end

@implementation ECB

@synthesize count;
@synthesize dataCodewords;

- (id) init:(int)count dataCodewords:(int)dataCodewords {
  if (self = [super init]) {
    count = count;
    dataCodewords = dataCodewords;
  }
  return self;
}

@end


/**
 * See ISO 18004:2006 Annex D.
 * Element i represents the raw version bits that specify version i + 7
 */
NSArray * const VERSION_DECODE_INFO = [NSArray arrayWithObjects:0x07C94, 0x085BC, 0x09A99, 0x0A4D3, 0x0BBF6, 0x0C762, 0x0D847, 0x0E60D, 0x0F928, 0x10B78, 0x1145D, 0x12A17, 0x13532, 0x149A6, 0x15683, 0x168C9, 0x177EC, 0x18EC4, 0x191E1, 0x1AFAB, 0x1B08E, 0x1CC1A, 0x1D33F, 0x1ED75, 0x1F250, 0x209D5, 0x216F0, 0x228BA, 0x2379F, 0x24B0B, 0x2542E, 0x26A64, 0x27541, 0x28C69, nil];
NSArray * const VERSIONS = [self buildVersions];

@implementation Version

@synthesize versionNumber;
@synthesize alignmentPatternCenters;
@synthesize totalCodewords;
@synthesize dimensionForVersion;

- (id) init:(int)versionNumber alignmentPatternCenters:(NSArray *)alignmentPatternCenters ecBlocks1:(ECBlocks *)ecBlocks1 ecBlocks2:(ECBlocks *)ecBlocks2 ecBlocks3:(ECBlocks *)ecBlocks3 ecBlocks4:(ECBlocks *)ecBlocks4 {
  if (self = [super init]) {
    versionNumber = versionNumber;
    alignmentPatternCenters = alignmentPatternCenters;
    ecBlocks = [NSArray arrayWithObjects:ecBlocks1, ecBlocks2, ecBlocks3, ecBlocks4, nil];
    int total = 0;
    int ecCodewords = [ecBlocks1 eCCodewordsPerBlock];
    NSArray * ecbArray = [ecBlocks1 eCBlocks];

    for (int i = 0; i < ecbArray.length; i++) {
      ECB * ecBlock = ecbArray[i];
      total += [ecBlock count] * ([ecBlock dataCodewords] + ecCodewords);
    }

    totalCodewords = total;
  }
  return self;
}

- (int) dimensionForVersion {
  return 17 + 4 * versionNumber;
}

- (ECBlocks *) getECBlocksForLevel:(ErrorCorrectionLevel *)ecLevel {
  return ecBlocks[[ecLevel ordinal]];
}


/**
 * <p>Deduces version information purely from QR Code dimensions.</p>
 * 
 * @param dimension dimension in modules
 * @return Version for a QR Code of that dimension
 * @throws FormatException if dimension is not 1 mod 4
 */
+ (Version *) getProvisionalVersionForDimension:(int)dimension {
  if (dimension % 4 != 1) {
    @throw [FormatException formatInstance];
  }

  @try {
    return [self getVersionForNumber:(dimension - 17) >> 2];
  }
  @catch (IllegalArgumentException * iae) {
    @throw [FormatException formatInstance];
  }
}

+ (Version *) getVersionForNumber:(int)versionNumber {
  if (versionNumber < 1 || versionNumber > 40) {
    @throw [[[IllegalArgumentException alloc] init] autorelease];
  }
  return VERSIONS[versionNumber - 1];
}

+ (Version *) decodeVersionInformation:(int)versionBits {
  int bestDifference = Integer.MAX_VALUE;
  int bestVersion = 0;

  for (int i = 0; i < VERSION_DECODE_INFO.length; i++) {
    int targetVersion = VERSION_DECODE_INFO[i];
    if (targetVersion == versionBits) {
      return [self getVersionForNumber:i + 7];
    }
    int bitsDifference = [FormatInformation numBitsDiffering:versionBits param1:targetVersion];
    if (bitsDifference < bestDifference) {
      bestVersion = i + 7;
      bestDifference = bitsDifference;
    }
  }

  if (bestDifference <= 3) {
    return [self getVersionForNumber:bestVersion];
  }
  return nil;
}


/**
 * See ISO 18004:2006 Annex E
 */
- (BitMatrix *) buildFunctionPattern {
  int dimension = [self dimensionForVersion];
  BitMatrix * bitMatrix = [[[BitMatrix alloc] init:dimension] autorelease];
  [bitMatrix setRegion:0 param1:0 param2:9 param3:9];
  [bitMatrix setRegion:dimension - 8 param1:0 param2:8 param3:9];
  [bitMatrix setRegion:0 param1:dimension - 8 param2:9 param3:8];
  int max = alignmentPatternCenters.length;

  for (int x = 0; x < max; x++) {
    int i = alignmentPatternCenters[x] - 2;

    for (int y = 0; y < max; y++) {
      if ((x == 0 && (y == 0 || y == max - 1)) || (x == max - 1 && y == 0)) {
        continue;
      }
      [bitMatrix setRegion:alignmentPatternCenters[y] - 2 param1:i param2:5 param3:5];
    }

  }

  [bitMatrix setRegion:6 param1:9 param2:1 param3:dimension - 17];
  [bitMatrix setRegion:9 param1:6 param2:dimension - 17 param3:1];
  if (versionNumber > 6) {
    [bitMatrix setRegion:dimension - 11 param1:0 param2:3 param3:6];
    [bitMatrix setRegion:0 param1:dimension - 11 param2:6 param3:3];
  }
  return bitMatrix;
}

- (NSString *) description {
  return [String valueOf:versionNumber];
}


/**
 * See ISO 18004:2006 6.5.1 Table 9
 */
+ (NSArray *) buildVersions {
  return [NSArray arrayWithObjects:[[[Version alloc] init:1 param1:nil param2:[[[ECBlocks alloc] init:7 param1:[[[ECB alloc] init:1 param1:19] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:10 param1:[[[ECB alloc] init:1 param1:16] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:13 param1:[[[ECB alloc] init:1 param1:13] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:17 param1:[[[ECB alloc] init:1 param1:9] autorelease]] autorelease]] autorelease], [[[Version alloc] init:2 param1:[NSArray arrayWithObjects:6, 18, nil] param2:[[[ECBlocks alloc] init:10 param1:[[[ECB alloc] init:1 param1:34] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:16 param1:[[[ECB alloc] init:1 param1:28] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:22 param1:[[[ECB alloc] init:1 param1:22] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:1 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:3 param1:[NSArray arrayWithObjects:6, 22, nil] param2:[[[ECBlocks alloc] init:15 param1:[[[ECB alloc] init:1 param1:55] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:26 param1:[[[ECB alloc] init:1 param1:44] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:18 param1:[[[ECB alloc] init:2 param1:17] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:22 param1:[[[ECB alloc] init:2 param1:13] autorelease]] autorelease]] autorelease], [[[Version alloc] init:4 param1:[NSArray arrayWithObjects:6, 26, nil] param2:[[[ECBlocks alloc] init:20 param1:[[[ECB alloc] init:1 param1:80] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:18 param1:[[[ECB alloc] init:2 param1:32] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:26 param1:[[[ECB alloc] init:2 param1:24] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:16 param1:[[[ECB alloc] init:4 param1:9] autorelease]] autorelease]] autorelease], [[[Version alloc] init:5 param1:[NSArray arrayWithObjects:6, 30, nil] param2:[[[ECBlocks alloc] init:26 param1:[[[ECB alloc] init:1 param1:108] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:24 param1:[[[ECB alloc] init:2 param1:43] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:18 param1:[[[ECB alloc] init:2 param1:15] autorelease] param2:[[[ECB alloc] init:2 param1:16] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:22 param1:[[[ECB alloc] init:2 param1:11] autorelease] param2:[[[ECB alloc] init:2 param1:12] autorelease]] autorelease]] autorelease], [[[Version alloc] init:6 param1:[NSArray arrayWithObjects:6, 34, nil] param2:[[[ECBlocks alloc] init:18 param1:[[[ECB alloc] init:2 param1:68] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:16 param1:[[[ECB alloc] init:4 param1:27] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:24 param1:[[[ECB alloc] init:4 param1:19] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:4 param1:15] autorelease]] autorelease]] autorelease], [[[Version alloc] init:7 param1:[NSArray arrayWithObjects:6, 22, 38, nil] param2:[[[ECBlocks alloc] init:20 param1:[[[ECB alloc] init:2 param1:78] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:18 param1:[[[ECB alloc] init:4 param1:31] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:18 param1:[[[ECB alloc] init:2 param1:14] autorelease] param2:[[[ECB alloc] init:4 param1:15] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:26 param1:[[[ECB alloc] init:4 param1:13] autorelease] param2:[[[ECB alloc] init:1 param1:14] autorelease]] autorelease]] autorelease], [[[Version alloc] init:8 param1:[NSArray arrayWithObjects:6, 24, 42, nil] param2:[[[ECBlocks alloc] init:24 param1:[[[ECB alloc] init:2 param1:97] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:22 param1:[[[ECB alloc] init:2 param1:38] autorelease] param2:[[[ECB alloc] init:2 param1:39] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:22 param1:[[[ECB alloc] init:4 param1:18] autorelease] param2:[[[ECB alloc] init:2 param1:19] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:26 param1:[[[ECB alloc] init:4 param1:14] autorelease] param2:[[[ECB alloc] init:2 param1:15] autorelease]] autorelease]] autorelease], [[[Version alloc] init:9 param1:[NSArray arrayWithObjects:6, 26, 46, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:2 param1:116] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:22 param1:[[[ECB alloc] init:3 param1:36] autorelease] param2:[[[ECB alloc] init:2 param1:37] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:20 param1:[[[ECB alloc] init:4 param1:16] autorelease] param2:[[[ECB alloc] init:4 param1:17] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:24 param1:[[[ECB alloc] init:4 param1:12] autorelease] param2:[[[ECB alloc] init:4 param1:13] autorelease]] autorelease]] autorelease], [[[Version alloc] init:10 param1:[NSArray arrayWithObjects:6, 28, 50, nil] param2:[[[ECBlocks alloc] init:18 param1:[[[ECB alloc] init:2 param1:68] autorelease] param2:[[[ECB alloc] init:2 param1:69] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:26 param1:[[[ECB alloc] init:4 param1:43] autorelease] param2:[[[ECB alloc] init:1 param1:44] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:24 param1:[[[ECB alloc] init:6 param1:19] autorelease] param2:[[[ECB alloc] init:2 param1:20] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:6 param1:15] autorelease] param2:[[[ECB alloc] init:2 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:11 param1:[NSArray arrayWithObjects:6, 30, 54, nil] param2:[[[ECBlocks alloc] init:20 param1:[[[ECB alloc] init:4 param1:81] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:1 param1:50] autorelease] param2:[[[ECB alloc] init:4 param1:51] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:4 param1:22] autorelease] param2:[[[ECB alloc] init:4 param1:23] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:24 param1:[[[ECB alloc] init:3 param1:12] autorelease] param2:[[[ECB alloc] init:8 param1:13] autorelease]] autorelease]] autorelease], [[[Version alloc] init:12 param1:[NSArray arrayWithObjects:6, 32, 58, nil] param2:[[[ECBlocks alloc] init:24 param1:[[[ECB alloc] init:2 param1:92] autorelease] param2:[[[ECB alloc] init:2 param1:93] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:22 param1:[[[ECB alloc] init:6 param1:36] autorelease] param2:[[[ECB alloc] init:2 param1:37] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:26 param1:[[[ECB alloc] init:4 param1:20] autorelease] param2:[[[ECB alloc] init:6 param1:21] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:7 param1:14] autorelease] param2:[[[ECB alloc] init:4 param1:15] autorelease]] autorelease]] autorelease], [[[Version alloc] init:13 param1:[NSArray arrayWithObjects:6, 34, 62, nil] param2:[[[ECBlocks alloc] init:26 param1:[[[ECB alloc] init:4 param1:107] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:22 param1:[[[ECB alloc] init:8 param1:37] autorelease] param2:[[[ECB alloc] init:1 param1:38] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:24 param1:[[[ECB alloc] init:8 param1:20] autorelease] param2:[[[ECB alloc] init:4 param1:21] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:22 param1:[[[ECB alloc] init:12 param1:11] autorelease] param2:[[[ECB alloc] init:4 param1:12] autorelease]] autorelease]] autorelease], [[[Version alloc] init:14 param1:[NSArray arrayWithObjects:6, 26, 46, 66, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:3 param1:115] autorelease] param2:[[[ECB alloc] init:1 param1:116] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:24 param1:[[[ECB alloc] init:4 param1:40] autorelease] param2:[[[ECB alloc] init:5 param1:41] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:20 param1:[[[ECB alloc] init:11 param1:16] autorelease] param2:[[[ECB alloc] init:5 param1:17] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:24 param1:[[[ECB alloc] init:11 param1:12] autorelease] param2:[[[ECB alloc] init:5 param1:13] autorelease]] autorelease]] autorelease], [[[Version alloc] init:15 param1:[NSArray arrayWithObjects:6, 26, 48, 70, nil] param2:[[[ECBlocks alloc] init:22 param1:[[[ECB alloc] init:5 param1:87] autorelease] param2:[[[ECB alloc] init:1 param1:88] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:24 param1:[[[ECB alloc] init:5 param1:41] autorelease] param2:[[[ECB alloc] init:5 param1:42] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:5 param1:24] autorelease] param2:[[[ECB alloc] init:7 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:24 param1:[[[ECB alloc] init:11 param1:12] autorelease] param2:[[[ECB alloc] init:7 param1:13] autorelease]] autorelease]] autorelease], [[[Version alloc] init:16 param1:[NSArray arrayWithObjects:6, 26, 50, 74, nil] param2:[[[ECBlocks alloc] init:24 param1:[[[ECB alloc] init:5 param1:98] autorelease] param2:[[[ECB alloc] init:1 param1:99] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:7 param1:45] autorelease] param2:[[[ECB alloc] init:3 param1:46] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:24 param1:[[[ECB alloc] init:15 param1:19] autorelease] param2:[[[ECB alloc] init:2 param1:20] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:3 param1:15] autorelease] param2:[[[ECB alloc] init:13 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:17 param1:[NSArray arrayWithObjects:6, 30, 54, 78, nil] param2:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:1 param1:107] autorelease] param2:[[[ECB alloc] init:5 param1:108] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:10 param1:46] autorelease] param2:[[[ECB alloc] init:1 param1:47] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:1 param1:22] autorelease] param2:[[[ECB alloc] init:15 param1:23] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:2 param1:14] autorelease] param2:[[[ECB alloc] init:17 param1:15] autorelease]] autorelease]] autorelease], [[[Version alloc] init:18 param1:[NSArray arrayWithObjects:6, 30, 56, 82, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:5 param1:120] autorelease] param2:[[[ECB alloc] init:1 param1:121] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:26 param1:[[[ECB alloc] init:9 param1:43] autorelease] param2:[[[ECB alloc] init:4 param1:44] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:17 param1:22] autorelease] param2:[[[ECB alloc] init:1 param1:23] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:2 param1:14] autorelease] param2:[[[ECB alloc] init:19 param1:15] autorelease]] autorelease]] autorelease], [[[Version alloc] init:19 param1:[NSArray arrayWithObjects:6, 30, 58, 86, nil] param2:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:3 param1:113] autorelease] param2:[[[ECB alloc] init:4 param1:114] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:26 param1:[[[ECB alloc] init:3 param1:44] autorelease] param2:[[[ECB alloc] init:11 param1:45] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:26 param1:[[[ECB alloc] init:17 param1:21] autorelease] param2:[[[ECB alloc] init:4 param1:22] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:26 param1:[[[ECB alloc] init:9 param1:13] autorelease] param2:[[[ECB alloc] init:16 param1:14] autorelease]] autorelease]] autorelease], [[[Version alloc] init:20 param1:[NSArray arrayWithObjects:6, 34, 62, 90, nil] param2:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:3 param1:107] autorelease] param2:[[[ECB alloc] init:5 param1:108] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:26 param1:[[[ECB alloc] init:3 param1:41] autorelease] param2:[[[ECB alloc] init:13 param1:42] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:15 param1:24] autorelease] param2:[[[ECB alloc] init:5 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:15 param1:15] autorelease] param2:[[[ECB alloc] init:10 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:21 param1:[NSArray arrayWithObjects:6, 28, 50, 72, 94, nil] param2:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:4 param1:116] autorelease] param2:[[[ECB alloc] init:4 param1:117] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:26 param1:[[[ECB alloc] init:17 param1:42] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:17 param1:22] autorelease] param2:[[[ECB alloc] init:6 param1:23] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:19 param1:16] autorelease] param2:[[[ECB alloc] init:6 param1:17] autorelease]] autorelease]] autorelease], [[[Version alloc] init:22 param1:[NSArray arrayWithObjects:6, 26, 50, 74, 98, nil] param2:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:2 param1:111] autorelease] param2:[[[ECB alloc] init:7 param1:112] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:17 param1:46] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:7 param1:24] autorelease] param2:[[[ECB alloc] init:16 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:24 param1:[[[ECB alloc] init:34 param1:13] autorelease]] autorelease]] autorelease], [[[Version alloc] init:23 param1:[NSArray arrayWithObjects:6, 30, 54, 78, 102, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:4 param1:121] autorelease] param2:[[[ECB alloc] init:5 param1:122] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:4 param1:47] autorelease] param2:[[[ECB alloc] init:14 param1:48] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:11 param1:24] autorelease] param2:[[[ECB alloc] init:14 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:16 param1:15] autorelease] param2:[[[ECB alloc] init:14 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:24 param1:[NSArray arrayWithObjects:6, 28, 54, 80, 106, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:6 param1:117] autorelease] param2:[[[ECB alloc] init:4 param1:118] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:6 param1:45] autorelease] param2:[[[ECB alloc] init:14 param1:46] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:11 param1:24] autorelease] param2:[[[ECB alloc] init:16 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:30 param1:16] autorelease] param2:[[[ECB alloc] init:2 param1:17] autorelease]] autorelease]] autorelease], [[[Version alloc] init:25 param1:[NSArray arrayWithObjects:6, 32, 58, 84, 110, nil] param2:[[[ECBlocks alloc] init:26 param1:[[[ECB alloc] init:8 param1:106] autorelease] param2:[[[ECB alloc] init:4 param1:107] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:8 param1:47] autorelease] param2:[[[ECB alloc] init:13 param1:48] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:7 param1:24] autorelease] param2:[[[ECB alloc] init:22 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:22 param1:15] autorelease] param2:[[[ECB alloc] init:13 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:26 param1:[NSArray arrayWithObjects:6, 30, 58, 86, 114, nil] param2:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:10 param1:114] autorelease] param2:[[[ECB alloc] init:2 param1:115] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:19 param1:46] autorelease] param2:[[[ECB alloc] init:4 param1:47] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:28 param1:22] autorelease] param2:[[[ECB alloc] init:6 param1:23] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:33 param1:16] autorelease] param2:[[[ECB alloc] init:4 param1:17] autorelease]] autorelease]] autorelease], [[[Version alloc] init:27 param1:[NSArray arrayWithObjects:6, 34, 62, 90, 118, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:8 param1:122] autorelease] param2:[[[ECB alloc] init:4 param1:123] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:22 param1:45] autorelease] param2:[[[ECB alloc] init:3 param1:46] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:8 param1:23] autorelease] param2:[[[ECB alloc] init:26 param1:24] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:12 param1:15] autorelease] param2:[[[ECB alloc] init:28 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:28 param1:[NSArray arrayWithObjects:6, 26, 50, 74, 98, 122, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:3 param1:117] autorelease] param2:[[[ECB alloc] init:10 param1:118] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:3 param1:45] autorelease] param2:[[[ECB alloc] init:23 param1:46] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:4 param1:24] autorelease] param2:[[[ECB alloc] init:31 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:11 param1:15] autorelease] param2:[[[ECB alloc] init:31 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:29 param1:[NSArray arrayWithObjects:6, 30, 54, 78, 102, 126, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:7 param1:116] autorelease] param2:[[[ECB alloc] init:7 param1:117] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:21 param1:45] autorelease] param2:[[[ECB alloc] init:7 param1:46] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:1 param1:23] autorelease] param2:[[[ECB alloc] init:37 param1:24] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:19 param1:15] autorelease] param2:[[[ECB alloc] init:26 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:30 param1:[NSArray arrayWithObjects:6, 26, 52, 78, 104, 130, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:5 param1:115] autorelease] param2:[[[ECB alloc] init:10 param1:116] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:19 param1:47] autorelease] param2:[[[ECB alloc] init:10 param1:48] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:15 param1:24] autorelease] param2:[[[ECB alloc] init:25 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:23 param1:15] autorelease] param2:[[[ECB alloc] init:25 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:31 param1:[NSArray arrayWithObjects:6, 30, 56, 82, 108, 134, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:13 param1:115] autorelease] param2:[[[ECB alloc] init:3 param1:116] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:2 param1:46] autorelease] param2:[[[ECB alloc] init:29 param1:47] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:42 param1:24] autorelease] param2:[[[ECB alloc] init:1 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:23 param1:15] autorelease] param2:[[[ECB alloc] init:28 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:32 param1:[NSArray arrayWithObjects:6, 34, 60, 86, 112, 138, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:17 param1:115] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:10 param1:46] autorelease] param2:[[[ECB alloc] init:23 param1:47] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:10 param1:24] autorelease] param2:[[[ECB alloc] init:35 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:19 param1:15] autorelease] param2:[[[ECB alloc] init:35 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:33 param1:[NSArray arrayWithObjects:6, 30, 58, 86, 114, 142, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:17 param1:115] autorelease] param2:[[[ECB alloc] init:1 param1:116] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:14 param1:46] autorelease] param2:[[[ECB alloc] init:21 param1:47] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:29 param1:24] autorelease] param2:[[[ECB alloc] init:19 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:11 param1:15] autorelease] param2:[[[ECB alloc] init:46 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:34 param1:[NSArray arrayWithObjects:6, 34, 62, 90, 118, 146, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:13 param1:115] autorelease] param2:[[[ECB alloc] init:6 param1:116] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:14 param1:46] autorelease] param2:[[[ECB alloc] init:23 param1:47] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:44 param1:24] autorelease] param2:[[[ECB alloc] init:7 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:59 param1:16] autorelease] param2:[[[ECB alloc] init:1 param1:17] autorelease]] autorelease]] autorelease], [[[Version alloc] init:35 param1:[NSArray arrayWithObjects:6, 30, 54, 78, 102, 126, 150, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:12 param1:121] autorelease] param2:[[[ECB alloc] init:7 param1:122] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:12 param1:47] autorelease] param2:[[[ECB alloc] init:26 param1:48] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:39 param1:24] autorelease] param2:[[[ECB alloc] init:14 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:22 param1:15] autorelease] param2:[[[ECB alloc] init:41 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:36 param1:[NSArray arrayWithObjects:6, 24, 50, 76, 102, 128, 154, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:6 param1:121] autorelease] param2:[[[ECB alloc] init:14 param1:122] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:6 param1:47] autorelease] param2:[[[ECB alloc] init:34 param1:48] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:46 param1:24] autorelease] param2:[[[ECB alloc] init:10 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:2 param1:15] autorelease] param2:[[[ECB alloc] init:64 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:37 param1:[NSArray arrayWithObjects:6, 28, 54, 80, 106, 132, 158, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:17 param1:122] autorelease] param2:[[[ECB alloc] init:4 param1:123] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:29 param1:46] autorelease] param2:[[[ECB alloc] init:14 param1:47] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:49 param1:24] autorelease] param2:[[[ECB alloc] init:10 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:24 param1:15] autorelease] param2:[[[ECB alloc] init:46 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:38 param1:[NSArray arrayWithObjects:6, 32, 58, 84, 110, 136, 162, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:4 param1:122] autorelease] param2:[[[ECB alloc] init:18 param1:123] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:13 param1:46] autorelease] param2:[[[ECB alloc] init:32 param1:47] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:48 param1:24] autorelease] param2:[[[ECB alloc] init:14 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:42 param1:15] autorelease] param2:[[[ECB alloc] init:32 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:39 param1:[NSArray arrayWithObjects:6, 26, 54, 82, 110, 138, 166, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:20 param1:117] autorelease] param2:[[[ECB alloc] init:4 param1:118] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:40 param1:47] autorelease] param2:[[[ECB alloc] init:7 param1:48] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:43 param1:24] autorelease] param2:[[[ECB alloc] init:22 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:10 param1:15] autorelease] param2:[[[ECB alloc] init:67 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:40 param1:[NSArray arrayWithObjects:6, 30, 58, 86, 114, 142, 170, nil] param2:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:19 param1:118] autorelease] param2:[[[ECB alloc] init:6 param1:119] autorelease]] autorelease] param3:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:18 param1:47] autorelease] param2:[[[ECB alloc] init:31 param1:48] autorelease]] autorelease] param4:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:34 param1:24] autorelease] param2:[[[ECB alloc] init:34 param1:25] autorelease]] autorelease] param5:[[[ECBlocks alloc] init:30 param1:[[[ECB alloc] init:20 param1:15] autorelease] param2:[[[ECB alloc] init:61 param1:16] autorelease]] autorelease]] autorelease], nil];
}

- (void) dealloc {
  [alignmentPatternCenters release];
  [ecBlocks release];
  [super dealloc];
}

@end
