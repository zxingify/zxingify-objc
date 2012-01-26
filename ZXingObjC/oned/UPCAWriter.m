#import "UPCAWriter.h"

@implementation UPCAWriter

- (void) init {
  if (self = [super init]) {
    subWriter = [[[EAN13Writer alloc] init] autorelease];
  }
  return self;
}

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height {
  return [self encode:contents format:format width:width height:height hints:nil];
}

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints {
  if (format != BarcodeFormat.UPC_A) {
    @throw [[[IllegalArgumentException alloc] init:[@"Can only encode UPC-A, but got " stringByAppendingString:format]] autorelease];
  }
  return [subWriter encode:[self preencode:contents] param1:BarcodeFormat.EAN_13 param2:width param3:height param4:hints];
}


/**
 * Transform a UPC-A code into the equivalent EAN-13 code, and add a check digit if it is not
 * already present.
 */
+ (NSString *) preencode:(NSString *)contents {
  int length = [contents length];
  if (length == 11) {
    int sum = 0;

    for (int i = 0; i < 11; ++i) {
      sum += ([contents characterAtIndex:i] - '0') * (i % 2 == 0 ? 3 : 1);
    }

    contents = [contents stringByAppendingString:(1000 - sum) % 10];
  }
   else if (length != 12) {
    @throw [[[IllegalArgumentException alloc] init:[@"Requested contents should be 11 or 12 digits long, but got " stringByAppendingString:[contents length]]] autorelease];
  }
  return ['0' stringByAppendingString:contents];
}

- (void) dealloc {
  [subWriter release];
  [super dealloc];
}

@end
