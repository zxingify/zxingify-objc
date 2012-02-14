#import "CharacterSetECI.h"

static NSMutableDictionary * VALUE_TO_ECI = nil;
static NSMutableDictionary * NAME_TO_ECI = nil;

@interface CharacterSetECI ()

+ (void) addCharacterSet:(int)value encodingName:(NSString*)encodingName;
+ (void) addCharacterSet:(int)value encodingNames:(NSArray *)encodingNames;

@end

@implementation CharacterSetECI

@synthesize encoding;

+ (void) initialize {
  VALUE_TO_ECI = [[NSMutableDictionary alloc] initWithCapacity:29];
  NAME_TO_ECI = [[NSMutableDictionary alloc] initWithCapacity:29];
  [self addCharacterSet:0 encodingName:@"Cp437"];
  [self addCharacterSet:1 encodingName:[NSArray arrayWithObjects:@"ISO8859_1", @"ISO-8859-1", nil]];
  [self addCharacterSet:2 encodingName:@"Cp437"];
  [self addCharacterSet:3 encodingName:[NSArray arrayWithObjects:@"ISO8859_1", @"ISO-8859-1", nil]];
  [self addCharacterSet:4 encodingName:@"ISO8859_2"];
  [self addCharacterSet:5 encodingName:@"ISO8859_3"];
  [self addCharacterSet:6 encodingName:@"ISO8859_4"];
  [self addCharacterSet:7 encodingName:@"ISO8859_5"];
  [self addCharacterSet:8 encodingName:@"ISO8859_6"];
  [self addCharacterSet:9 encodingName:@"ISO8859_7"];
  [self addCharacterSet:10 encodingName:@"ISO8859_8"];
  [self addCharacterSet:11 encodingName:@"ISO8859_9"];
  [self addCharacterSet:12 encodingName:@"ISO8859_10"];
  [self addCharacterSet:13 encodingName:@"ISO8859_11"];
  [self addCharacterSet:15 encodingName:@"ISO8859_13"];
  [self addCharacterSet:16 encodingName:@"ISO8859_14"];
  [self addCharacterSet:17 encodingName:@"ISO8859_15"];
  [self addCharacterSet:18 encodingName:@"ISO8859_16"];
  [self addCharacterSet:20 encodingName:[NSArray arrayWithObjects:@"SJIS", @"Shift_JIS", nil]];
}

- (id) initWithValue:(int)value encoding:(NSString *)anEncoding {
  if (self = [super initWithValue:value]) {
    encoding = [anEncoding copy];
  }
  return self;
}

+ (void) addCharacterSet:(int)value encodingName:(NSString *)encoding {
  CharacterSetECI * eci = [[[CharacterSetECI alloc] initWithValue:value encoding:encoding] autorelease];
  [VALUE_TO_ECI setObject:eci forKey:[NSNumber numberWithInt:value]];
  [NAME_TO_ECI setObject:eci forKey:encoding];
}

+ (void) addCharacterSet:(int)value encodingNames:(NSArray *)encodings {
  CharacterSetECI * eci = [[[CharacterSetECI alloc] initWithValue:value encoding:[encodings objectAtIndex:0]] autorelease];
  [VALUE_TO_ECI setObject:eci forKey:[NSNumber numberWithInt:value]];

  for (id name in encodings) {
    [NAME_TO_ECI setObject:eci forKey:name];
  }
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
+ (CharacterSetECI *) getCharacterSetECIByName:(NSString *)name {
  if (NAME_TO_ECI == nil) {
    [self initialize];
  }
  return [NAME_TO_ECI objectForKey:name];
}

- (void)dealloc {
  [encoding release];
  [super dealloc];
}

@end
