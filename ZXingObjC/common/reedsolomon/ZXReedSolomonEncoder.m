#import "ZXGenericGF.h"
#import "ZXGenericGFPoly.h"
#import "ZXReedSolomonEncoder.h"

@interface ZXReedSolomonEncoder ()

@property (nonatomic, retain) NSMutableArray * cachedGenerators;
@property (nonatomic, retain) ZXGenericGF * field;

@end


@implementation ZXReedSolomonEncoder

@synthesize cachedGenerators;
@synthesize field;

- (id)initWithField:(ZXGenericGF *)aField {
  if (self = [super init]) {
    if (![[ZXGenericGF QrCodeField256] isEqual:aField]) {
      @throw [NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"Only QR Code is supported at this time"
                                   userInfo:nil];
    }
    self.field = aField;
    self.cachedGenerators = [NSMutableArray arrayWithObject:[[[ZXGenericGFPoly alloc] initWithField:aField coefficients:[NSArray arrayWithObject:[NSNumber numberWithInt:1]]] autorelease]];
  }

  return self;
}

- (void)dealloc {
  [cachedGenerators release];
  [field release];

  [super dealloc];
}

- (ZXGenericGFPoly *)buildGenerator:(int)degree {
  if (degree >= self.cachedGenerators.count) {
    ZXGenericGFPoly * lastGenerator = (ZXGenericGFPoly *)[self.cachedGenerators objectAtIndex:[cachedGenerators count] - 1];
    for (int d = [self.cachedGenerators count]; d <= degree; d++) {
      ZXGenericGFPoly * nextGenerator = [lastGenerator multiply:[[[ZXGenericGFPoly alloc] initWithField:field coefficients:[NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:[field exp:d - 1]], nil]] autorelease]];
      [self.cachedGenerators addObject:nextGenerator];
      lastGenerator = nextGenerator;
    }
  }

  return (ZXGenericGFPoly *)[self.cachedGenerators objectAtIndex:degree];
}

- (void)encode:(NSMutableArray *)toEncode ecBytes:(int)ecBytes {
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
  ZXGenericGFPoly * generator = [self buildGenerator:ecBytes];
  NSArray * infoCoefficients = [[[toEncode copy] autorelease] subarrayWithRange:NSMakeRange(0, dataBytes)];
  ZXGenericGFPoly * info = [[[ZXGenericGFPoly alloc] initWithField:field coefficients:infoCoefficients] autorelease];
  info = [info multiplyByMonomial:ecBytes coefficient:1];
  ZXGenericGFPoly * remainder = [[info divide:generator] objectAtIndex:1];
  NSArray * coefficients = [remainder coefficients];
  int numZeroCoefficients = ecBytes - [coefficients count];
  for (int i = 0; i < numZeroCoefficients; i++) {
    [toEncode replaceObjectAtIndex:dataBytes + i withObject:[NSNumber numberWithInt:0]];
  }
  for (int i = 0; i < [coefficients count]; i++) {
    [toEncode replaceObjectAtIndex:dataBytes + numZeroCoefficients + i withObject:[coefficients objectAtIndex:i]];
  }
}

@end
