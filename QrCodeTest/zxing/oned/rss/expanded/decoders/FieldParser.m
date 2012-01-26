#import "FieldParser.h"

NSObject * const VARIABLE_LENGTH = [[[NSObject alloc] init] autorelease];
NSArray * const TWO_DIGIT_DATA_LENGTH = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"00", [[[NSNumber alloc] init:18] autorelease], nil], [NSArray arrayWithObjects:@"01", [[[NSNumber alloc] init:14] autorelease], nil], [NSArray arrayWithObjects:@"02", [[[NSNumber alloc] init:14] autorelease], nil], [NSArray arrayWithObjects:@"10", VARIABLE_LENGTH, [[[NSNumber alloc] init:20] autorelease], nil], [NSArray arrayWithObjects:@"11", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"12", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"13", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"15", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"17", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"20", [[[NSNumber alloc] init:2] autorelease], nil], [NSArray arrayWithObjects:@"21", VARIABLE_LENGTH, [[[NSNumber alloc] init:20] autorelease], nil], [NSArray arrayWithObjects:@"22", VARIABLE_LENGTH, [[[NSNumber alloc] init:29] autorelease], nil], [NSArray arrayWithObjects:@"30", VARIABLE_LENGTH, [[[NSNumber alloc] init:8] autorelease], nil], [NSArray arrayWithObjects:@"37", VARIABLE_LENGTH, [[[NSNumber alloc] init:8] autorelease], nil], [NSArray arrayWithObjects:@"90", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"91", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"92", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"93", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"94", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"95", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"96", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"97", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"98", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"99", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], nil];
NSArray * const THREE_DIGIT_DATA_LENGTH = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"240", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"241", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"242", VARIABLE_LENGTH, [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"250", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"251", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"253", VARIABLE_LENGTH, [[[NSNumber alloc] init:17] autorelease], nil], [NSArray arrayWithObjects:@"254", VARIABLE_LENGTH, [[[NSNumber alloc] init:20] autorelease], nil], [NSArray arrayWithObjects:@"400", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"401", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"402", [[[NSNumber alloc] init:17] autorelease], nil], [NSArray arrayWithObjects:@"403", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"410", [[[NSNumber alloc] init:13] autorelease], nil], [NSArray arrayWithObjects:@"411", [[[NSNumber alloc] init:13] autorelease], nil], [NSArray arrayWithObjects:@"412", [[[NSNumber alloc] init:13] autorelease], nil], [NSArray arrayWithObjects:@"413", [[[NSNumber alloc] init:13] autorelease], nil], [NSArray arrayWithObjects:@"414", [[[NSNumber alloc] init:13] autorelease], nil], [NSArray arrayWithObjects:@"420", VARIABLE_LENGTH, [[[NSNumber alloc] init:20] autorelease], nil], [NSArray arrayWithObjects:@"421", VARIABLE_LENGTH, [[[NSNumber alloc] init:15] autorelease], nil], [NSArray arrayWithObjects:@"422", [[[NSNumber alloc] init:3] autorelease], nil], [NSArray arrayWithObjects:@"423", VARIABLE_LENGTH, [[[NSNumber alloc] init:15] autorelease], nil], [NSArray arrayWithObjects:@"424", [[[NSNumber alloc] init:3] autorelease], nil], [NSArray arrayWithObjects:@"425", [[[NSNumber alloc] init:3] autorelease], nil], [NSArray arrayWithObjects:@"426", [[[NSNumber alloc] init:3] autorelease], nil], nil];
NSArray * const THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"310", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"311", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"312", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"313", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"314", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"315", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"316", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"320", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"321", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"322", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"323", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"324", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"325", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"326", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"327", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"328", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"329", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"330", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"331", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"332", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"333", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"334", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"335", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"336", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"340", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"341", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"342", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"343", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"344", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"345", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"346", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"347", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"348", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"349", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"350", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"351", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"352", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"353", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"354", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"355", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"356", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"357", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"360", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"361", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"362", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"363", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"364", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"365", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"366", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"367", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"368", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"369", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"390", VARIABLE_LENGTH, [[[NSNumber alloc] init:15] autorelease], nil], [NSArray arrayWithObjects:@"391", VARIABLE_LENGTH, [[[NSNumber alloc] init:18] autorelease], nil], [NSArray arrayWithObjects:@"392", VARIABLE_LENGTH, [[[NSNumber alloc] init:15] autorelease], nil], [NSArray arrayWithObjects:@"393", VARIABLE_LENGTH, [[[NSNumber alloc] init:18] autorelease], nil], [NSArray arrayWithObjects:@"703", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], nil];
NSArray * const FOUR_DIGIT_DATA_LENGTH = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"7001", [[[NSNumber alloc] init:13] autorelease], nil], [NSArray arrayWithObjects:@"7002", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"7003", [[[NSNumber alloc] init:10] autorelease], nil], [NSArray arrayWithObjects:@"8001", [[[NSNumber alloc] init:14] autorelease], nil], [NSArray arrayWithObjects:@"8002", VARIABLE_LENGTH, [[[NSNumber alloc] init:20] autorelease], nil], [NSArray arrayWithObjects:@"8003", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"8004", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"8005", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"8006", [[[NSNumber alloc] init:18] autorelease], nil], [NSArray arrayWithObjects:@"8007", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], [NSArray arrayWithObjects:@"8008", VARIABLE_LENGTH, [[[NSNumber alloc] init:12] autorelease], nil], [NSArray arrayWithObjects:@"8018", [[[NSNumber alloc] init:18] autorelease], nil], [NSArray arrayWithObjects:@"8020", VARIABLE_LENGTH, [[[NSNumber alloc] init:25] autorelease], nil], [NSArray arrayWithObjects:@"8100", [[[NSNumber alloc] init:6] autorelease], nil], [NSArray arrayWithObjects:@"8101", [[[NSNumber alloc] init:10] autorelease], nil], [NSArray arrayWithObjects:@"8102", [[[NSNumber alloc] init:2] autorelease], nil], [NSArray arrayWithObjects:@"8110", VARIABLE_LENGTH, [[[NSNumber alloc] init:30] autorelease], nil], nil];

@implementation FieldParser

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

+ (NSString *) parseFieldsInGeneralPurpose:(NSString *)rawInformation {
  if ([rawInformation length] == 0) {
    return @"";
  }
  if ([rawInformation length] < 2) {
    @throw [NotFoundException notFoundInstance];
  }
  NSString * firstTwoDigits = [rawInformation substringFromIndex:0 param1:2];

  for (int i = 0; i < TWO_DIGIT_DATA_LENGTH.length; ++i) {
    if ([TWO_DIGIT_DATA_LENGTH[i][0] isEqualTo:firstTwoDigits]) {
      if (TWO_DIGIT_DATA_LENGTH[i][1] == VARIABLE_LENGTH) {
        return [self processVariableAI:2 variableFieldSize:[((NSNumber *)TWO_DIGIT_DATA_LENGTH[i][2]) intValue] rawInformation:rawInformation];
      }
      return [self processFixedAI:2 fieldSize:[((NSNumber *)TWO_DIGIT_DATA_LENGTH[i][1]) intValue] rawInformation:rawInformation];
    }
  }

  if ([rawInformation length] < 3) {
    @throw [NotFoundException notFoundInstance];
  }
  NSString * firstThreeDigits = [rawInformation substringFromIndex:0 param1:3];

  for (int i = 0; i < THREE_DIGIT_DATA_LENGTH.length; ++i) {
    if ([THREE_DIGIT_DATA_LENGTH[i][0] isEqualTo:firstThreeDigits]) {
      if (THREE_DIGIT_DATA_LENGTH[i][1] == VARIABLE_LENGTH) {
        return [self processVariableAI:3 variableFieldSize:[((NSNumber *)THREE_DIGIT_DATA_LENGTH[i][2]) intValue] rawInformation:rawInformation];
      }
      return [self processFixedAI:3 fieldSize:[((NSNumber *)THREE_DIGIT_DATA_LENGTH[i][1]) intValue] rawInformation:rawInformation];
    }
  }


  for (int i = 0; i < THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH.length; ++i) {
    if ([THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH[i][0] isEqualTo:firstThreeDigits]) {
      if (THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH[i][1] == VARIABLE_LENGTH) {
        return [self processVariableAI:4 variableFieldSize:[((NSNumber *)THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH[i][2]) intValue] rawInformation:rawInformation];
      }
      return [self processFixedAI:4 fieldSize:[((NSNumber *)THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH[i][1]) intValue] rawInformation:rawInformation];
    }
  }

  if ([rawInformation length] < 4) {
    @throw [NotFoundException notFoundInstance];
  }
  NSString * firstFourDigits = [rawInformation substringFromIndex:0 param1:4];

  for (int i = 0; i < FOUR_DIGIT_DATA_LENGTH.length; ++i) {
    if ([FOUR_DIGIT_DATA_LENGTH[i][0] isEqualTo:firstFourDigits]) {
      if (FOUR_DIGIT_DATA_LENGTH[i][1] == VARIABLE_LENGTH) {
        return [self processVariableAI:4 variableFieldSize:[((NSNumber *)FOUR_DIGIT_DATA_LENGTH[i][2]) intValue] rawInformation:rawInformation];
      }
      return [self processFixedAI:4 fieldSize:[((NSNumber *)FOUR_DIGIT_DATA_LENGTH[i][1]) intValue] rawInformation:rawInformation];
    }
  }

  @throw [NotFoundException notFoundInstance];
}

+ (NSString *) processFixedAI:(int)aiSize fieldSize:(int)fieldSize rawInformation:(NSString *)rawInformation {
  if ([rawInformation length] < aiSize) {
    @throw [NotFoundException notFoundInstance];
  }
  NSString * ai = [rawInformation substringFromIndex:0 param1:aiSize];
  if ([rawInformation length] < aiSize + fieldSize) {
    @throw [NotFoundException notFoundInstance];
  }
  NSString * field = [rawInformation substringFromIndex:aiSize param1:aiSize + fieldSize];
  NSString * remaining = [rawInformation substringFromIndex:aiSize + fieldSize];
  return [['(' stringByAppendingString:ai] + ')' stringByAppendingString:field] + [self parseFieldsInGeneralPurpose:remaining];
}

+ (NSString *) processVariableAI:(int)aiSize variableFieldSize:(int)variableFieldSize rawInformation:(NSString *)rawInformation {
  NSString * ai = [rawInformation substringFromIndex:0 param1:aiSize];
  int maxSize;
  if ([rawInformation length] < aiSize + variableFieldSize) {
    maxSize = [rawInformation length];
  }
   else {
    maxSize = aiSize + variableFieldSize;
  }
  NSString * field = [rawInformation substringFromIndex:aiSize param1:maxSize];
  NSString * remaining = [rawInformation substringFromIndex:maxSize];
  return [['(' stringByAppendingString:ai] + ')' stringByAppendingString:field] + [self parseFieldsInGeneralPurpose:remaining];
}

@end
