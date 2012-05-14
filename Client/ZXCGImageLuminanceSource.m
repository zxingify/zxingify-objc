/*
 * Copyright 2011 ZXing authors
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
  int bytesPerRow = CVPixelBufferGetBytesPerRow(buffer); 
  int dataWidth = CVPixelBufferGetWidth(buffer); 
  int dataHeight = CVPixelBufferGetHeight(buffer); 

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
      memcpy(bytes+y*bytesPerRow,
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
  
  CGContextRelease(newContext); 
  
  free(bytes);
  
  return result;

}

- (ZXCGImageLuminanceSource*)initWithZXImage:(ZXImage*)_image 
                                      left:(size_t)_left
                                       top:(size_t)_top
                                     width:(size_t)_width
                                    height:(size_t)_height {
  self = [self initWithCGImage:_image.cgimage left:_left top:_top width:_width height:_height];

  return self;
}

- (ZXCGImageLuminanceSource*)initWithZXImage:(ZXImage*)_image {
  self = [self initWithCGImage:_image.cgimage];

  return self;
}

- (ZXCGImageLuminanceSource*)initWithCGImage:(CGImageRef)_image 
                                      left:(size_t)_left
                                       top:(size_t)_top
                                     width:(size_t)_width
                                    height:(size_t)_height {
  if (self = [super init]) {
    [self initializeWithImage:_image left:_left top:_top width:_width height:_height];
  }

  return self;
}

- (ZXCGImageLuminanceSource*)initWithCGImage:(CGImageRef)_image {
  self = [self initWithCGImage:_image left:0 top:0 width:CGImageGetWidth(_image) height:CGImageGetHeight(_image)];

  return self;
}

- (ZXCGImageLuminanceSource*)initWithBuffer:(CVPixelBufferRef)buffer
                                      left:(size_t)_left
                                       top:(size_t)_top
                                     width:(size_t)_width
                                    height:(size_t)_height {
  CGImageRef _image = [ZXCGImageLuminanceSource createImageFromBuffer:buffer left:_left top:_top width:_width height:_height];
  
  self = [self initWithCGImage:_image];
  
  CGImageRelease(image);
  
  return self;
}

- (ZXCGImageLuminanceSource*)initWithBuffer:(CVPixelBufferRef)buffer {
  CGImageRef _image = [ZXCGImageLuminanceSource createImageFromBuffer:buffer];

  self = [self initWithCGImage:_image];

  CGImageRelease(image);

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
    CFRelease(data);
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
  CFDataGetBytes(data, CFRangeMake(offset, self.width), row);

  return row;
}

- (unsigned char*)matrix {
  int size = self.width * self.height;
  unsigned char* result = (unsigned char*)malloc(size * sizeof(unsigned char));
  if (left == 0 && top == 0 && dataWidth == self.width && dataHeight == self.height) {
    CFDataGetBytes(data, CFRangeMake(0, size), result);
  } else {
    for (int row = 0; row < self.height; row++) {
      CFDataGetBytes(data,
                     CFRangeMake((top + row) * dataWidth + left, self.width),
                     result + row * self.width);
    }
  }
  return result;
}

- (void)initializeWithImage:(CGImageRef)cgimage left:(int)_left top:(int)_top width:(int)_width height:(int)_height {
  data = 0;
  image = cgimage;
  left = _left;
  top = _top;
  self->width = _width;
  self->height = _height;
  dataWidth = CGImageGetWidth(cgimage);
  dataHeight = CGImageGetHeight(cgimage);
  
  if (left + self.width > dataWidth ||
      top + self.height > dataHeight ||
      top < 0 ||
      left < 0) {
    [NSException raise:NSInvalidArgumentException format:@"Crop rectangle does not fit within image data."];
  }
  
  CGColorSpaceRef space = CGImageGetColorSpace(self.image);
  CGColorSpaceModel model = CGColorSpaceGetModel(space);
  
  if (model != kCGColorSpaceModelMonochrome ||
      CGImageGetBitsPerComponent(self.image) != 8 ||
      CGImageGetBitsPerPixel(self.image) != 8) {

    CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();

    CGContextRef ctx = CGBitmapContextCreate(0,
                                             self.width,
                                             self.height, 
                                             8,
                                             self.width,
                                             gray, 
                                             kCGImageAlphaNone);

    CGColorSpaceRelease(gray);

    if (top || left) {
      CGContextClipToRect(ctx, CGRectMake(0, 0, self.width, self.height));
    }
    
    CGContextDrawImage(ctx, CGRectMake(-left, -top, self.width, self.height), image);
    
    image = CGBitmapContextCreateImage(ctx); 
    
    bytesPerRow = self.width;
    top = 0;
    left = 0;
    dataWidth = self.width;
    dataHeight = self.height;
    
    CGContextRelease(ctx);
  } else {
    CGImageRetain(image);
  }
  
  CGDataProviderRef provider = CGImageGetDataProvider(image);
  data = CGDataProviderCopyData(provider);
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
  CFMakeCollectable(rotatedImage);

  CFRelease(context);

  int _width = self.width;
  return [[[ZXCGImageLuminanceSource alloc] initWithCGImage:rotatedImage left:top top:sourceWidth - (left + _width) width:self.height height:_width] autorelease];
}

@end
