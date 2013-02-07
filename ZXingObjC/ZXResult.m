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

#import "ZXResult.h"

@interface ZXResult ()

@property (nonatomic, copy)   NSString *text;
@property (nonatomic, assign) unsigned char *rawBytes;
@property (nonatomic, assign) int length;
@property (nonatomic, retain) NSMutableArray *resultPoints;
@property (nonatomic, assign) ZXBarcodeFormat barcodeFormat;
@property (nonatomic, retain) NSMutableDictionary *resultMetadata;
@property (nonatomic, assign) long timestamp;

@end

@implementation ZXResult

@synthesize text;
@synthesize rawBytes;
@synthesize length;
@synthesize resultPoints;
@synthesize barcodeFormat;
@synthesize resultMetadata;
@synthesize timestamp;

- (id)initWithText:(NSString *)aText rawBytes:(unsigned char *)aRawBytes length:(unsigned int)aLength resultPoints:(NSArray *)aResultPoints format:(ZXBarcodeFormat)aFormat {
  return [self initWithText:aText rawBytes:aRawBytes length:aLength resultPoints:aResultPoints format:aFormat timestamp:CFAbsoluteTimeGetCurrent()];
}

- (id)initWithText:(NSString *)aText rawBytes:(unsigned char *)aRawBytes length:(unsigned int)aLength resultPoints:(NSArray *)aResultPoints format:(ZXBarcodeFormat)aFormat timestamp:(long)aTimestamp {
  if (self = [super init]) {
    self.text = aText;
    if (aRawBytes != NULL && aLength > 0) {
      self.rawBytes = (unsigned char *)malloc(aLength * sizeof(unsigned char));
      memcpy(self.rawBytes, aRawBytes, aLength);
      self.length = aLength;
    } else {
      self.rawBytes = NULL;
      self.length = 0;
    }
    self.resultPoints = [[aResultPoints mutableCopy] autorelease];
    self.barcodeFormat = aFormat;
    self.resultMetadata = nil;
    self.timestamp = aTimestamp;
  }

  return self;
}

+ (id)resultWithText:(NSString *)text rawBytes:(unsigned char *)rawBytes length:(unsigned int)length resultPoints:(NSArray *)resultPoints format:(ZXBarcodeFormat)format {
  return [[[self alloc] initWithText:text rawBytes:rawBytes length:length resultPoints:resultPoints format:format] autorelease];
}

+ (id)resultWithText:(NSString *)text rawBytes:(unsigned char *)rawBytes length:(unsigned int)length resultPoints:(NSArray *)resultPoints format:(ZXBarcodeFormat)format timestamp:(long)timestamp {
  return [[[self alloc] initWithText:text rawBytes:rawBytes length:length resultPoints:resultPoints format:format timestamp:timestamp] autorelease];
}

- (void)dealloc {
  if (self.rawBytes != NULL) {
    free(self.rawBytes);
    self.rawBytes = NULL;
  }

  [text release];
  [resultPoints release];
  [resultMetadata release];

  [super dealloc];
}

- (void)putMetadata:(ZXResultMetadataType)type value:(id)value {
  if (self.resultMetadata == nil) {
    self.resultMetadata = [NSMutableDictionary dictionary];
  }
  [self.resultMetadata setObject:[NSNumber numberWithInt:type] forKey:value];
}

- (void)putAllMetadata:(NSMutableDictionary *)metadata {
  if (metadata != nil) {
    if (self.resultMetadata == nil) {
      self.resultMetadata = metadata;
    } else {
      [self.resultMetadata addEntriesFromDictionary:metadata];
    }
  }
}

- (void)addResultPoints:(NSArray *)newPoints {
  if (self.resultPoints == nil) {
    self.resultPoints = [[newPoints mutableCopy] autorelease];
  } else if (newPoints != nil && [newPoints count] > 0) {
    [self.resultPoints addObjectsFromArray:newPoints];
  }
}

- (NSString *)description {
  return self.text;
}

@end
