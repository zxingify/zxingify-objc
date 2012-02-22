#import "NotFoundException.h"
#import "Result.h"
#import "ResultPoint.h"
#import "UPCEANExtensionSupport.h"
#import "UPCEANReader.h"

const int EXTENSION_START_PATTERN[3] = {1,1,2};
const int CHECK_DIGIT_ENCODINGS[10] = {
  0x18, 0x14, 0x12, 0x11, 0x0C, 0x06, 0x03, 0x0A, 0x09, 0x05
};

@interface UPCEANExtensionSupport ()

- (int) determineCheckDigit:(int)lgPatternFound;
- (int) extensionChecksum:(NSString *)s;
- (NSMutableDictionary *) parseExtensionString:(NSString *)raw;
- (NSNumber *) parseExtension2String:(NSString *)raw;
- (NSString *) parseExtension5String:(NSString *)raw;

@end

@implementation UPCEANExtensionSupport

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row rowOffset:(int)rowOffset {
  NSArray * extensionStartRange = [UPCEANReader findGuardPattern:row rowOffset:rowOffset whiteFirst:NO pattern:(int*)EXTENSION_START_PATTERN];

  NSMutableString * result = [NSMutableString string];
  int end = [self decodeMiddle:row startRange:extensionStartRange result:result];

  NSMutableDictionary * extensionData = [self parseExtensionString:result];

  Result * extensionResult = [[[Result alloc] initWithText:result
                                                  rawBytes:nil
                                                    length:0
                                              resultPoints:[NSArray arrayWithObjects:
                                                            [[[ResultPoint alloc] initWithX:([[extensionStartRange objectAtIndex:0] intValue] + [[extensionStartRange objectAtIndex:1] intValue]) / 2.0f y:(float)rowNumber] autorelease],
                                                            [[[ResultPoint alloc] initWithX:(float)end y:(float)rowNumber] autorelease], nil]
                                                    format:kBarcodeFormatUPCEANExtension] autorelease];
  if (extensionData != nil) {
    [extensionResult putAllMetadata:extensionData];
  }
  return extensionResult;
}

- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange result:(NSMutableString *)result {
  int counters[4] = {0, 0, 0, 0};
  int end = [row size];
  int rowOffset = [[startRange objectAtIndex:1] intValue];

  int lgPatternFound = 0;

  for (int x = 0; x < 5 && rowOffset < end; x++) {
    int bestMatch = [UPCEANReader decodeDigit:row counters:counters rowOffset:rowOffset patterns:(int**)L_AND_G_PATTERNS];
    [result appendFormat:@"%C", (unichar)('0' + bestMatch % 10)];
    for (int i = 0; i < sizeof(counters) / sizeof(int); i++) {
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

  if ([result length] != 5) {
    @throw [NotFoundException notFoundInstance];
  }

  int checkDigit = [self determineCheckDigit:lgPatternFound];
  if ([self extensionChecksum:result] != checkDigit) {
    @throw [NotFoundException notFoundInstance];
  }

  return rowOffset;
}

- (int) extensionChecksum:(NSString *)s {
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

- (int) determineCheckDigit:(int)lgPatternFound {
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
- (NSMutableDictionary *) parseExtensionString:(NSString *)raw {
  ResultMetadataType type;
  id value;

  switch ([raw length]) {
  case 2:
    type = kResultMetadataTypeIssueNumber;
    value = [self parseExtension2String:raw];
    break;
  case 5:
    type = kResultMetadataTypeSuggestedPrice;
    value = [self parseExtension5String:raw];
    break;
  default:
    return nil;
  }
  if (value == nil) {
    return nil;
  }
  NSMutableDictionary * result = [NSMutableDictionary dictionaryWithCapacity:1];
  [result setObject:value forKey:[NSNumber numberWithInt:type]];
  return result;
}

- (NSNumber *) parseExtension2String:(NSString *)raw {
  return [NSNumber numberWithInt:[raw intValue]];
}

- (NSString *) parseExtension5String:(NSString *)raw {
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
    } else if ([@"99991" isEqualToString:raw]) {
      return @"0.00";
    } else if ([@"99990" isEqualToString:raw]) {
      return @"Used";
    }
    currency = @"";
    break;
  default:
    currency = @"";
    break;
  }
  int rawAmount = [[raw substringFromIndex:1] intValue];
  NSString * unitsString = [[NSNumber numberWithInt:rawAmount / 100] stringValue];
  int hundredths = rawAmount % 100;
  NSString * hundredthsString = hundredths < 10 ? 
  [NSString stringWithFormat:@"0%d", hundredths] : [[NSNumber numberWithInt:hundredths] stringValue];
  return [NSString stringWithFormat:@"%@%@.%@", currency, unitsString, hundredthsString];
}

@end
