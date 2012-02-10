#import "UPCEANExtensionSupport.h"

NSArray * const EXTENSION_START_PATTERN = [NSArray arrayWithObjects:1, 1, 2, nil];
NSArray * const CHECK_DIGIT_ENCODINGS = [NSArray arrayWithObjects:0x18, 0x14, 0x12, 0x11, 0x0C, 0x06, 0x03, 0x0A, 0x09, 0x05, nil];

@implementation UPCEANExtensionSupport

- (void) init {
  if (self = [super init]) {
    decodeMiddleCounters = [NSArray array];
    decodeRowNSMutableString = [[[NSMutableString alloc] init] autorelease];
  }
  return self;
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row rowOffset:(int)rowOffset {
  NSArray * extensionStartRange = [UPCEANReader findGuardPattern:row param1:rowOffset param2:NO param3:EXTENSION_START_PATTERN];
  NSMutableString * result = decodeRowNSMutableString;
  [result setLength:0];
  int end = [self decodeMiddle:row startRange:extensionStartRange resultString:result];
  NSString * resultString = [result description];
  NSMutableDictionary * extensionData = [self parseExtensionString:resultString];
  Result * extensionResult = [[[Result alloc] init:resultString param1:nil param2:[NSArray arrayWithObjects:[[[ResultPoint alloc] init:(extensionStartRange[0] + extensionStartRange[1]) / 2.0f param1:(float)rowNumber] autorelease], [[[ResultPoint alloc] init:(float)end param1:(float)rowNumber] autorelease], nil] param3:BarcodeFormat.UPC_EAN_EXTENSION] autorelease];
  if (extensionData != nil) {
    [extensionResult putAllMetadata:extensionData];
  }
  return extensionResult;
}

- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange resultString:(NSMutableString *)resultString {
  NSArray * counters = decodeMiddleCounters;
  counters[0] = 0;
  counters[1] = 0;
  counters[2] = 0;
  counters[3] = 0;
  int end = [row size];
  int rowOffset = startRange[1];
  int lgPatternFound = 0;

  for (int x = 0; x < 5 && rowOffset < end; x++) {
    int bestMatch = [UPCEANReader decodeDigit:row param1:counters param2:rowOffset param3:UPCEANReader.L_AND_G_PATTERNS];
    [resultString append:(unichar)('0' + bestMatch % 10)];

    for (int i = 0; i < counters.length; i++) {
      rowOffset += counters[i];
    }

    if (bestMatch >= 10) {
      lgPatternFound |= 1 << (4 - x);
    }
    if (x != 4) {

      while (rowOffset < end && ![row get:rowOffset]) {
        rowOffset++;
      }


      while (rowOffset < end && [row get:rowOffset]) {
        rowOffset++;
      }

    }
  }

  if ([resultString length] != 5) {
    @throw [NotFoundException notFoundInstance];
  }
  int checkDigit = [self determineCheckDigit:lgPatternFound];
  if ([self extensionChecksum:[resultString description]] != checkDigit) {
    @throw [NotFoundException notFoundInstance];
  }
  return rowOffset;
}

+ (int) extensionChecksum:(NSString *)s {
  int length = [s length];
  int sum = 0;

  for (int i = length - 2; i >= 0; i -= 2) {
    sum += (int)[s characterAtIndex:i] - (int)'0';
  }

  sum *= 3;

  for (int i = length - 1; i >= 0; i -= 2) {
    sum += (int)[s characterAtIndex:i] - (int)'0';
  }

  sum *= 3;
  return sum % 10;
}

+ (int) determineCheckDigit:(int)lgPatternFound {

  for (int d = 0; d < 10; d++) {
    if (lgPatternFound == CHECK_DIGIT_ENCODINGS[d]) {
      return d;
    }
  }

  @throw [NotFoundException notFoundInstance];
}


/**
 * @param raw raw content of extension
 * @return formatted interpretation of raw content as a {@link Hashtable} mapping
 * one {@link ResultMetadataType} to appropriate value, or <code>null</code> if not known
 */
+ (NSMutableDictionary *) parseExtensionString:(NSString *)raw {
  ResultMetadataType * type;
  NSObject * value;

  switch ([raw length]) {
  case 2:
    type = ResultMetadataType.ISSUE_NUMBER;
    value = [self parseExtension2String:raw];
    break;
  case 5:
    type = ResultMetadataType.SUGGESTED_PRICE;
    value = [self parseExtension5String:raw];
    break;
  default:
    return nil;
  }
  if (value == nil) {
    return nil;
  }
  NSMutableDictionary * result = [[[NSMutableDictionary alloc] init:1] autorelease];
  [result setObject:type param1:value];
  return result;
}

+ (NSNumber *) parseExtension2String:(NSString *)raw {
  return [Integer valueOf:raw];
}

+ (NSString *) parseExtension5String:(NSString *)raw {
  NSString * currency;

  switch ([raw characterAtIndex:0]) {
  case '0':
    currency = @"£";
    break;
  case '5':
    currency = @"$";
    break;
  case '9':
    if ([@"90000" isEqualToString:raw]) {
      return nil;
    }
     else if ([@"99991" isEqualToString:raw]) {
      return @"0.00";
    }
     else if ([@"99990" isEqualToString:raw]) {
      return @"Used";
    }
    currency = @"";
    break;
  default:
    currency = @"";
    break;
  }
  int rawAmount = [Integer parseInt:[raw substringFromIndex:1]];
  NSString * unitsString = [String valueOf:rawAmount / 100];
  int hundredths = rawAmount % 100;
  NSString * hundredthsString = hundredths < 10 ? [@"0" stringByAppendingString:hundredths] : [String valueOf:hundredths];
  return [[currency stringByAppendingString:unitsString] + '.' stringByAppendingString:hundredthsString];
}

- (void) dealloc {
  [decodeMiddleCounters release];
  [decodeRowNSMutableString release];
  [super dealloc];
}

@end
