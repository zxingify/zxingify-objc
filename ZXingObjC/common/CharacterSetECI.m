#import "CharacterSetECI.h"

static NSMutableDictionary * VALUE_TO_ECI = nil;
static NSMutableDictionary * ENCODING_TO_ECI = nil;

@interface CharacterSetECI ()

+ (void) addCharacterSet:(int)value encoding:(NSStringEncoding)encoding;

@end

@implementation CharacterSetECI

@synthesize encoding;

+ (void) initialize {
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

- (id) initWithValue:(int)value encoding:(NSStringEncoding)anEncoding {
  if (self = [super initWithValue:value]) {
    encoding = anEncoding;
  }
  return self;
}

+ (void) addCharacterSet:(int)value encoding:(NSStringEncoding)encoding {
  CharacterSetECI * eci = [[[CharacterSetECI alloc] initWithValue:value encoding:encoding] autorelease];
  [VALUE_TO_ECI setObject:eci forKey:[NSNumber numberWithInt:value]];
  [ENCODING_TO_ECI setObject:eci forKey:[NSNumber numberWithUnsignedInteger:encoding]];
}

/**
 * @param value character set ECI value
 * @return CharacterSetECI representing ECI of given value, or null if it is legal but
 * unsupported
 * @throws IllegalArgumentException if ECI value is invalid
 */
+ (CharacterSetECI *) getCharacterSetECIByValue:(int)value {
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


/**
 * @param name character set ECI encoding name
 * @return CharacterSetECI representing ECI for character encoding, or null if it is legal
 * but unsupported
 */
+ (CharacterSetECI *) getCharacterSetECIByEncoding:(NSStringEncoding)encoding {
  if (ENCODING_TO_ECI == nil) {
    [self initialize];
  }
  return [ENCODING_TO_ECI objectForKey:[NSNumber numberWithUnsignedInteger:encoding]];
}

@end
