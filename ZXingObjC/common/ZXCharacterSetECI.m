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
  [self addCharacterSet:0 encoding:(NSStringEncoding) 0x80000400];
  [self addCharacterSet:1 encoding:NSISOLatin1StringEncoding];
  [self addCharacterSet:2 encoding:(NSStringEncoding) 0x80000400];
  [self addCharacterSet:3 encoding:NSISOLatin1StringEncoding];
  [self addCharacterSet:4 encoding:NSISOLatin2StringEncoding];
  [self addCharacterSet:5 encoding:(NSStringEncoding) 0x80000203];
  [self addCharacterSet:6 encoding:(NSStringEncoding) 0x80000204];
  [self addCharacterSet:7 encoding:(NSStringEncoding) 0x80000205];
  [self addCharacterSet:8 encoding:(NSStringEncoding) 0x80000206];
  [self addCharacterSet:9 encoding:(NSStringEncoding) 0x80000207];
  [self addCharacterSet:10 encoding:(NSStringEncoding) 0x80000208];
  [self addCharacterSet:11 encoding:(NSStringEncoding) 0x80000209];
  [self addCharacterSet:12 encoding:(NSStringEncoding) 0x8000020A];
  [self addCharacterSet:13 encoding:(NSStringEncoding) 0x8000020B];
  [self addCharacterSet:15 encoding:(NSStringEncoding) 0x8000020D];
  [self addCharacterSet:16 encoding:(NSStringEncoding) 0x8000020E];
  [self addCharacterSet:17 encoding:(NSStringEncoding) 0x8000020F];
  [self addCharacterSet:18 encoding:(NSStringEncoding) 0x80000210];
  [self addCharacterSet:20 encoding:NSShiftJISStringEncoding];
}

- (id)initWithValue:(int)value encoding:(NSStringEncoding)anEncoding {
  if (self = [super initWithValue:value]) {
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
