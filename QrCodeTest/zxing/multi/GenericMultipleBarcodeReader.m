#import "GenericMultipleBarcodeReader.h"

int const MIN_DIMENSION_TO_RECUR = 100;

@implementation GenericMultipleBarcodeReader

- (id) initWithDelegate:(Reader *)delegate {
  if (self = [super init]) {
    delegate = delegate;
  }
  return self;
}

- (NSArray *) decodeMultiple:(BinaryBitmap *)image {
  return [self decodeMultiple:image hints:nil];
}

- (NSArray *) decodeMultiple:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints {
  NSMutableArray * results = [[[NSMutableArray alloc] init] autorelease];
  [self doDecodeMultiple:image hints:hints results:results xOffset:0 yOffset:0];
  if ([results empty]) {
    @throw [NotFoundException notFoundInstance];
  }
  int numResults = [results count];
  NSArray * resultArray = [NSArray array];

  for (int i = 0; i < numResults; i++) {
    resultArray[i] = (Result *)[results objectAtIndex:i];
  }

  return resultArray;
}

- (void) doDecodeMultiple:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints results:(NSMutableArray *)results xOffset:(int)xOffset yOffset:(int)yOffset {
  Result * result;

  @try {
    result = [delegate decode:image param1:hints];
  }
  @catch (ReaderException * re) {
    return;
  }
  BOOL alreadyFound = NO;

  for (int i = 0; i < [results count]; i++) {
    Result * existingResult = (Result *)[results objectAtIndex:i];
    if ([[existingResult text] isEqualTo:[result text]]) {
      alreadyFound = YES;
      break;
    }
  }

  if (alreadyFound) {
    return;
  }
  [results addObject:[self translateResultPoints:result xOffset:xOffset yOffset:yOffset]];
  NSArray * resultPoints = [result resultPoints];
  if (resultPoints == nil || resultPoints.length == 0) {
    return;
  }
  int width = [image width];
  int height = [image height];
  float minX = width;
  float minY = height;
  float maxX = 0.0f;
  float maxY = 0.0f;

  for (int i = 0; i < resultPoints.length; i++) {
    ResultPoint * point = resultPoints[i];
    float x = [point x];
    float y = [point y];
    if (x < minX) {
      minX = x;
    }
    if (y < minY) {
      minY = y;
    }
    if (x > maxX) {
      maxX = x;
    }
    if (y > maxY) {
      maxY = y;
    }
  }

  if (minX > MIN_DIMENSION_TO_RECUR) {
    [self doDecodeMultiple:[image crop:0 param1:0 param2:(int)minX param3:height] hints:hints results:results xOffset:xOffset yOffset:yOffset];
  }
  if (minY > MIN_DIMENSION_TO_RECUR) {
    [self doDecodeMultiple:[image crop:0 param1:0 param2:width param3:(int)minY] hints:hints results:results xOffset:xOffset yOffset:yOffset];
  }
  if (maxX < width - MIN_DIMENSION_TO_RECUR) {
    [self doDecodeMultiple:[image crop:(int)maxX param1:0 param2:width - (int)maxX param3:height] hints:hints results:results xOffset:xOffset + (int)maxX yOffset:yOffset];
  }
  if (maxY < height - MIN_DIMENSION_TO_RECUR) {
    [self doDecodeMultiple:[image crop:0 param1:(int)maxY param2:width param3:height - (int)maxY] hints:hints results:results xOffset:xOffset yOffset:yOffset + (int)maxY];
  }
}

+ (Result *) translateResultPoints:(Result *)result xOffset:(int)xOffset yOffset:(int)yOffset {
  NSArray * oldResultPoints = [result resultPoints];
  NSArray * newResultPoints = [NSArray array];

  for (int i = 0; i < oldResultPoints.length; i++) {
    ResultPoint * oldPoint = oldResultPoints[i];
    newResultPoints[i] = [[[ResultPoint alloc] init:[oldPoint x] + xOffset param1:[oldPoint y] + yOffset] autorelease];
  }

  return [[[Result alloc] init:[result text] param1:[result rawBytes] param2:newResultPoints param3:[result barcodeFormat]] autorelease];
}

- (void) dealloc {
  [delegate release];
  [super dealloc];
}

@end
