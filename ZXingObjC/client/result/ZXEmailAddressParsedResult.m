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

#import "ZXEmailAddressParsedResult.h"
#import "ZXParsedResultType.h"

@interface ZXEmailAddressParsedResult ()

@property (nonatomic, copy) NSString *emailAddress;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *mailtoURI;

@end

@implementation ZXEmailAddressParsedResult

@synthesize emailAddress;
@synthesize subject;
@synthesize body;
@synthesize mailtoURI;

- (id)initWithEmailAddress:(NSString *)anEmailAddress subject:(NSString *)aSubject body:(NSString *)aBody mailtoURI:(NSString *)aMailtoURI {
  if (self = [super initWithType:kParsedResultTypeEmailAddress]) {
    self.emailAddress = anEmailAddress;
    self.subject = aSubject;
    self.body = aBody;
    self.mailtoURI = aMailtoURI;
  }

  return self;
}

+ (id)emailAddressParsedResultWithEmailAddress:(NSString *)emailAddress subject:(NSString *)subject body:(NSString *)body mailtoURI:(NSString *)mailtoURI {
  return [[[self alloc] initWithEmailAddress:emailAddress subject:subject body:body mailtoURI:mailtoURI] autorelease];
}

- (void)dealloc {
  [emailAddress release];
  [subject release];
  [body release];
  [mailtoURI release];
  
  [super dealloc];
}

- (NSString *)displayResult {
  NSMutableString *result = [NSMutableString stringWithCapacity:30];
  [ZXParsedResult maybeAppend:emailAddress result:result];
  [ZXParsedResult maybeAppend:subject result:result];
  [ZXParsedResult maybeAppend:body result:result];
  return result;
}

@end
