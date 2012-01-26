#import "Version.h"

@implementation ECBlocks

- (id) init:(int)ecCodewords ecBlocks:(ECB *)ecBlocks {
  if (self = [super init]) {
    ecCodewords = ecCodewords;
    ecBlocks = [NSArray arrayWithObjects:ecBlocks, nil];
  }
  return self;
}

- (id) init:(int)ecCodewords ecBlocks1:(ECB *)ecBlocks1 ecBlocks2:(ECB *)ecBlocks2 {
  if (self = [super init]) {
    ecCodewords = ecCodewords;
    ecBlocks = [NSArray arrayWithObjects:ecBlocks1, ecBlocks2, nil];
  }
  return self;
}

- (int) getECCodewords {
  return ecCodewords;
}

- (NSArray *) getECBlocks {
  return ecBlocks;
}

- (void) dealloc {
  [ecBlocks release];
  [super dealloc];
}

@end

@implementation ECB

- (id) init:(int)count dataCodewords:(int)dataCodewords {
  if (self = [super init]) {
    count = count;
    dataCodewords = dataCodewords;
  }
  return self;
}

- (int) getCount {
  return count;
}

- (int) getDataCodewords {
  return dataCodewords;
}

@end

NSArray * const VERSIONS = [self buildVersions];

@implementation Version

@synthesize versionNumber;
@synthesize symbolSizeRows;
@synthesize symbolSizeColumns;
@synthesize dataRegionSizeRows;
@synthesize dataRegionSizeColumns;
@synthesize totalCodewords;

- (id) init:(int)versionNumber symbolSizeRows:(int)symbolSizeRows symbolSizeColumns:(int)symbolSizeColumns dataRegionSizeRows:(int)dataRegionSizeRows dataRegionSizeColumns:(int)dataRegionSizeColumns ecBlocks:(ECBlocks *)ecBlocks {
  if (self = [super init]) {
    versionNumber = versionNumber;
    symbolSizeRows = symbolSizeRows;
    symbolSizeColumns = symbolSizeColumns;
    dataRegionSizeRows = dataRegionSizeRows;
    dataRegionSizeColumns = dataRegionSizeColumns;
    ecBlocks = ecBlocks;
    int total = 0;
    int ecCodewords = [ecBlocks eCCodewords];
    NSArray * ecbArray = [ecBlocks eCBlocks];

    for (int i = 0; i < ecbArray.length; i++) {
      ECB * ecBlock = ecbArray[i];
      total += [ecBlock count] * ([ecBlock dataCodewords] + ecCodewords);
    }

    totalCodewords = total;
  }
  return self;
}

- (ECBlocks *) getECBlocks {
  return ecBlocks;
}


/**
 * <p>Deduces version information from Data Matrix dimensions.</p>
 * 
 * @param numRows Number of rows in modules
 * @param numColumns Number of columns in modules
 * @return Version for a Data Matrix Code of those dimensions
 * @throws FormatException if dimensions do correspond to a valid Data Matrix size
 */
+ (Version *) getVersionForDimensions:(int)numRows numColumns:(int)numColumns {
  if ((numRows & 0x01) != 0 || (numColumns & 0x01) != 0) {
    @throw [FormatException formatInstance];
  }
  int numVersions = VERSIONS.length;

  for (int i = 0; i < numVersions; ++i) {
    Version * version = VERSIONS[i];
    if (version.symbolSizeRows == numRows && version.symbolSizeColumns == numColumns) {
      return version;
    }
  }

  @throw [FormatException formatInstance];
}

- (NSString *) description {
  return [String valueOf:versionNumber];
}


/**
 * See ISO 16022:2006 5.5.1 Table 7
 */
+ (NSArray *) buildVersions {
  return [NSArray arrayWithObjects:[[[Version alloc] init:1 param1:10 param2:10 param3:8 param4:8 param5:[[[ECBlocks alloc] init:5 param1:[[[ECB alloc] init:1 param1:3] autorelease]] autorelease]] autorelease], [[[Version alloc] init:2 param1:12 param2:12 param3:10 param4:10 param5:[[[ECBlocks alloc] init:7 param1:[[[ECB alloc] init:1 param1:5] autorelease]] autorelease]] autorelease], [[[Version alloc] init:3 param1:14 param2:14 param3:12 param4:12 param5:[[[ECBlocks alloc] init:10 param1:[[[ECB alloc] init:1 param1:8] autorelease]] autorelease]] autorelease], [[[Version alloc] init:4 param1:16 param2:16 param3:14 param4:14 param5:[[[ECBlocks alloc] init:12 param1:[[[ECB alloc] init:1 param1:12] autorelease]] autorelease]] autorelease], [[[Version alloc] init:5 param1:18 param2:18 param3:16 param4:16 param5:[[[ECBlocks alloc] init:14 param1:[[[ECB alloc] init:1 param1:18] autorelease]] autorelease]] autorelease], [[[Version alloc] init:6 param1:20 param2:20 param3:18 param4:18 param5:[[[ECBlocks alloc] init:18 param1:[[[ECB alloc] init:1 param1:22] autorelease]] autorelease]] autorelease], [[[Version alloc] init:7 param1:22 param2:22 param3:20 param4:20 param5:[[[ECBlocks alloc] init:20 param1:[[[ECB alloc] init:1 param1:30] autorelease]] autorelease]] autorelease], [[[Version alloc] init:8 param1:24 param2:24 param3:22 param4:22 param5:[[[ECBlocks alloc] init:24 param1:[[[ECB alloc] init:1 param1:36] autorelease]] autorelease]] autorelease], [[[Version alloc] init:9 param1:26 param2:26 param3:24 param4:24 param5:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:1 param1:44] autorelease]] autorelease]] autorelease], [[[Version alloc] init:10 param1:32 param2:32 param3:14 param4:14 param5:[[[ECBlocks alloc] init:36 param1:[[[ECB alloc] init:1 param1:62] autorelease]] autorelease]] autorelease], [[[Version alloc] init:11 param1:36 param2:36 param3:16 param4:16 param5:[[[ECBlocks alloc] init:42 param1:[[[ECB alloc] init:1 param1:86] autorelease]] autorelease]] autorelease], [[[Version alloc] init:12 param1:40 param2:40 param3:18 param4:18 param5:[[[ECBlocks alloc] init:48 param1:[[[ECB alloc] init:1 param1:114] autorelease]] autorelease]] autorelease], [[[Version alloc] init:13 param1:44 param2:44 param3:20 param4:20 param5:[[[ECBlocks alloc] init:56 param1:[[[ECB alloc] init:1 param1:144] autorelease]] autorelease]] autorelease], [[[Version alloc] init:14 param1:48 param2:48 param3:22 param4:22 param5:[[[ECBlocks alloc] init:68 param1:[[[ECB alloc] init:1 param1:174] autorelease]] autorelease]] autorelease], [[[Version alloc] init:15 param1:52 param2:52 param3:24 param4:24 param5:[[[ECBlocks alloc] init:42 param1:[[[ECB alloc] init:2 param1:102] autorelease]] autorelease]] autorelease], [[[Version alloc] init:16 param1:64 param2:64 param3:14 param4:14 param5:[[[ECBlocks alloc] init:56 param1:[[[ECB alloc] init:2 param1:140] autorelease]] autorelease]] autorelease], [[[Version alloc] init:17 param1:72 param2:72 param3:16 param4:16 param5:[[[ECBlocks alloc] init:36 param1:[[[ECB alloc] init:4 param1:92] autorelease]] autorelease]] autorelease], [[[Version alloc] init:18 param1:80 param2:80 param3:18 param4:18 param5:[[[ECBlocks alloc] init:48 param1:[[[ECB alloc] init:4 param1:114] autorelease]] autorelease]] autorelease], [[[Version alloc] init:19 param1:88 param2:88 param3:20 param4:20 param5:[[[ECBlocks alloc] init:56 param1:[[[ECB alloc] init:4 param1:144] autorelease]] autorelease]] autorelease], [[[Version alloc] init:20 param1:96 param2:96 param3:22 param4:22 param5:[[[ECBlocks alloc] init:68 param1:[[[ECB alloc] init:4 param1:174] autorelease]] autorelease]] autorelease], [[[Version alloc] init:21 param1:104 param2:104 param3:24 param4:24 param5:[[[ECBlocks alloc] init:56 param1:[[[ECB alloc] init:6 param1:136] autorelease]] autorelease]] autorelease], [[[Version alloc] init:22 param1:120 param2:120 param3:18 param4:18 param5:[[[ECBlocks alloc] init:68 param1:[[[ECB alloc] init:6 param1:175] autorelease]] autorelease]] autorelease], [[[Version alloc] init:23 param1:132 param2:132 param3:20 param4:20 param5:[[[ECBlocks alloc] init:62 param1:[[[ECB alloc] init:8 param1:163] autorelease]] autorelease]] autorelease], [[[Version alloc] init:24 param1:144 param2:144 param3:22 param4:22 param5:[[[ECBlocks alloc] init:62 param1:[[[ECB alloc] init:8 param1:156] autorelease] param2:[[[ECB alloc] init:2 param1:155] autorelease]] autorelease]] autorelease], [[[Version alloc] init:25 param1:8 param2:18 param3:6 param4:16 param5:[[[ECBlocks alloc] init:7 param1:[[[ECB alloc] init:1 param1:5] autorelease]] autorelease]] autorelease], [[[Version alloc] init:26 param1:8 param2:32 param3:6 param4:14 param5:[[[ECBlocks alloc] init:11 param1:[[[ECB alloc] init:1 param1:10] autorelease]] autorelease]] autorelease], [[[Version alloc] init:27 param1:12 param2:26 param3:10 param4:24 param5:[[[ECBlocks alloc] init:14 param1:[[[ECB alloc] init:1 param1:16] autorelease]] autorelease]] autorelease], [[[Version alloc] init:28 param1:12 param2:36 param3:10 param4:16 param5:[[[ECBlocks alloc] init:18 param1:[[[ECB alloc] init:1 param1:22] autorelease]] autorelease]] autorelease], [[[Version alloc] init:29 param1:16 param2:36 param3:14 param4:16 param5:[[[ECBlocks alloc] init:24 param1:[[[ECB alloc] init:1 param1:32] autorelease]] autorelease]] autorelease], [[[Version alloc] init:30 param1:16 param2:48 param3:14 param4:22 param5:[[[ECBlocks alloc] init:28 param1:[[[ECB alloc] init:1 param1:49] autorelease]] autorelease]] autorelease], nil];
}

- (void) dealloc {
  [ecBlocks release];
  [super dealloc];
}

@end
