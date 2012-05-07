#import "ZXCharacterSetECI.h"

static NSMutableDictionary * VALUE_TO_ECI = nil;
static NSMutableDictionary * ENCODING_TO_ECI = nil;

@interface ZXCharacterSetECI ()

@property (nonatomic) NSStringEncoding encoding;

+ (void)addCharacterSet:(int)value encoding:(NSStringEncoding)encoding;

@end

@implementation ZXCharacterSetECI

@synthesize encoding;

+ (void)initialize {
  VALUE_TO_ECI = [[NSMutableDictionary alloc] initWithCapacity:29];
  ENCODING_TO_ECI = [[NSMutableDictionary alloc] initWithCapacity:29];
  [self addCharacterSet:1 encoding:NSISOLatin1StringEncoding];
  [self addCharacterSet:3 encoding:NSISOLatin1StringEncoding];
  [self addCharacterSet:4 encoding:NSISOLatin2StringEncoding];
  [self addCharacterSet:5 encoding:(NSStringEncoding) 0x80000203];
  [self addCharacterSet:6 encoding:(NSStringEncoding) 0x80000204];
  [self addCharacterSet:7 encoding:(NSStringEncoding) 0x80000205];
  [self addCharacterSet:10 encoding:(NSStringEncoding) 0x80000208];
  [self addCharacterSet:12 encoding:(NSStringEncoding) 0x80000205];
  [self addCharacterSet:15 encoding:(NSStringEncoding) 0x8000020D];
  [self addCharacterSet:17 encoding:(NSStringEncoding) 0x8000020F];
  [self addCharacterSet:20 encoding:NSShiftJISStringEncoding];
  [self addCharacterSet:21 encoding:NSWindowsCP1250StringEncoding];
  [self addCharacterSet:22 encoding:NSWindowsCP1251StringEncoding];
  [self addCharacterSet:23 encoding:NSWindowsCP1252StringEncoding];
}

- (id)initWithValue:(int)value encoding:(NSStringEncoding)anEncoding {
  self = [super initWithValue:value];
  if (self) {
    self.encoding = anEncoding;
  }

  return self;
}

+ (void)addCharacterSet:(int)value encoding:(NSStringEncoding)encoding {
  ZXCharacterSetECI * eci = [[[ZXCharacterSetECI alloc] initWithValue:value encoding:encoding] autorelease];
  [VALUE_TO_ECI setObject:eci forKey:[NSNumber numberWithInt:value]];
  [ENCODING_TO_ECI setObject:eci forKey:[NSNumber numberWithUnsignedInteger:encoding]];
}

+ (ZXCharacterSetECI *)characterSetECIByValue:(int)value {
  if (VALUE_TO_ECI == nil) {
    [self initialize];
  }
  if (value < 0 || value >= 900) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"Bad ECI value: %d", value]
                                 userInfo:nil];
  }
  return [VALUE_TO_ECI objectForKey:[NSNumber numberWithInt:value]];
}


+ (ZXCharacterSetECI *)characterSetECIByEncoding:(NSStringEncoding)encoding {
  if (ENCODING_TO_ECI == nil) {
    [self initialize];
  }
  return [ENCODING_TO_ECI objectForKey:[NSNumber numberWithUnsignedInteger:encoding]];
}

@end
