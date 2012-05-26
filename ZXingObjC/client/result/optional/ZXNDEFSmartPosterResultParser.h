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

#import "ZXAbstractNDEFResultParser.h"

/**
 * Recognizes an NDEF message that encodes information according to the
 * "Smart Poster Record Type Definition" specification.
 * 
 * This actually only supports some parts of the Smart Poster format: title,
 * URI, and action records. Icon records are not supported because the size
 * of these records are infeasibly large for barcodes. Size and type records
 * are not supported. Multiple titles are not supported.
 */

@class ZXNDEFSmartPosterParsedResult, ZXResult;

@interface ZXNDEFSmartPosterResultParser : ZXAbstractNDEFResultParser

+ (ZXNDEFSmartPosterParsedResult *)parse:(ZXResult *)result;

@end
