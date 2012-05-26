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

/**
 * A class which wraps a 2D array of bytes. The default usage is signed. If you want to use it as a
 * unsigned container, it's up to you to do byteValue & 0xff at each location.
 */

@interface ZXByteMatrix : NSObject

@property (nonatomic, assign, readonly) int height;
@property (nonatomic, assign, readonly) int width;
@property (nonatomic, assign, readonly) unsigned char** array;

- (id)initWithWidth:(int)width height:(int)height;
- (char)getX:(int)x y:(int)y;
- (void)setX:(int)x y:(int)y charValue:(char)value;
- (void)setX:(int)x y:(int)y intValue:(int)value;
- (void)setX:(int)x y:(int)y boolValue:(BOOL)value;
- (void)clear:(char)value;

@end
