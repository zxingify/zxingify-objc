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

#import "ZXCompaction.h"
#import "ZXDimensions.h"
#import "ZXErrorCorrectionLevel.h"

/**
 * These are a set of hints that you may pass to Writers to specify their behavior.
 */

@interface ZXEncodeHints : NSObject

+ (id)hints;

/**
 * Specifies what character encoding to use where applicable.
 */
@property (nonatomic, assign) NSStringEncoding encoding;

/**
 * Specifies what degree of error correction to use, for example in QR Codes.
 */
@property (nonatomic, retain) ZXErrorCorrectionLevel *errorCorrectionLevel;

/**
 * Specifies whether to use compact mode for PDF417.
 */
@property (nonatomic, assign) BOOL pdf417Compact;

/**
 * Specifies what compaction mode to use for PDF417.
 */
@property (nonatomic, assign) ZXCompaction pdf417Compaction;

/**
 * Specifies the minimum and maximum number of rows and columns for PDF417.
 */
@property (nonatomic, retain) ZXDimensions *pdf417Dimensions;

@end
