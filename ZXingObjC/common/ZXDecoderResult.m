#import "ZXDecoderResult.h"

@interface ZXDecoderResult ()

@property (nonatomic, assign) unsigned char * rawBytes;
@property (nonatomic, assign) int length;
@property (nonatomic, copy) NSString * text;
@property (nonatomic, retain) NSMutableArray * byteSegments;
@property (nonatomic, copy) NSString * ecLevel;

@end

@implementation ZXDecoderResult

@synthesize rawBytes;
@synthesize length;
@synthesize text;
@synthesize byteSegments;
@synthesize ecLevel;

- (id)initWithRawBytes:(unsigned char *)theRawBytes
                length:(unsigned int)aLength
                  text:(NSString *)theText
          byteSegments:(NSMutableArray *)theByteSegments
               ecLevel:(NSString *)anEcLevel {
  if (self = [super init]) {
    if (theRawBytes == nil && theText == nil) {
      [NSException raise:NSInvalidArgumentException 
                  format:@"Bytes and text must be non-null."];
    }
    self.rawBytes = theRawBytes;
    self.length = aLength;
    self.text = theText;
    self.byteSegments = theByteSegments;
    self.ecLevel = anEcLevel;
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
