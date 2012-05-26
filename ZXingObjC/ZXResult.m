#import "ZXResult.h"

@interface ZXResult ()

@property (nonatomic, copy)   NSString * text;
@property (nonatomic, assign) unsigned char * rawBytes;
@property (nonatomic, assign) int length;
@property (nonatomic, retain) NSMutableArray * resultPoints;
@property (nonatomic, assign) ZXBarcodeFormat barcodeFormat;
@property (nonatomic, retain) NSMutableDictionary * resultMetadata;
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
    if (aText == nil && aRawBytes == nil) {
      @throw [NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"Text and bytes are null"
                                   userInfo:nil];
    }

    self.text = aText;
    if (aRawBytes != NULL && aLength > 0) {
      self.rawBytes = (unsigned char*)malloc(aLength * sizeof(unsigned char));
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
      for (id key in [metadata allKeys]) {
        id value = [metadata objectForKey:key];
        [self.resultMetadata setObject:value forKey:key];
      }
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
  if (self.text == nil) {
    return [NSString stringWithFormat:@"[%d]", self.length];
  } else {
    return self.text;
  }
}

@end
