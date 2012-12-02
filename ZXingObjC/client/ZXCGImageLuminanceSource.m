/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <CoreVideo/CoreVideo.h>
#import "ZXCGImageLuminanceSource.h"
#import "ZXImage.h"

@interface ZXCGImageLuminanceSource ()

- (void)initializeWithImage:(CGImageRef)image left:(int)left top:(int)top width:(int)width height:(int)height;
- (void)fillGrayscale:(unsigned char*)array offset:(int)offset size:(int)size;

@end

@implementation ZXCGImageLuminanceSource

+ (CGImageRef)createImageFromBuffer:(CVImageBufferRef)buffer {
  return [self createImageFromBuffer:buffer
                                left:0
                                 top:0
                               width:CVPixelBufferGetWidth(buffer)
                              height:CVPixelBufferGetHeight(buffer)];
}

+ (CGImageRef)createImageFromBuffer:(CVImageBufferRef)buffer
                                      left:(size_t)left
                                       top:(size_t)top
                                     width:(size_t)width
                                    height:(size_t)height {
  int bytesPerRow = (int)CVPixelBufferGetBytesPerRow(buffer);
  int dataWidth = (int)CVPixelBufferGetWidth(buffer);
  int dataHeight = (int)CVPixelBufferGetHeight(buffer);

  if (left + width > dataWidth ||
      top + height > dataHeight) {
    [NSException raise:NSInvalidArgumentException format:@"Crop rectangle does not fit within image data."];
  }

  int newBytesPerRow = ((width*4+0xf)>>4)<<4;

  CVPixelBufferLockBaseAddress(buffer,0); 

  unsigned char* baseAddress =
  (unsigned char*)CVPixelBufferGetBaseAddress(buffer); 

  int size = newBytesPerRow*height;
  unsigned char* bytes = (unsigned char*)malloc(size);
  if (newBytesPerRow == bytesPerRow) {
    memcpy(bytes, baseAddress+top*bytesPerRow, size);
  } else {
    for(int y=0; y<height; y++) {
      memcpy(bytes+y*newBytesPerRow,
             baseAddress+left*4+(top+y)*bytesPerRow,
             bytesPerRow);
    }
  }
  CVPixelBufferUnlockBaseAddress(buffer, 0);

  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
  CGContextRef newContext = CGBitmapContextCreate(bytes,
                                                  width,
                                                  height,
                                                  8,
                                                  newBytesPerRow,
                                                  colorSpace,
                                                  kCGBitmapByteOrder32Little|
                                                  kCGImageAlphaNoneSkipFirst);
  CGColorSpaceRelease(colorSpace);

  CGImageRef result = CGBitmapContextCreateImage(newContext);
  [NSMakeCollectable(result) autorelease];

  CGContextRelease(newContext);

  free(bytes);

  return result;
}

- (id)initWithZXImage:(ZXImage*)_image 
                 left:(size_t)_left
                  top:(size_t)_top
                width:(size_t)_width
               height:(size_t)_height {
  self = [self initWithCGImage:_image.cgimage left:(int)_left top:(int)_top width:(int)_width height:(int)_height];

  return self;
}

- (id)initWithZXImage:(ZXImage*)_image {
  self = [self initWithCGImage:_image.cgimage];

  return self;
}

- (id)initWithCGImage:(CGImageRef)_image 
                 left:(size_t)_left
                  top:(size_t)_top
                width:(size_t)_width
               height:(size_t)_height {
  if (self = [super init]) {
    [self initializeWithImage:_image left:(int)_left top:(int)_top width:(int)_width height:(int)_height];
  }

  return self;
}

- (id)initWithCGImage:(CGImageRef)_image {
  self = [self initWithCGImage:_image left:0 top:0 width:(int)CGImageGetWidth(_image) height:(int)CGImageGetHeight(_image)];

  return self;
}

- (id)initWithBuffer:(CVPixelBufferRef)buffer
                left:(size_t)_left
                 top:(size_t)_top
               width:(size_t)_width
              height:(size_t)_height {
  CGImageRef _image = [ZXCGImageLuminanceSource createImageFromBuffer:buffer left:(int)_left top:(int)_top width:(int)_width height:(int)_height];

  self = [self initWithCGImage:_image];

  return self;
}

- (id )initWithBuffer:(CVPixelBufferRef)buffer {
  CGImageRef _image = [ZXCGImageLuminanceSource createImageFromBuffer:buffer];

  self = [self initWithCGImage:_image];

  return self;
}

- (CGImageRef)image {
  return image;
}

- (void)dealloc {  
  if (image) {
    CGImageRelease(image);
  }
  if (data) {
    free(data);
  }

  [super dealloc];
}

- (unsigned char *)row:(int)y row:(unsigned char *)row {
  if (y < 0 || y >= self.height) {
    [NSException raise:NSInvalidArgumentException format:@"Requested row is outside the image: %d", y];
  }

  if (row == NULL) {
    row = (unsigned char*)malloc(self.width * sizeof(unsigned char));
  }

  int offset = (y + top) * dataWidth + left;
  [self fillGrayscale:row offset:offset size:self.width];

  return row;
}

- (unsigned char*)matrix {
  int size = self.width * self.height;

  unsigned char* result = (unsigned char*)malloc(size * sizeof(unsigned char));

  if (left == 0 && top == 0 && dataWidth == self.width && dataHeight == self.height) {
    [self fillGrayscale:result offset:0 size:size];
  } else {
    for (int row = 0; row < self.height; row++) {
      [self fillGrayscale:result + row * self.width offset:(top + row) * dataWidth + left size:self.width];
    }
  }

  return result;
}

- (void)initializeWithImage:(CGImageRef)cgimage left:(int)_left top:(int)_top width:(int)_width height:(int)_height {
  data = 0;
  image = CGImageRetain(cgimage);
  left = _left;
  top = _top;
  self->width = _width;
  self->height = _height;
  dataWidth = (int)CGImageGetWidth(cgimage);
  dataHeight = (int)CGImageGetHeight(cgimage);
  
  if (left + self.width > dataWidth ||
      top + self.height > dataHeight ||
      top < 0 ||
      left < 0) {
    [NSException raise:NSInvalidArgumentException format:@"Crop rectangle does not fit within image data."];
  }
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(0, self.width, self.height, 8, self.width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
  CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
  CGContextSetShouldAntialias(context, NO);

  if (top || left) {
    CGContextClipToRect(context, CGRectMake(0, 0, self.width, self.height));
  }
  
  CGContextDrawImage(context, CGRectMake(-left, -top, self.width, self.height), image);

  data = (uint32_t *) malloc(self.width * self.height * sizeof(uint32_t));
  memcpy(data, CGBitmapContextGetData(context), self.width * self.height * sizeof(uint32_t));
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);

  top = 0;
  left = 0;
  dataWidth = self.width;
  dataHeight = self.height;
}

- (void)fillGrayscale:(unsigned char*)array offset:(int)offset size:(int)size {
  static double redRatio = 77.0f/255.0f;
  static double greenRatio = 149.0f/255.0f;
  static double blueRatio = 29.0f/255.0f;

  for (int i = 0; i < size; i++) {
    uint32_t rgbPixel=data[offset+i];
    int red = (rgbPixel>>24)&255;
    int green = (rgbPixel>>16)&255;
    int blue = (rgbPixel>>8)&255;
    array[i] = roundf(redRatio * red + greenRatio * green + blueRatio * blue);
  }
}

- (BOOL)rotateSupported {
  return YES;
}

- (ZXLuminanceSource*)rotateCounterClockwise {
  double radians = 270.0f * M_PI / 180;

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
  radians = -1 * radians;
#endif

  int sourceWidth = self.width;
  int sourceHeight = self.height;

  CGRect imgRect = CGRectMake(0, 0, sourceWidth, sourceHeight);
  CGAffineTransform transform = CGAffineTransformMakeRotation(radians);
  CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);

  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(NULL,
                                               rotatedRect.size.width,
                                               rotatedRect.size.height,
                                               CGImageGetBitsPerComponent(self.image),
                                               0,
                                               colorSpace,
                                               kCGImageAlphaPremultipliedFirst);
  CGContextSetAllowsAntialiasing(context, FALSE);
  CGContextSetInterpolationQuality(context, kCGInterpolationNone);
  CGColorSpaceRelease(colorSpace);

  CGContextTranslateCTM(context,
                        +(rotatedRect.size.width/2),
                        +(rotatedRect.size.height/2));
  CGContextRotateCTM(context, radians);

  CGContextDrawImage(context, CGRectMake(-imgRect.size.width/2,
                                         -imgRect.size.height/2,
                                         imgRect.size.width,
                                         imgRect.size.height),
                     self.image);

  CGImageRef rotatedImage = CGBitmapContextCreateImage(context);
  [NSMakeCollectable(rotatedImage) autorelease];

  CFRelease(context);

  int _width = self.width;
  return [[[ZXCGImageLuminanceSource alloc] initWithCGImage:rotatedImage left:top top:sourceWidth - (left + _width) width:self.height height:_width] autorelease];
}

@end
