#import "DataMatrixVersion.h"
#import "FormatException.h"

@implementation DataMatrixECBlocks

@synthesize ecCodewords, ecBlocks;

- (id) initWithCodewords:(int)theEcCodewords ecBlocks:(DataMatrixECB *)theEcBlocks {
  if (self = [super init]) {
    ecCodewords = theEcCodewords;
    ecBlocks = [NSArray arrayWithObjects:theEcBlocks, nil];
  }
  return self;
}

- (id) initWithCodewords:(int)theEcCodewords ecBlocks1:(DataMatrixECB *)ecBlocks1 ecBlocks2:(DataMatrixECB *)ecBlocks2 {
  if (self = [super init]) {
    ecCodewords = theEcCodewords;
    ecBlocks = [NSArray arrayWithObjects:ecBlocks1, ecBlocks2, nil];
  }
  return self;
}

- (void) dealloc {
  [ecBlocks release];
  [super dealloc];
}

@end


@implementation DataMatrixECB

@synthesize count, dataCodewords;

- (id) initWithCount:(int)aCount dataCodewords:(int)theDataCodewords {
  if (self = [super init]) {
    count = aCount;
    dataCodewords = theDataCodewords;
  }
  return self;
}

@end

@interface DataMatrixVersion ()

+ (NSArray *) buildVersions;

@end

@implementation DataMatrixVersion

@synthesize ecBlocks;
@synthesize versionNumber;
@synthesize symbolSizeRows;
@synthesize symbolSizeColumns;
@synthesize dataRegionSizeRows;
@synthesize dataRegionSizeColumns;
@synthesize totalCodewords;

- (id) initWithVersionNumber:(int)aVersionNumber symbolSizeRows:(int)theSymbolSizeRows symbolSizeColumns:(int)theSymbolSizeColumns dataRegionSizeRows:(int)theDataRegionSizeRows dataRegionSizeColumns:(int)theDataRegionSizeColumns ecBlocks:(DataMatrixECBlocks *)anEcBlocks {
  if (self = [super init]) {
    versionNumber = aVersionNumber;
    symbolSizeRows = theSymbolSizeRows;
    symbolSizeColumns = theSymbolSizeColumns;
    dataRegionSizeRows = theDataRegionSizeRows;
    dataRegionSizeColumns = theDataRegionSizeColumns;
    ecBlocks = [anEcBlocks retain];
    int total = 0;
    int ecCodewords = ecBlocks.ecCodewords;
    NSArray * ecbArray = ecBlocks.ecBlocks;

    for (DataMatrixECB *ecBlock in ecbArray) {
      total += [ecBlock count] * ([ecBlock dataCodewords] + ecCodewords);
    }

    totalCodewords = total;
  }
  return self;
}


/**
 * <p>Deduces version information from Data Matrix dimensions.</p>
 * 
 * @param numRows Number of rows in modules
 * @param numColumns Number of columns in modules
 * @return Version for a Data Matrix Code of those dimensions
 * @throws FormatException if dimensions do correspond to a valid Data Matrix size
 */
+ (DataMatrixVersion *) getVersionForDimensions:(int)numRows numColumns:(int)numColumns {
  static NSArray* VERSIONS = nil;

  if (!VERSIONS) {
    VERSIONS = [self buildVersions];
  }

  if ((numRows & 0x01) != 0 || (numColumns & 0x01) != 0) {
    @throw [FormatException formatInstance];
  }

  for (DataMatrixVersion *version in VERSIONS) {
    if (version.symbolSizeRows == numRows && version.symbolSizeColumns == numColumns) {
      return version;
    }
  }

  @throw [FormatException formatInstance];
}

- (NSString *) description {
  return [[NSNumber numberWithInt:versionNumber] stringValue];
}


/**
 * See ISO 16022:2006 5.5.1 Table 7
 */
+ (NSArray *) buildVersions {
  return [[NSArray alloc] initWithObjects:
          [[[DataMatrixVersion alloc] initWithVersionNumber:1
                                             symbolSizeRows:10
                                          symbolSizeColumns:10
                                         dataRegionSizeRows:8
                                      dataRegionSizeColumns:8
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:5
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:3] autorelease]] autorelease]] autorelease],

          [[[DataMatrixVersion alloc] initWithVersionNumber:2
                                             symbolSizeRows:12
                                          symbolSizeColumns:12
                                         dataRegionSizeRows:10
                                      dataRegionSizeColumns:10
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:7
                                          ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                                 dataCodewords:5] autorelease]] autorelease]] autorelease],

          [[[DataMatrixVersion alloc] initWithVersionNumber:3
                                             symbolSizeRows:14
                                          symbolSizeColumns:14
                                         dataRegionSizeRows:12
                                      dataRegionSizeColumns:12
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:10
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:8] autorelease]] autorelease]] autorelease],

          [[[DataMatrixVersion alloc] initWithVersionNumber:4
                                             symbolSizeRows:16
                                          symbolSizeColumns:16
                                         dataRegionSizeRows:14
                                      dataRegionSizeColumns:14
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:12
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:12] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:5
                                             symbolSizeRows:18
                                          symbolSizeColumns:18
                                         dataRegionSizeRows:16
                                      dataRegionSizeColumns:16
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:14
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:18] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:6
                                             symbolSizeRows:20
                                          symbolSizeColumns:20
                                         dataRegionSizeRows:18
                                      dataRegionSizeColumns:18
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:18
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:22] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:7
                                             symbolSizeRows:22
                                          symbolSizeColumns:22
                                         dataRegionSizeRows:20
                                      dataRegionSizeColumns:20
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:20
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:30] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:8
                                             symbolSizeRows:24
                                          symbolSizeColumns:24
                                         dataRegionSizeRows:22
                                      dataRegionSizeColumns:22
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:24
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:36] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:9
                                             symbolSizeRows:26
                                          symbolSizeColumns:26
                                         dataRegionSizeRows:24
                                      dataRegionSizeColumns:24
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:28
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:44] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:10
                                             symbolSizeRows:32
                                          symbolSizeColumns:32
                                         dataRegionSizeRows:14
                                      dataRegionSizeColumns:14
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:36
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:62] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:11
                                             symbolSizeRows:36
                                          symbolSizeColumns:36
                                         dataRegionSizeRows:16
                                      dataRegionSizeColumns:16
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:42
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:86] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:12
                                             symbolSizeRows:40
                                          symbolSizeColumns:40
                                         dataRegionSizeRows:18
                                      dataRegionSizeColumns:18
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:48
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:114] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:13
                                             symbolSizeRows:44
                                          symbolSizeColumns:44
                                         dataRegionSizeRows:20
                                      dataRegionSizeColumns:20
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:56
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:144] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:14
                                             symbolSizeRows:48
                                          symbolSizeColumns:48
                                         dataRegionSizeRows:22
                                      dataRegionSizeColumns:22
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:68
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:174] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:15
                                             symbolSizeRows:52
                                          symbolSizeColumns:52
                                         dataRegionSizeRows:24
                                      dataRegionSizeColumns:24
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:42
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:2
                                                               dataCodewords:102] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:16
                                             symbolSizeRows:64
                                          symbolSizeColumns:64
                                         dataRegionSizeRows:14
                                      dataRegionSizeColumns:14
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:56
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:2
                                                               dataCodewords:140] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:17
                                             symbolSizeRows:72
                                          symbolSizeColumns:72
                                         dataRegionSizeRows:16
                                      dataRegionSizeColumns:16
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:36
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:4
                                                               dataCodewords:92] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:18
                                             symbolSizeRows:80
                                          symbolSizeColumns:80
                                         dataRegionSizeRows:18
                                      dataRegionSizeColumns:18
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:48
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:4
                                                               dataCodewords:114] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:19
                                             symbolSizeRows:88
                                          symbolSizeColumns:88
                                         dataRegionSizeRows:20
                                      dataRegionSizeColumns:20
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:56
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:4
                                                               dataCodewords:144] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:20
                                             symbolSizeRows:96
                                          symbolSizeColumns:96
                                         dataRegionSizeRows:22
                                      dataRegionSizeColumns:22
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:68
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:4
                                                               dataCodewords:174] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:21
                                             symbolSizeRows:104
                                          symbolSizeColumns:104
                                         dataRegionSizeRows:24
                                      dataRegionSizeColumns:24
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:56
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:6
                                                               dataCodewords:136] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:22
                                             symbolSizeRows:120
                                          symbolSizeColumns:120
                                         dataRegionSizeRows:18
                                      dataRegionSizeColumns:18
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:68
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:6
                                                               dataCodewords:175] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:23
                                             symbolSizeRows:132
                                          symbolSizeColumns:132
                                         dataRegionSizeRows:20
                                      dataRegionSizeColumns:20
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:62
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:8
                                                               dataCodewords:163] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:24
                                             symbolSizeRows:144
                                          symbolSizeColumns:144
                                         dataRegionSizeRows:22
                                      dataRegionSizeColumns:22
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:62
                                       ecBlocks1:[[[DataMatrixECB alloc] initWithCount:8
                                                               dataCodewords:156] autorelease]
                                       ecBlocks2:[[[DataMatrixECB alloc] initWithCount:2
                                                               dataCodewords:155] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:25
                                             symbolSizeRows:8
                                          symbolSizeColumns:18
                                         dataRegionSizeRows:6
                                      dataRegionSizeColumns:16
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:7
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:5] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:26
                                             symbolSizeRows:8
                                          symbolSizeColumns:32
                                         dataRegionSizeRows:6
                                      dataRegionSizeColumns:14
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:11
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:10] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:27
                                             symbolSizeRows:12
                                          symbolSizeColumns:26
                                         dataRegionSizeRows:10
                                      dataRegionSizeColumns:24
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:14
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:16] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:28
                                             symbolSizeRows:12
                                          symbolSizeColumns:36
                                         dataRegionSizeRows:10
                                      dataRegionSizeColumns:16
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:18
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:22] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:29
                                             symbolSizeRows:16
                                          symbolSizeColumns:36
                                         dataRegionSizeRows:14
                                      dataRegionSizeColumns:16
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:24
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:32] autorelease]] autorelease]] autorelease],
          
          [[[DataMatrixVersion alloc] initWithVersionNumber:30
                                             symbolSizeRows:16
                                          symbolSizeColumns:48
                                         dataRegionSizeRows:14
                                      dataRegionSizeColumns:22
                                                   ecBlocks:
            [[[DataMatrixECBlocks alloc] initWithCodewords:28
                                        ecBlocks:[[[DataMatrixECB alloc] initWithCount:1
                                                               dataCodewords:49] autorelease]] autorelease]] autorelease],
          
           nil];
}

- (void) dealloc {
  [ecBlocks release];
  [super dealloc];
}

@end
