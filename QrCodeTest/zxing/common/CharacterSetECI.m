#import "CharacterSetECI.h"

NSMutableDictionary * VALUE_TO_ECI;
NSMutableDictionary * NAME_TO_ECI;

@implementation CharacterSetECI

@synthesize encodingName;

+ (void) initialize {
  VALUE_TO_ECI = [[[NSMutableDictionary alloc] init:29] autorelease];
  NAME_TO_ECI = [[[NSMutableDictionary alloc] init:29] autorelease];
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

- (id) init:(int)value encodingName:(NSString *)encodingName {
  if (self = [super init:value]) {
    encodingName = encodingName;
  }
  return self;
}

+ (void) addCharacterSet:(int)value encodingName:(NSString *)encodingName {
  CharacterSetECI * eci = [[[CharacterSetECI alloc] init:value param1:encodingName] autorelease];
  [VALUE_TO_ECI setObject:[[[NSNumber alloc] init:value] autorelease] param1:eci];
  [NAME_TO_ECI setObject:encodingName param1:eci];
}

+ (void) addCharacterSet:(int)value encodingNames:(NSArray *)encodingNames {
  CharacterSetECI * eci = [[[CharacterSetECI alloc] init:value param1:encodingNames[0]] autorelease];
  [VALUE_TO_ECI setObject:[[[NSNumber alloc] init:value] autorelease] param1:eci];

  for (int i = 0; i < encodingNames.length; i++) {
    [NAME_TO_ECI setObject:encodingNames[i] param1:eci];
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
    @throw [[[IllegalArgumentException alloc] init:[@"Bad ECI value: " stringByAppendingString:value]] autorelease];
  }
  return (CharacterSetECI *)[VALUE_TO_ECI objectForKey:[[[NSNumber alloc] init:value] autorelease]];
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
  return (CharacterSetECI *)[NAME_TO_ECI objectForKey:name];
}

- (void) dealloc {
  [encodingName release];
  [super dealloc];
}

@end
