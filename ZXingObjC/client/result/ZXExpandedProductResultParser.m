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

#import "ZXExpandedProductResultParser.h"
#import "ZXExpandedProductParsedResult.h"
#import "ZXResult.h"

@interface ZXExpandedProductResultParser ()

+ (NSString *)findAIvalue:(int)i rawText:(NSString *)rawText;
+ (NSString *)findValue:(int)i rawText:(NSString *)rawText;

@end

@implementation ZXExpandedProductResultParser

+ (ZXExpandedProductParsedResult *)parse:(ZXResult *)result {
  ZXBarcodeFormat format = [result barcodeFormat];
  if (kBarcodeFormatRSSExpanded != format) {
    return nil;
  }
  NSString * rawText = [result text];
  if (rawText == nil) {
    return nil;
  }

  NSString * productID = @"-";
  NSString * sscc = @"-";
  NSString * lotNumber = @"-";
  NSString * productionDate = @"-";
  NSString * packagingDate = @"-";
  NSString * bestBeforeDate = @"-";
  NSString * expirationDate = @"-";
  NSString * weight = @"-";
  NSString * weightType = @"-";
  NSString * weightIncrement = @"-";
  NSString * price = @"-";
  NSString * priceIncrement = @"-";
  NSString * priceCurrency = @"-";
  NSMutableDictionary * uncommonAIs = [NSMutableDictionary dictionary];

  int i = 0;

  while (i < [rawText length]) {
    NSString * ai = [self findAIvalue:i rawText:rawText];
    if ([@"ERROR" isEqualToString:ai]) {
      return nil;
    }
    i += [ai length] + 2;
    NSString * value = [self findValue:i rawText:rawText];
    i += [value length];

    if ([@"00" isEqualToString:ai]) {
      sscc = value;
    } else if ([@"01" isEqualToString:ai]) {
      productID = value;
    } else if ([@"10" isEqualToString:ai]) {
      lotNumber = value;
    } else if ([@"11" isEqualToString:ai]) {
      productionDate = value;
    } else if ([@"13" isEqualToString:ai]) {
      packagingDate = value;
    } else if ([@"15" isEqualToString:ai]) {
      bestBeforeDate = value;
    } else if ([@"17" isEqualToString:ai]) {
      expirationDate = value;
    } else if ([@"3100" isEqualToString:ai] || [@"3101" isEqualToString:ai] || [@"3102" isEqualToString:ai] || [@"3103" isEqualToString:ai] || [@"3104" isEqualToString:ai] || [@"3105" isEqualToString:ai] || [@"3106" isEqualToString:ai] || [@"3107" isEqualToString:ai] || [@"3108" isEqualToString:ai] || [@"3109" isEqualToString:ai]) {
      weight = value;
      weightType = KILOGRAM;
      weightIncrement = [ai substringFromIndex:3];
    } else if ([@"3200" isEqualToString:ai] || [@"3201" isEqualToString:ai] || [@"3202" isEqualToString:ai] || [@"3203" isEqualToString:ai] || [@"3204" isEqualToString:ai] || [@"3205" isEqualToString:ai] || [@"3206" isEqualToString:ai] || [@"3207" isEqualToString:ai] || [@"3208" isEqualToString:ai] || [@"3209" isEqualToString:ai]) {
      weight = value;
      weightType = POUND;
      weightIncrement = [ai substringFromIndex:3];
    } else if ([@"3920" isEqualToString:ai] || [@"3921" isEqualToString:ai] || [@"3922" isEqualToString:ai] || [@"3923" isEqualToString:ai]) {
      price = value;
      priceIncrement = [ai substringFromIndex:3];
    } else if ([@"3930" isEqualToString:ai] || [@"3931" isEqualToString:ai] || [@"3932" isEqualToString:ai] || [@"3933" isEqualToString:ai]) {
      if ([value length] < 4) {
        return nil;
      }
      price = [value substringFromIndex:3];
      priceCurrency = [value substringToIndex:3];
      priceIncrement = [ai substringFromIndex:3];
    } else {
      [uncommonAIs setObject:value forKey:ai];
    }
  }

  return [[[ZXExpandedProductParsedResult alloc] initWithProductID:productID
                                                              sscc:sscc
                                                         lotNumber:lotNumber
                                                    productionDate:productionDate
                                                     packagingDate:packagingDate
                                                    bestBeforeDate:bestBeforeDate
                                                    expirationDate:expirationDate
                                                            weight:weight
                                                        weightType:weightType
                                                   weightIncrement:weightIncrement
                                                             price:price
                                                    priceIncrement:priceIncrement
                                                     priceCurrency:priceCurrency
                                                       uncommonAIs:uncommonAIs] autorelease];
}

+ (NSString *)findAIvalue:(int)i rawText:(NSString *)rawText {
  NSMutableString * buf = [NSMutableString string];
  unichar c = [rawText characterAtIndex:i];
  if (c != '(') {
    return @"ERROR";
  }

  NSString * rawTextAux = [rawText substringFromIndex:i + 1];

  for (int index = 0; index < [rawTextAux length]; index++) {
    unichar currentChar = [rawTextAux characterAtIndex:index];
    switch (currentChar) {
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      [buf appendFormat:@"%C", currentChar];
      break;
    case ')':
      return [NSString stringWithString:buf];
    default:
      return @"ERROR";
    }
  }

  return [NSString stringWithString:buf];
}

+ (NSString *)findValue:(int)i rawText:(NSString *)rawText {
  NSMutableString * buf = [NSMutableString string];
  NSString * rawTextAux = [rawText substringFromIndex:i];

  for (int index = 0; index < [rawTextAux length]; index++) {
    unichar c = [rawTextAux characterAtIndex:index];
    if (c == '(') {
      if ([@"ERROR" isEqualToString:[self findAIvalue:index rawText:rawTextAux]]) {
        [buf appendString:@"("];
      } else {
        break;
      }
    } else {
      [buf appendFormat:@"%C", c];
    }
  }

  return [NSString stringWithString:buf];
}

@end
