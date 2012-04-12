#import "ZXDecoderResult.h"

@implementation ZXDecoderResult

@synthesize rawBytes;
@synthesize length;
@synthesize text;
@synthesize byteSegments;
@synthesize eCLevel;

- (id) init:(unsigned char *)theRawBytes length:(unsigned int)aLength text:(NSString *)theText byteSegments:(NSMutableArray *)theByteSegments ecLevel:(NSString *)anEcLevel {
  if (self = [super init]) {
    if (theRawBytes == nil && theText == nil) {
      [NSException raise:NSInvalidArgumentException 
                  format:@"Bytes and text must be non-null."];
    }
    rawBytes = theRawBytes;
    length = aLength;
    text = [theText copy];
    byteSegments = [theByteSegments retain];
    ecLevel = [anEcLevel copy];
  }
  return self;
}

- (void) dealloc {
  [text release];
  [byteSegments release];
  [ecLevel release];
  [super dealloc];
}

@end
