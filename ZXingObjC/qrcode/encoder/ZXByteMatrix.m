#import "ZXByteMatrix.h"

@implementation ZXByteMatrix

@synthesize array=bytes;
@synthesize height;
@synthesize width;

- (id) initWithWidth:(int)aWidth height:(int)aHeight {
  if (self = [super init]) {
    width = aWidth;
    height = aHeight;

    bytes = (unsigned char**)malloc(height * sizeof(unsigned char*));
    for (int i = 0; i < height; i++) {
      bytes[i] = (unsigned char*)malloc(width * sizeof(unsigned char));
    }
    [self clear:0];
  }
  return self;
}

- (void)dealloc {
//  for (int i = 0; i < height; i++) {
//    free(bytes[i]);
//  }
//  free(bytes);

  [super dealloc];
}

- (char) get:(int)x y:(int)y {
  return bytes[y][x];
}

- (void) set:(int)x y:(int)y charValue:(char)value {
  bytes[y][x] = value;
}

- (void) set:(int)x y:(int)y intValue:(int)value {
  bytes[y][x] = (char)value;
}

- (void) set:(int)x y:(int)y boolValue:(BOOL)value {
  bytes[y][x] = (char)value;
}

- (void) clear:(char)value {
  for (int y = 0; y < height; ++y) {
    for (int x = 0; x < width; ++x) {
      bytes[y][x] = value;
    }
  }
}

- (NSString *) description {
  NSMutableString * result = [NSMutableString string];

  for (int y = 0; y < height; ++y) {

    for (int x = 0; x < width; ++x) {

      switch (bytes[y][x]) {
      case 0:
        [result appendString:@" 0"];
        break;
      case 1:
        [result appendString:@" 1"];
        break;
      default:
        [result appendString:@"  "];
        break;
      }
    }

    [result appendString:@"\n"];
  }

  return result;
}

@end
