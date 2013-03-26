/*
 * Copyright 2013 ZXing authors
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

#import "ZXAztecCode.h"
#import "ZXAztecEncoder.h"
#import "ZXAztecWriter.h"

@implementation ZXAztecWriter

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height error:(NSError **)error {
  char bytes[4096];
  [contents getCString:bytes maxLength:4096 encoding:NSISOLatin1StringEncoding];
  int bytesLen = [contents lengthOfBytesUsingEncoding:NSISOLatin1StringEncoding];

  ZXAztecCode *aztec = [ZXAztecEncoder encode:(unsigned char *)bytes len:bytesLen minECCPercent:30];
  return aztec.matrix;
}

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height hints:(ZXEncodeHints *)hints error:(NSError **)error {
  return [self encode:contents format:format width:width height:height error:error];
}

@end
