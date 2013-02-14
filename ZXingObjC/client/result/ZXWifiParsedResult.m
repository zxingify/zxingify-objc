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

#import "ZXParsedResultType.h"
#import "ZXWifiParsedResult.h"

@interface ZXWifiParsedResult ()

@property (nonatomic, copy) NSString *ssid;
@property (nonatomic, copy) NSString *networkEncryption;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) BOOL hidden;

@end

@implementation ZXWifiParsedResult

@synthesize ssid;
@synthesize networkEncryption;
@synthesize password;
@synthesize hidden;

- (id)initWithNetworkEncryption:(NSString *)aNetworkEncryption ssid:(NSString *)anSsid password:(NSString *)aPassword {
  return [self initWithNetworkEncryption:aNetworkEncryption ssid:anSsid password:aPassword];
}

- (id)initWithNetworkEncryption:(NSString *)aNetworkEncryption ssid:(NSString *)anSsid password:(NSString *)aPassword hidden:(BOOL)isHidden {
  if (self = [super initWithType:kParsedResultTypeWifi]) {
    self.ssid = anSsid;
    self.networkEncryption = aNetworkEncryption;
    self.password = aPassword;
    self.hidden = isHidden;
  }

  return self;
}

+ (id)wifiParsedResultWithNetworkEncryption:(NSString *)networkEncryption ssid:(NSString *)ssid password:(NSString *)password {
  return [[[self alloc] initWithNetworkEncryption:networkEncryption ssid:ssid password:password] autorelease];
}

+ (id)wifiParsedResultWithNetworkEncryption:(NSString *)networkEncryption ssid:(NSString *)ssid password:(NSString *)password hidden:(BOOL)hidden {
  return [[[self alloc] initWithNetworkEncryption:networkEncryption ssid:ssid password:password hidden:hidden] autorelease];
}

- (void)dealloc {
  [ssid release];
  [networkEncryption release];
  [password release];
  
  [super dealloc];
}

- (NSString *)displayResult {
  NSMutableString *result = [NSMutableString stringWithCapacity:80];
  [ZXParsedResult maybeAppend:ssid result:result];
  [ZXParsedResult maybeAppend:networkEncryption result:result];
  [ZXParsedResult maybeAppend:password result:result];
  [ZXParsedResult maybeAppend:[[NSNumber numberWithBool:hidden] stringValue] result:result];
  return result;
}

@end
