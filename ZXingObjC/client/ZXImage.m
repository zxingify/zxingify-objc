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

#import "ZXBitMatrix.h"
#import "ZXImage.h"

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
#import <ImageIO/ImageIO.h>
#endif

@implementation ZXImage

@synthesize cgimage;

- (ZXImage *)initWithCGImageRef:(CGImageRef)image {
  if (self = [super init]) {
    cgimage = CGImageRetain(image);
  }

  return self;
}

- (ZXImage *)initWithURL:(NSURL const *)url {
  if (self = [super init]) {
    CGDataProviderRef provider = CGDataProviderCreateWithURL((CFURLRef)url);

    if (provider) {
      CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, 0);

      if (source) {
        cgimage = CGImageSourceCreateImageAtIndex(source, 0, 0);

        CFRelease(source);
      }

      CGDataProviderRelease(provider);
    }
  }

  return self;
}

- (size_t)width {
  return CGImageGetWidth(cgimage);
}

- (size_t)height {
  return CGImageGetHeight(cgimage);
}

- (void)dealloc {
  if (cgimage) {
    CGImageRelease(cgimage);
  }
  [super dealloc];
}

+ (ZXImage *)imageWithMatrix:(ZXBitMatrix *)matrix {
  int width = matrix.width;
  int height = matrix.height;
  unsigned char *bytes = (unsigned char *)malloc(width * height * 4);
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      BOOL bit = [matrix getX:x y:y];
      unsigned char intensity = bit ? 0 : 255;
      for(int i = 0; i < 3; i++) {
        bytes[y * width * 4 + x * 4 + i] = intensity;
      }
      bytes[y * width * 4 + x * 4 + 3] = 255;
    }
  }

  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef c = CGBitmapContextCreate(bytes, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast);
  CFRelease(colorSpace);
  CGImageRef image = CGBitmapContextCreateImage(c);
  [NSMakeCollectable(image) autorelease];
  CFRelease(c);
  free(bytes);

  return [[[ZXImage alloc] initWithCGImageRef:image] autorelease];
}

@end
