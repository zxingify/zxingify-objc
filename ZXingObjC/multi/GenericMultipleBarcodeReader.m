#import "GenericMultipleBarcodeReader.h"
#import "Reader.h"
#import "ReaderException.h"
#import "ResultPoint.h"

int const MIN_DIMENSION_TO_RECUR = 100;

@interface GenericMultipleBarcodeReader ()

- (void) doDecodeMultiple:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints results:(NSMutableArray *)results xOffset:(int)xOffset yOffset:(int)yOffset;
- (Result *) translateResultPoints:(Result *)result xOffset:(int)xOffset yOffset:(int)yOffset;

@end

@implementation GenericMultipleBarcodeReader

- (id) initWithDelegate:(id <Reader>)aDelegate {
  if (self = [super init]) {
    delegate = aDelegate;
  }
  return self;
}

- (NSArray *) decodeMultiple:(BinaryBitmap *)image {
  return [self decodeMultiple:image hints:nil];
}

- (NSArray *) decodeMultiple:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints {
  NSMutableArray * results = [NSMutableArray array];
  [self doDecodeMultiple:image hints:hints results:results xOffset:0 yOffset:0];
  if ([results count] == 0) {
    @throw [NotFoundException notFoundInstance];
  }
  return results;
}

- (void) doDecodeMultiple:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints results:(NSMutableArray *)results xOffset:(int)xOffset yOffset:(int)yOffset {
  Result * result;
  @try {
    result = [delegate decode:image hints:hints];
  }
  @catch (ReaderException * re) {
    return;
  }
  BOOL alreadyFound = NO;
  for (Result * existingResult in results) {
    if ([[existingResult text] isEqualToString:[result text]]) {
      alreadyFound = YES;
      break;
    }
  }
  if (alreadyFound) {
    return;
  }
  [results addObject:[self translateResultPoints:result xOffset:xOffset yOffset:yOffset]];
  NSMutableArray * resultPoints = [result resultPoints];
  if (resultPoints == nil || [resultPoints count] == 0) {
    return;
  }
  int width = [image width];
  int height = [image height];
  float minX = width;
  float minY = height;
  float maxX = 0.0f;
  float maxY = 0.0f;
  for (ResultPoint * point in resultPoints) {
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
    [self doDecodeMultiple:[image crop:0 top:0 width:(int)minX height:height] hints:hints results:results xOffset:xOffset yOffset:yOffset];
  }
  if (minY > MIN_DIMENSION_TO_RECUR) {
    [self doDecodeMultiple:[image crop:0 top:0 width:width height:(int)minY] hints:hints results:results xOffset:xOffset yOffset:yOffset];
  }
  if (maxX < width - MIN_DIMENSION_TO_RECUR) {
    [self doDecodeMultiple:[image crop:(int)maxX top:0 width:width - (int)maxX height:height] hints:hints results:results xOffset:xOffset + (int)maxX yOffset:yOffset];
  }
  if (maxY < height - MIN_DIMENSION_TO_RECUR) {
    [self doDecodeMultiple:[image crop:0 top:(int)maxY width:width height:height - (int)maxY] hints:hints results:results xOffset:xOffset yOffset:yOffset + (int)maxY];
  }
}

- (Result *) translateResultPoints:(Result *)result xOffset:(int)xOffset yOffset:(int)yOffset {
  NSArray * oldResultPoints = [result resultPoints];
  NSMutableArray * newResultPoints = [NSMutableArray arrayWithCapacity:[oldResultPoints count]];
  for (ResultPoint * oldPoint in oldResultPoints) {
    [newResultPoints addObject:[[[ResultPoint alloc] initWithX:[oldPoint x] + xOffset y:[oldPoint y] + yOffset] autorelease]];
  }

  return [[[Result alloc] initWithText:[result text] rawBytes:[result rawBytes] resultPoints:newResultPoints format:[result barcodeFormat]] autorelease];
}

@end
