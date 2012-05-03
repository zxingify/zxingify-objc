#import "ZXGenericMultipleBarcodeReader.h"
#import "ZXReader.h"
#import "ZXReaderException.h"
#import "ZXResultPoint.h"

int const MIN_DIMENSION_TO_RECUR = 100;

@interface ZXGenericMultipleBarcodeReader ()

- (void) doDecodeMultiple:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints results:(NSMutableArray *)results xOffset:(int)xOffset yOffset:(int)yOffset;
- (ZXResult *) translateResultPoints:(ZXResult *)result xOffset:(int)xOffset yOffset:(int)yOffset;

@end

@implementation ZXGenericMultipleBarcodeReader

- (id) initWithDelegate:(id <ZXReader>)aDelegate {
  if (self = [super init]) {
    delegate = aDelegate;
  }
  return self;
}

- (NSArray *) decodeMultiple:(ZXBinaryBitmap *)image {
  return [self decodeMultiple:image hints:nil];
}

- (NSArray *) decodeMultiple:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints {
  NSMutableArray * results = [NSMutableArray array];
  [self doDecodeMultiple:image hints:hints results:results xOffset:0 yOffset:0];
  if ([results count] == 0) {
    @throw [ZXNotFoundException notFoundInstance];
  }
  return results;
}

- (void) doDecodeMultiple:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints results:(NSMutableArray *)results xOffset:(int)xOffset yOffset:(int)yOffset {
  ZXResult * result;
  @try {
    result = [delegate decode:image hints:hints];
  }
  @catch (ZXReaderException * re) {
    return;
  }
  BOOL alreadyFound = NO;
  for (ZXResult * existingResult in results) {
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
  for (ZXResultPoint * point in resultPoints) {
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

- (ZXResult *) translateResultPoints:(ZXResult *)result xOffset:(int)xOffset yOffset:(int)yOffset {
  NSArray * oldResultPoints = [result resultPoints];
  NSMutableArray * newResultPoints = [NSMutableArray arrayWithCapacity:[oldResultPoints count]];
  for (ZXResultPoint * oldPoint in oldResultPoints) {
    [newResultPoints addObject:[[[ZXResultPoint alloc] initWithX:[oldPoint x] + xOffset y:[oldPoint y] + yOffset] autorelease]];
  }

  return [[[ZXResult alloc] initWithText:[result text] rawBytes:[result rawBytes] length:[result length] resultPoints:newResultPoints format:[result barcodeFormat]] autorelease];
}

@end
