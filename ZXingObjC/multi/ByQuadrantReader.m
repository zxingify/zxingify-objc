#import "ByQuadrantReader.h"
#import "NotFoundException.h"

@implementation ByQuadrantReader

- (id) initWithDelegate:(id<Reader>)aDelegate {
  if (self = [super init]) {
    delegate = aDelegate;
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

  BinaryBitmap * topLeft = [image crop:0 top:0 width:halfWidth height:halfHeight];
  @try {
    return [delegate decode:topLeft hints:hints];
  }
  @catch (NotFoundException * re) {
  }

  BinaryBitmap * topRight = [image crop:halfWidth top:0 width:halfWidth height:halfHeight];
  @try {
    return [delegate decode:topRight hints:hints];
  }
  @catch (NotFoundException * re) {
  }

  BinaryBitmap * bottomLeft = [image crop:0 top:halfHeight width:halfWidth height:halfHeight];
  @try {
    return [delegate decode:bottomLeft hints:hints];
  }
  @catch (NotFoundException * re) {
  }

  BinaryBitmap * bottomRight = [image crop:halfWidth top:halfHeight width:halfWidth height:halfHeight];
  @try {
    return [delegate decode:bottomRight hints:hints];
  }
  @catch (NotFoundException * re) {
  }

  int quarterWidth = halfWidth / 2;
  int quarterHeight = halfHeight / 2;
  BinaryBitmap * center = [image crop:quarterWidth top:quarterHeight width:halfWidth height:halfHeight];
  return [delegate decode:center hints:hints];
}

- (void) reset {
  [delegate reset];
}

@end
