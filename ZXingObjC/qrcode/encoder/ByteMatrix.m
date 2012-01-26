#import "ByteMatrix.h"

@implementation ByteMatrix

@synthesize height;
@synthesize width;
@synthesize array;

- (id) init:(int)width height:(int)height {
  if (self = [super init]) {
    bytes = [NSArray array];
    width = width;
    height = height;
  }
  return self;
}

- (char) get:(int)x y:(int)y {
  return bytes[y][x];
}

- (void) set:(int)x y:(int)y value:(char)value {
  bytes[y][x] = value;
}

- (void) set:(int)x y:(int)y value:(int)value {
  bytes[y][x] = (char)value;
}

- (void) set:(int)x y:(int)y value:(BOOL)value {
  bytes[y][x] = (char)(value ? 1 : 0);
}

- (void) clear:(char)value {

  for (int y = 0; y < height; ++y) {

    for (int x = 0; x < width; ++x) {
      bytes[y][x] = value;
    }

  }

}

- (NSString *) description {
  StringBuffer * result = [[[StringBuffer alloc] init:2 * width * height + 2] autorelease];

  for (int y = 0; y < height; ++y) {

    for (int x = 0; x < width; ++x) {

      switch (bytes[y][x]) {
      case 0:
        [result append:@" 0"];
        break;
      case 1:
        [result append:@" 1"];
        break;
      default:
        [result append:@"  "];
        break;
      }
    }

    [result append:'\n'];
  }

  return [result description];
}

- (void) dealloc {
  [bytes release];
  [super dealloc];
}

@end
