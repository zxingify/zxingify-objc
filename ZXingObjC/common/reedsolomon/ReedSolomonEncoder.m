#import "GenericGF.h"
#import "ReedSolomonEncoder.h"

@implementation ReedSolomonEncoder

- (id) initWithField:(GenericGF *)field {
  if (self = [super init]) {
    if (![GenericGF.QR_CODE_FIELD_256 isEqualTo:field]) {
      @throw [[[IllegalArgumentException alloc] init:@"Only QR Code is supported at this time"] autorelease];
    }
    field = field;
    cachedGenerators = [[[NSMutableArray alloc] init] autorelease];
    [cachedGenerators addObject:[[[GenericGFPoly alloc] init:field param1:[NSArray arrayWithObjects:1, nil]] autorelease]];
  }
  return self;
}

- (GenericGFPoly *) buildGenerator:(int)degree {
  if (degree >= [cachedGenerators count]) {
    GenericGFPoly * lastGenerator = (GenericGFPoly *)[cachedGenerators objectAtIndex:[cachedGenerators count] - 1];

    for (int d = [cachedGenerators count]; d <= degree; d++) {
      GenericGFPoly * nextGenerator = [lastGenerator multiply:[[[GenericGFPoly alloc] init:field param1:[NSArray arrayWithObjects:1, [field exp:d - 1], nil]] autorelease]];
      [cachedGenerators addObject:nextGenerator];
      lastGenerator = nextGenerator;
    }

  }
  return (GenericGFPoly *)[cachedGenerators objectAtIndex:degree];
}

- (void) encode:(NSArray *)toEncode ecBytes:(int)ecBytes {
  if (ecBytes == 0) {
    @throw [[[IllegalArgumentException alloc] init:@"No error correction bytes"] autorelease];
  }
  int dataBytes = toEncode.length - ecBytes;
  if (dataBytes <= 0) {
    @throw [[[IllegalArgumentException alloc] init:@"No data bytes provided"] autorelease];
  }
  GenericGFPoly * generator = [self buildGenerator:ecBytes];
  NSArray * infoCoefficients = [NSArray array];
  [System arraycopy:toEncode param1:0 param2:infoCoefficients param3:0 param4:dataBytes];
  GenericGFPoly * info = [[[GenericGFPoly alloc] init:field param1:infoCoefficients] autorelease];
  info = [info multiplyByMonomial:ecBytes param1:1];
  GenericGFPoly * remainder = [info divide:generator][1];
  NSArray * coefficients = [remainder coefficients];
  int numZeroCoefficients = ecBytes - coefficients.length;

  for (int i = 0; i < numZeroCoefficients; i++) {
    toEncode[dataBytes + i] = 0;
  }

  [System arraycopy:coefficients param1:0 param2:toEncode param3:dataBytes + numZeroCoefficients param4:coefficients.length];
}

- (void) dealloc {
  [field release];
  [cachedGenerators release];
  [super dealloc];
}

@end
