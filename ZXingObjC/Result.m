#import "Result.h"

@implementation Result

@synthesize text;
@synthesize rawBytes;
@synthesize resultPoints;
@synthesize barcodeFormat=format;
@synthesize resultMetadata;
@synthesize timestamp;

- (id) init:(NSString *)aText rawBytes:(NSArray *)aRawBytes resultPoints:(NSArray *)aResultPoints format:(BarcodeFormat)aFormat {
  if (self = [self init:aText rawBytes:aRawBytes resultPoints:aResultPoints format:aFormat timestamp:CFAbsoluteTimeGetCurrent()]) {
  }
  return self;
}

- (id) init:(NSString *)aText rawBytes:(NSArray *)aRawBytes resultPoints:(NSArray *)aResultPoints format:(BarcodeFormat)aFormat timestamp:(long)aTimestamp {
  if (self = [super init]) {
    if (aText == nil && aRawBytes == nil) {
      @throw [NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"Text and bytes are null"
                                   userInfo:nil];
    }
    self.text = aText;
    self.rawBytes = aRawBytes;
    self.resultPoints = aResultPoints;
    self.barcodeFormat = aFormat;
    self.resultMetadata = nil;
    timestamp = aTimestamp;
  }
  return self;
}

- (void) putMetadata:(ResultMetadataType)type value:(id)value {
  if (resultMetadata == nil) {
    self.resultMetadata = [[[NSMutableDictionary alloc] init] autorelease];
  }
  [self.resultMetadata setObject:[NSNumber numberWithInt:type] forKey:value];
}

- (void) putAllMetadata:(NSMutableDictionary *)metadata {
  if (metadata != nil) {
    if (self.resultMetadata == nil) {
      self.resultMetadata = metadata;
    } else {
      for (id key in [metadata allKeys]) {
        id value = [metadata objectForKey:key];
        [resultMetadata setObject:value forKey:key];
      }
    }
  }
}

- (void) addResultPoints:(NSArray *)newPoints {
  if (self.resultPoints == nil) {
    self.resultPoints = newPoints;
  } else if (newPoints != nil && [newPoints count] > 0) {
    self.resultPoints = [self.resultPoints arrayByAddingObjectsFromArray:newPoints];
  }
}

- (NSString *) description {
  if (text == nil) {
    return [NSString stringWithFormat:@"[%d]", [rawBytes count]];
  } else {
    return text;
  }
}

- (void) dealloc {
  [text release];
  [rawBytes release];
  [resultPoints release];
  [resultMetadata release];
  [super dealloc];
}

@end
