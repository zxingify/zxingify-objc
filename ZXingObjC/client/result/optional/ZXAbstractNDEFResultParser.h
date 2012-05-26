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

#import "ZXResultParser.h"

/**
 * Superclass for classes encapsulating results in the NDEF format.
 * See http://www.nfc-forum.org/specs/.
 * 
 * This code supports a limited subset of NDEF messages, ones that are plausibly
 * useful in 2D barcode formats. This generally includes 1-record messages, no chunking,
 * "short record" syntax, no ID field.
 */

@interface ZXAbstractNDEFResultParser : ZXResultParser

+ (NSString *)bytesToString:(unsigned char *)bytes offset:(int)offset length:(unsigned int)length encoding:(NSStringEncoding)encoding;

@end
