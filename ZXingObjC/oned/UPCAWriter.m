#import "EAN13Writer.h"
#import "UPCAWriter.h"

@interface UPCAWriter ()

- (EAN13Writer *)subWriter;
+ (NSString *)preencode:(NSString *)contents;

@end

@implementation UPCAWriter

static EAN13Writer* subWriter = nil;

- (EAN13Writer *)subWriter {
  static EAN13Writer* subWriter = nil;
  if (!subWriter) {
    subWriter = [[[EAN13Writer alloc] init] autorelease];
  }

  return subWriter;
}

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat)format width:(int)width height:(int)height {
  return [self encode:contents format:format width:width height:height hints:nil];
}

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints {
  if (format != kBarcodeUPCA) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"Can only encode UPC-A, but got %d", format]
                                 userInfo:nil];
  }
  return [subWriter encode:[self preencode:contents] format:kBarcodeEan13 width:width height:height hints:hints];
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

    contents = [contents stringByAppendingFormat:@"%", (1000 - sum) % 10];
  }
   else if (length != 12) {
     @throw [NSException exceptionWithName:NSInvalidArgumentException
                                    reason:[NSString stringWithFormat:@"Requested contents should be 11 or 12 digits long, but got %d", [contents length]]
                                  userInfo:nil];
  }
  return [NSString stringWithFormat:@"0%@", contents];
}

- (void) dealloc {
  [subWriter release];
  [super dealloc];
}

@end
