#import "Result.h"

@implementation Result

@synthesize text;
@synthesize rawBytes;
@synthesize resultPoints;
@synthesize barcodeFormat;
@synthesize resultMetadata;
@synthesize timestamp;

- (id) init:(NSString *)text rawBytes:(NSArray *)rawBytes resultPoints:(NSArray *)resultPoints format:(BarcodeFormat *)format {
  if (self = [self init:text rawBytes:rawBytes resultPoints:resultPoints format:format timestamp:[System currentTimeMillis]]) {
  }
  return self;
}

- (id) init:(NSString *)text rawBytes:(NSArray *)rawBytes resultPoints:(NSArray *)resultPoints format:(BarcodeFormat *)format timestamp:(long)timestamp {
  if (self = [super init]) {
    if (text == nil && rawBytes == nil) {
      @throw [[[IllegalArgumentException alloc] init:@"Text and bytes are null"] autorelease];
    }
    text = text;
    rawBytes = rawBytes;
    resultPoints = resultPoints;
    format = format;
    resultMetadata = nil;
    timestamp = timestamp;
  }
  return self;
}

- (void) putMetadata:(ResultMetadataType *)type value:(NSObject *)value {
  if (resultMetadata == nil) {
    resultMetadata = [[[NSMutableDictionary alloc] init:3] autorelease];
  }
  [resultMetadata setObject:type param1:value];
}

- (void) putAllMetadata:(NSMutableDictionary *)metadata {
  if (metadata != nil) {
    if (resultMetadata == nil) {
      resultMetadata = metadata;
    }
     else {
      NSEnumerator * e = [metadata keys];

      while ([e hasMoreElements]) {
        ResultMetadataType * key = (ResultMetadataType *)[e nextObject];
        NSObject * value = [metadata objectForKey:key];
        [resultMetadata setObject:key param1:value];
      }

    }
  }
}

- (void) addResultPoints:(NSArray *)newPoints {
  if (resultPoints == nil) {
    resultPoints = newPoints;
  }
   else if (newPoints != nil && newPoints.length > 0) {
    NSArray * allPoints = [NSArray array];
    [System arraycopy:resultPoints param1:0 param2:allPoints param3:0 param4:resultPoints.length];
    [System arraycopy:newPoints param1:0 param2:allPoints param3:resultPoints.length param4:newPoints.length];
    resultPoints = allPoints;
  }
}

- (NSString *) description {
  if (text == nil) {
    return [[@"[" stringByAppendingString:rawBytes.length] stringByAppendingString:@" bytes]"];
  }
   else {
    return text;
  }
}

- (void) dealloc {
  [text release];
  [rawBytes release];
  [resultPoints release];
  [format release];
  [resultMetadata release];
  [super dealloc];
}

@end
