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

  unsigned char *baseAddress =
  (unsigned char *)CVPixelBufferGetBaseAddress(buffer); 

  int size = newBytesPerRow*height;
  unsigned char *bytes = (unsigned char*)malloc(size);
  if (newBytesPerRow == bytesPerRow) {
    memcpy(bytes, baseAddress+top*bytesPerRow, size);
  } else {
    for(int y=0; y<height; y++) {
      memcpy(bytes+y*newBytesPerRow,
             baseAddress+left*4+(top+y)*bytesPerRow,
             newBytesPerRow);
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

- (id)initWithZXImage:(ZXImage *)_image 
                 left:(size_t)_left
                  top:(size_t)_top
                width:(size_t)_width
               height:(size_t)_height {
  self = [self initWithCGImage:_image.cgimage left:(int)_left top:(int)_top width:(int)_width height:(int)_height];

  return self;
}

- (id)initWithZXImage:(ZXImage *)_image {
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

- (unsigned char *)row:(int)y {
  if (y < 0 || y >= self.height) {
    [NSException raise:NSInvalidArgumentException format:@"Requested row is outside the image: %d", y];
  }

  unsigned char *row = (unsigned char *)malloc(self.width * sizeof(unsigned char));

  int offset = y * self.width;
  memcpy(row, data + offset, self.width);
  return row;
}

- (unsigned char *)matrix {
  int area = self.width * self.height;

  unsigned char *result = (unsigned char *)malloc(area * sizeof(unsigned char));
  memcpy(result, data, area * sizeof(unsigned char));
  return result;
}

- (void)initializeWithImage:(CGImageRef)cgimage left:(int)_left top:(int)_top width:(int)_width height:(int)_height {
  data = 0;
  image = CGImageRetain(cgimage);
  left = _left;
  top = _top;
  self->width = _width;
  self->height = _height;
  int sourceWidth = (int)CGImageGetWidth(cgimage);
  int sourceHeight = (int)CGImageGetHeight(cgimage);

  if (left + self.width > sourceWidth ||
      top + self.height > sourceHeight ||
      top < 0 ||
      left < 0) {
    [NSException raise:NSInvalidArgumentException format:@"Crop rectangle does not fit within image data."];
  }

  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(0, self.width, self.height, 8, self.width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
  CGContextSetAllowsAntialiasing(context, FALSE);
  CGContextSetInterpolationQuality(context, kCGInterpolationNone);

  if (top || left) {
    CGContextClipToRect(context, CGRectMake(0, 0, self.width, self.height));
  }

  CGContextDrawImage(context, CGRectMake(-left, -top, self.width, self.height), image);

  uint32_t *pixelData = (uint32_t *) malloc(self.width * self.height * sizeof(uint32_t));
  memcpy(pixelData, CGBitmapContextGetData(context), self.width * self.height * sizeof(uint32_t));
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);

  data = (unsigned char *)malloc(self.width * self.height * sizeof(unsigned char));

  for (int i = 0; i < self.height * self.width; i++) {
    uint32_t rgbPixel=pixelData[i];

    float red = (rgbPixel>>24)&0xFF;
    float green = (rgbPixel>>16)&0xFF;
    float blue = (rgbPixel>>8)&0xFF;
    float alpha = (float)(rgbPixel & 0xFF) / 255.0f;

    // ImageIO premultiplies all PNGs, so we have to "un-premultiply them":
    // http://code.google.com/p/cocos2d-iphone/issues/detail?id=697#c26
    red = round((red / alpha) - 0.001f);
    green = round((green / alpha) - 0.001f);
    blue = round((blue / alpha) - 0.001f);

    if (red == green && green == blue) {
      data[i] = red;
    } else {
      data[i] = (306 * (int)red +
                 601 * (int)green +
                 117 * (int)blue +
                (0x200)) >> 10; // 0x200 = 1<<9, half an lsb of the result to force rounding
    }
  }

  free(pixelData);

  top = _top;
  left = _left;
}

- (BOOL)rotateSupported {
  return YES;
}

- (ZXLuminanceSource *)rotateCounterClockwise {
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
