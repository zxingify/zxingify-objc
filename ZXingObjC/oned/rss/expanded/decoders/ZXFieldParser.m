/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXErrors.h"
#import "ZXFieldParser.h"

static NSObject *VARIABLE_LENGTH = nil;
static NSArray *TWO_DIGIT_DATA_LENGTH = nil;
static NSArray *THREE_DIGIT_DATA_LENGTH = nil;
static NSArray *THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH = nil;
static NSArray *FOUR_DIGIT_DATA_LENGTH = nil;

@interface ZXFieldParser ()

+ (NSString *)processFixedAI:(int)aiSize fieldSize:(int)fieldSize rawInformation:(NSString *)rawInformation;
+ (NSString *)processVariableAI:(int)aiSize variableFieldSize:(int)variableFieldSize rawInformation:(NSString *)rawInformation;

@end

@implementation ZXFieldParser

+ (void)initialize {
  if (VARIABLE_LENGTH == nil) {
    VARIABLE_LENGTH = [[NSObject alloc] init];
  }

  if (TWO_DIGIT_DATA_LENGTH == nil) {
    TWO_DIGIT_DATA_LENGTH = [[NSArray alloc] initWithObjects:
                             [NSArray arrayWithObjects:@"00", [NSNumber numberWithInt:18], nil],
                             [NSArray arrayWithObjects:@"01", [NSNumber numberWithInt:14], nil],
                             [NSArray arrayWithObjects:@"02", [NSNumber numberWithInt:14], nil],
                             
                             [NSArray arrayWithObjects:@"10", VARIABLE_LENGTH, [NSNumber numberWithInt:20], nil],
                             [NSArray arrayWithObjects:@"11", [NSNumber numberWithInt:6], nil],
                             [NSArray arrayWithObjects:@"12", [NSNumber numberWithInt:6], nil],
                             [NSArray arrayWithObjects:@"13", [NSNumber numberWithInt:6], nil],
                             [NSArray arrayWithObjects:@"15", [NSNumber numberWithInt:6], nil],
                             [NSArray arrayWithObjects:@"17", [NSNumber numberWithInt:6], nil],
                             
                             [NSArray arrayWithObjects:@"20", [NSNumber numberWithInt:2], nil],
                             [NSArray arrayWithObjects:@"21", VARIABLE_LENGTH, [NSNumber numberWithInt:20], nil],
                             [NSArray arrayWithObjects:@"22", VARIABLE_LENGTH, [NSNumber numberWithInt:29], nil],
                             
                             [NSArray arrayWithObjects:@"30", VARIABLE_LENGTH, [NSNumber numberWithInt: 8], nil],
                             [NSArray arrayWithObjects:@"37", VARIABLE_LENGTH, [NSNumber numberWithInt: 8], nil],

                             //internal company codes
                             [NSArray arrayWithObjects:@"90", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                             [NSArray arrayWithObjects:@"91", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                             [NSArray arrayWithObjects:@"92", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                             [NSArray arrayWithObjects:@"93", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                             [NSArray arrayWithObjects:@"94", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                             [NSArray arrayWithObjects:@"95", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                             [NSArray arrayWithObjects:@"96", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                             [NSArray arrayWithObjects:@"97", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                             [NSArray arrayWithObjects:@"98", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                             [NSArray arrayWithObjects:@"99", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                             nil];
  }

  if (THREE_DIGIT_DATA_LENGTH == nil) {
    THREE_DIGIT_DATA_LENGTH = [[NSArray alloc] initWithObjects:
                               [NSArray arrayWithObjects:@"240", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                               [NSArray arrayWithObjects:@"241", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                               [NSArray arrayWithObjects:@"242", VARIABLE_LENGTH, [NSNumber numberWithInt: 6], nil],
                               [NSArray arrayWithObjects:@"250", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                               [NSArray arrayWithObjects:@"251", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                               [NSArray arrayWithObjects:@"253", VARIABLE_LENGTH, [NSNumber numberWithInt:17], nil],
                               [NSArray arrayWithObjects:@"254", VARIABLE_LENGTH, [NSNumber numberWithInt:20], nil],
                               
                               [NSArray arrayWithObjects:@"400", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                               [NSArray arrayWithObjects:@"401", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                               [NSArray arrayWithObjects:@"402", [NSNumber numberWithInt:17], nil],
                               [NSArray arrayWithObjects:@"403", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                               [NSArray arrayWithObjects:@"410", [NSNumber numberWithInt:13], nil],
                               [NSArray arrayWithObjects:@"411", [NSNumber numberWithInt:13], nil],
                               [NSArray arrayWithObjects:@"412", [NSNumber numberWithInt:13], nil],
                               [NSArray arrayWithObjects:@"413", [NSNumber numberWithInt:13], nil],
                               [NSArray arrayWithObjects:@"414", [NSNumber numberWithInt:13], nil],
                               [NSArray arrayWithObjects:@"420", VARIABLE_LENGTH, [NSNumber numberWithInt:20], nil],
                               [NSArray arrayWithObjects:@"421", VARIABLE_LENGTH, [NSNumber numberWithInt:15], nil],
                               [NSArray arrayWithObjects:@"422", [NSNumber numberWithInt:3], nil],
                               [NSArray arrayWithObjects:@"423", VARIABLE_LENGTH, [NSNumber numberWithInt:15], nil],
                               [NSArray arrayWithObjects:@"424", [NSNumber numberWithInt:3], nil],
                               [NSArray arrayWithObjects:@"425", [NSNumber numberWithInt:3], nil],
                               [NSArray arrayWithObjects:@"426", [NSNumber numberWithInt:3], nil],
                               nil];

  }

  if (THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH == nil) {
    THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH = [[NSArray alloc] initWithObjects:
                                          [NSArray arrayWithObjects:@"310", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"311", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"312", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"313", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"314", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"315", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"316", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"320", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"321", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"322", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"323", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"324", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"325", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"326", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"327", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"328", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"329", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"330", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"331", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"332", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"333", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"334", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"335", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"336", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"340", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"341", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"342", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"343", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"344", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"345", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"346", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"347", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"348", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"349", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"350", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"351", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"352", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"353", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"354", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"355", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"356", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"357", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"360", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"361", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"362", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"363", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"364", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"365", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"366", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"367", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"368", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"369", [NSNumber numberWithInt:6], nil],
                                          [NSArray arrayWithObjects:@"390", VARIABLE_LENGTH, [NSNumber numberWithInt:15], nil],
                                          [NSArray arrayWithObjects:@"391", VARIABLE_LENGTH, [NSNumber numberWithInt:18], nil],
                                          [NSArray arrayWithObjects:@"392", VARIABLE_LENGTH, [NSNumber numberWithInt:15], nil],
                                          [NSArray arrayWithObjects:@"393", VARIABLE_LENGTH, [NSNumber numberWithInt:18], nil],
                                          [NSArray arrayWithObjects:@"703", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                                          nil];
  }

  if (FOUR_DIGIT_DATA_LENGTH == nil) {
    FOUR_DIGIT_DATA_LENGTH = [[NSArray alloc] initWithObjects:
                              [NSArray arrayWithObjects:@"7001", [NSNumber numberWithInt:13], nil],
                              [NSArray arrayWithObjects:@"7002", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                              [NSArray arrayWithObjects:@"7003", [NSNumber numberWithInt:10], nil],
                              
                              [NSArray arrayWithObjects:@"8001", [NSNumber numberWithInt:14], nil],
                              [NSArray arrayWithObjects:@"8002", VARIABLE_LENGTH, [NSNumber numberWithInt:20], nil],
                              [NSArray arrayWithObjects:@"8003", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                              [NSArray arrayWithObjects:@"8004", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                              [NSArray arrayWithObjects:@"8005", [NSNumber numberWithInt:6], nil],
                              [NSArray arrayWithObjects:@"8006", [NSNumber numberWithInt:18], nil],
                              [NSArray arrayWithObjects:@"8007", VARIABLE_LENGTH, [NSNumber numberWithInt:30], nil],
                              [NSArray arrayWithObjects:@"8008", VARIABLE_LENGTH, [NSNumber numberWithInt:12], nil],
                              [NSArray arrayWithObjects:@"8018", [NSNumber numberWithInt:18], nil],
                              [NSArray arrayWithObjects:@"8020", VARIABLE_LENGTH, [NSNumber numberWithInt:25], nil],
                              [NSArray arrayWithObjects:@"8100", [NSNumber numberWithInt:6], nil],
                              [NSArray arrayWithObjects:@"8101", [NSNumber numberWithInt:10], nil],
                              [NSArray arrayWithObjects:@"8102", [NSNumber numberWithInt:2], nil],
                              [NSArray arrayWithObjects:@"8110", VARIABLE_LENGTH, [NSNumber numberWithInt:70], nil],
                              [NSArray arrayWithObjects:@"8200", VARIABLE_LENGTH, [NSNumber numberWithInt:70], nil],
                              nil];
  }
}

+ (NSString *)parseFieldsInGeneralPurpose:(NSString *)rawInformation error:(NSError **)error {
  if ([rawInformation length] == 0) {
    return @"";
  }
  if ([rawInformation length] < 2) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }
  NSString *firstTwoDigits = [rawInformation substringWithRange:NSMakeRange(0, 2)];

  for (int i = 0; i < [TWO_DIGIT_DATA_LENGTH count]; ++i) {
    if ([[[TWO_DIGIT_DATA_LENGTH objectAtIndex:i] objectAtIndex:0] isEqualToString:firstTwoDigits]) {
      if ([[[TWO_DIGIT_DATA_LENGTH objectAtIndex:i] objectAtIndex:1] isEqual:VARIABLE_LENGTH]) {
        return [self processVariableAI:2
                     variableFieldSize:[[[TWO_DIGIT_DATA_LENGTH objectAtIndex:i] objectAtIndex:2] intValue]
                        rawInformation:rawInformation];
      }
      NSString *result = [self processFixedAI:2
                                    fieldSize:[[[TWO_DIGIT_DATA_LENGTH objectAtIndex:i] objectAtIndex:1] intValue]
                               rawInformation:rawInformation];
      if (!result) {
        if (error) *error = NotFoundErrorInstance();
        return nil;
      }
      return result;
    }
  }

  if ([rawInformation length] < 3) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }
  NSString *firstThreeDigits = [rawInformation substringWithRange:NSMakeRange(0, 3)];

  for (int i = 0; i < [THREE_DIGIT_DATA_LENGTH count]; ++i) {
    if ([[[THREE_DIGIT_DATA_LENGTH objectAtIndex:i] objectAtIndex:0] isEqualToString:firstThreeDigits]) {
      if ([[[THREE_DIGIT_DATA_LENGTH objectAtIndex:i] objectAtIndex:1] isEqual:VARIABLE_LENGTH]) {
        return [self processVariableAI:3
                     variableFieldSize:[[[THREE_DIGIT_DATA_LENGTH objectAtIndex:i] objectAtIndex:2] intValue]
                        rawInformation:rawInformation];
      }
      NSString *result = [self processFixedAI:3
                                    fieldSize:[[[THREE_DIGIT_DATA_LENGTH objectAtIndex:i] objectAtIndex:1] intValue]
                               rawInformation:rawInformation];
      if (!result) {
        if (error) *error = NotFoundErrorInstance();
        return nil;
      }
      return result;
    }
  }

  for (int i = 0; i < [THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH count]; ++i) {
    if ([[[THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH objectAtIndex:i] objectAtIndex:0] isEqualToString:firstThreeDigits]) {
      if ([[[THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH objectAtIndex:i] objectAtIndex:1] isEqual:VARIABLE_LENGTH]) {
        return [self processVariableAI:4
                     variableFieldSize:[[[THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH objectAtIndex:i] objectAtIndex:2] intValue]
                        rawInformation:rawInformation];
      }
      NSString *result = [self processFixedAI:4
                                    fieldSize:[[[THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH objectAtIndex:i] objectAtIndex:1] intValue]
                               rawInformation:rawInformation];
      if (!result) {
        if (error) *error = NotFoundErrorInstance();
        return nil;
      }
      return result;
    }
  }

  if ([rawInformation length] < 4) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }
  NSString *firstFourDigits = [rawInformation substringWithRange:NSMakeRange(0, 4)];

  for (int i = 0; i < [FOUR_DIGIT_DATA_LENGTH count]; ++i) {
    if ([[[FOUR_DIGIT_DATA_LENGTH objectAtIndex:i] objectAtIndex:0] isEqualToString:firstFourDigits]) {
      if ([[[FOUR_DIGIT_DATA_LENGTH objectAtIndex:i] objectAtIndex:1] isEqual:VARIABLE_LENGTH]) {
        NSString *result = [self processVariableAI:4
                                 variableFieldSize:[[[FOUR_DIGIT_DATA_LENGTH objectAtIndex:i] objectAtIndex:2] intValue]
                                    rawInformation:rawInformation];
        if (!result) {
          if (error) *error = NotFoundErrorInstance();
          return nil;
        }
        return result;
      }
      NSString *result = [self processFixedAI:4
                                    fieldSize:[[[FOUR_DIGIT_DATA_LENGTH objectAtIndex:i] objectAtIndex:1] intValue]
                               rawInformation:rawInformation];
      if (!result) {
        if (error) *error = NotFoundErrorInstance();
        return nil;
      }
      return result;
    }
  }

  if (error) *error = NotFoundErrorInstance();
  return nil;
}

+ (NSString *)processFixedAI:(int)aiSize fieldSize:(int)fieldSize rawInformation:(NSString *)rawInformation {
  if ([rawInformation length] < aiSize) {
    return nil;
  }

  NSString *ai = [rawInformation substringWithRange:NSMakeRange(0, aiSize)];
  if ([rawInformation length] < aiSize + fieldSize) {
    return nil;
  }

  NSString *field = [rawInformation substringWithRange:NSMakeRange(aiSize, fieldSize)];
  NSString *remaining;
  if (aiSize + fieldSize == rawInformation.length) {
    remaining = @"";
  } else {
    remaining = [rawInformation substringFromIndex:aiSize + fieldSize];
  }

  NSString *result = [NSString stringWithFormat:@"(%@)%@", ai, field];
  NSString *parsedAI = [self parseFieldsInGeneralPurpose:remaining error:nil];
  return parsedAI == nil ? result : [result stringByAppendingString:parsedAI];
}

+ (NSString *)processVariableAI:(int)aiSize variableFieldSize:(int)variableFieldSize rawInformation:(NSString *)rawInformation {
  NSString *ai = [rawInformation substringWithRange:NSMakeRange(0, aiSize)];
  int maxSize;
  if ([rawInformation length] < aiSize + variableFieldSize) {
    maxSize = [rawInformation length];
  } else {
    maxSize = aiSize + variableFieldSize;
  }
  NSString *field = [rawInformation substringWithRange:NSMakeRange(aiSize, maxSize - aiSize)];
  NSString *remaining = [rawInformation substringFromIndex:maxSize];
  NSString *result = [NSString stringWithFormat:@"(%@)%@", ai, field];
  NSString *parsedAI = [self parseFieldsInGeneralPurpose:remaining error:nil];
  return parsedAI == nil ? result : [result stringByAppendingString:parsedAI];
}

@end
