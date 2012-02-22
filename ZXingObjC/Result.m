#import "Result.h"

@implementation Result

@synthesize text;
@synthesize rawBytes;
@synthesize length;
@synthesize resultPoints;
@synthesize barcodeFormat=format;
@synthesize resultMetadata;
@synthesize timestamp;

- (id) initWithText:(NSString *)aText rawBytes:(unsigned char *)aRawBytes length:(unsigned int)aLength resultPoints:(NSArray *)aResultPoints format:(BarcodeFormat)aFormat {
  if (self = [self initWithText:aText rawBytes:aRawBytes length:aLength resultPoints:aResultPoints format:aFormat timestamp:CFAbsoluteTimeGetCurrent()]) {
  }
  return self;
}

- (id) initWithText:(NSString *)aText rawBytes:(unsigned char *)aRawBytes length:(unsigned int)aLength resultPoints:(NSArray *)aResultPoints format:(BarcodeFormat)aFormat timestamp:(long)aTimestamp {
  if (self = [super init]) {
    if (aText == nil && aRawBytes == nil) {
      @throw [NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"Text and bytes are null"
                                   userInfo:nil];
    }
    text = [aText copy];
    rawBytes = aRawBytes;
    length = aLength;
    resultPoints = [[aResultPoints mutableCopy] autorelease];
    format = aFormat;
    resultMetadata = nil;
    timestamp = aTimestamp;
  }
  return self;
}

- (void) putMetadata:(ResultMetadataType)type value:(id)value {
  if (resultMetadata == nil) {
    resultMetadata = [[[NSMutableDictionary alloc] init] autorelease];
  }
  [resultMetadata setObject:[NSNumber numberWithInt:type] forKey:value];
}

- (void) putAllMetadata:(NSMutableDictionary *)metadata {
  if (metadata != nil) {
    if (self.resultMetadata == nil) {
      resultMetadata = [metadata retain];
    } else {
      for (id key in [metadata allKeys]) {
        id value = [metadata objectForKey:key];
        [resultMetadata setObject:value forKey:key];
      }
    }
  }
}

- (void) addResultPoints:(NSArray *)newPoints {
  if (resultPoints == nil) {
    resultPoints = [[newPoints mutableCopy] autorelease];
  } else if (newPoints != nil && [newPoints count] > 0) {
    resultPoints = [[[resultPoints arrayByAddingObjectsFromArray:newPoints] mutableCopy] autorelease];
  }
}

- (NSString *) description {
  if (text == nil) {
    return [NSString stringWithFormat:@"[%d]", length];
  } else {
    return text;
  }
}

- (void) dealloc {
  [text release];
  [resultPoints release];
  [resultMetadata release];

  [super dealloc];
}

@end
