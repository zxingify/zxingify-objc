#import "GenericGF.h"
#import "ReedSolomonEncoder.h"

@implementation ReedSolomonEncoder

- (id) initWithField:(GenericGF *)aField {
  if (self = [super init]) {
    if (![[GenericGF QrCodeField256] isEqual:aField]) {
      @throw [NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"Only QR Code is supported at this time"
                                   userInfo:nil];
    }
    field = [aField retain];
    cachedGenerators = [[NSMutableArray alloc] initWithObjects:
                        [[[GenericGFPoly alloc] initWithField:aField
                                                 coefficients:[NSArray arrayWithObject:[NSNumber numberWithInt:1]]] autorelease], nil];
  }
  return self;
}

- (GenericGFPoly *) buildGenerator:(int)degree {
  if (degree >= [cachedGenerators count]) {
    GenericGFPoly * lastGenerator = (GenericGFPoly *)[cachedGenerators objectAtIndex:[cachedGenerators count] - 1];

    for (int d = [cachedGenerators count]; d <= degree; d++) {
      GenericGFPoly * nextGenerator = [lastGenerator multiply:[[[GenericGFPoly alloc] initWithField:field coefficients:[NSArray arrayWithObjects:[NSNumber numberWithInt:1], [field exp:d - 1], nil]] autorelease]];
      [cachedGenerators addObject:nextGenerator];
      lastGenerator = nextGenerator;
    }

  }
  return (GenericGFPoly *)[cachedGenerators objectAtIndex:degree];
}

- (void) encode:(NSMutableArray *)toEncode ecBytes:(int)ecBytes {
  if (ecBytes == 0) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"No error correction bytes"
                                 userInfo:nil];
  }
  int dataBytes = [toEncode count] - ecBytes;
  if (dataBytes <= 0) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"No data bytes provided"
                                 userInfo:nil];
  }
  GenericGFPoly * generator = [self buildGenerator:ecBytes];
  NSArray * infoCoefficients = [toEncode copy];
  GenericGFPoly * info = [[[GenericGFPoly alloc] initWithField:field coefficients:infoCoefficients] autorelease];
  info = [info multiplyByMonomial:ecBytes coefficient:1];
  GenericGFPoly * remainder = [[info divide:generator] objectAtIndex:1];
  NSArray * coefficients = [remainder coefficients];
  int numZeroCoefficients = ecBytes - [coefficients count];

  for (int i = 0; i < numZeroCoefficients; i++) {
    [toEncode replaceObjectAtIndex:dataBytes + i withObject:[NSNumber numberWithInt:0]];
  }

  for (int i = 0; i < [coefficients count]; i++) {
    [toEncode replaceObjectAtIndex:dataBytes + numZeroCoefficients + i withObject:[coefficients objectAtIndex:dataBytes + numZeroCoefficients + i]];
  }
}

- (void) dealloc {
  [field release];
  [cachedGenerators release];
  [super dealloc];
}

@end
