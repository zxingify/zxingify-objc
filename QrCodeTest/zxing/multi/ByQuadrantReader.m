#import "ByQuadrantReader.h"

@implementation ByQuadrantReader

- (id) initWithDelegate:(Reader *)delegate {
  if (self = [super init]) {
    delegate = delegate;
  }
  return self;
}

- (Result *) decode:(BinaryBitmap *)image {
  return [self decode:image hints:nil];
}

- (Result *) decode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints {
  int width = [image width];
  int height = [image height];
  int halfWidth = width / 2;
  int halfHeight = height / 2;
  BinaryBitmap * topLeft = [image crop:0 param1:0 param2:halfWidth param3:halfHeight];

  @try {
    return [delegate decode:topLeft param1:hints];
  }
  @catch (NotFoundException * re) {
  }
  BinaryBitmap * topRight = [image crop:halfWidth param1:0 param2:halfWidth param3:halfHeight];

  @try {
    return [delegate decode:topRight param1:hints];
  }
  @catch (NotFoundException * re) {
  }
  BinaryBitmap * bottomLeft = [image crop:0 param1:halfHeight param2:halfWidth param3:halfHeight];

  @try {
    return [delegate decode:bottomLeft param1:hints];
  }
  @catch (NotFoundException * re) {
  }
  BinaryBitmap * bottomRight = [image crop:halfWidth param1:halfHeight param2:halfWidth param3:halfHeight];

  @try {
    return [delegate decode:bottomRight param1:hints];
  }
  @catch (NotFoundException * re) {
  }
  int quarterWidth = halfWidth / 2;
  int quarterHeight = halfHeight / 2;
  BinaryBitmap * center = [image crop:quarterWidth param1:quarterHeight param2:halfWidth param3:halfHeight];
  return [delegate decode:center param1:hints];
}

- (void) reset {
  [delegate reset];
}

- (void) dealloc {
  [delegate release];
  [super dealloc];
}

@end
