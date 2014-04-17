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

#ifndef _ZXINGOBJC_CORE_

#define _ZXINGOBJC_CORE_

#import "ZXCapture.h"
#import "ZXCaptureDelegate.h"
#import "ZXCaptureView.h"
#import "ZXCGImageLuminanceSource.h"
#import "ZXImage.h"
#import "ZXView.h"

#import "ZXMathUtils.h"
#import "ZXMonochromeRectangleDetector.h"
#import "ZXWhiteRectangleDetector.h"

#import "ZXBitArray.h"
#import "ZXBitMatrix.h"
#import "ZXBitSource.h"
#import "ZXCharacterSetECI.h"
#import "ZXDecoderResult.h"
#import "ZXDefaultGridSampler.h"
#import "ZXDetectorResult.h"
#import "ZXECI.h"
#import "ZXGlobalHistogramBinarizer.h"
#import "ZXGridSampler.h"
#import "ZXHybridBinarizer.h"
#import "ZXPerspectiveTransform.h"
#import "ZXStringUtils.h"

#import "ZXGenericGF.h"
#import "ZXGenericGFPoly.h"
#import "ZXReedSolomonDecoder.h"
#import "ZXReedSolomonEncoder.h"

#import "ZXBarcodeFormat.h"
#import "ZXBinarizer.h"
#import "ZXBinaryBitmap.h"
#import "ZXDecodeHints.h"
#import "ZXDimension.h"
#import "ZXEncodeHints.h"
#import "ZXErrors.h"
#import "ZXInvertedLuminanceSource.h"
#import "ZXLuminanceSource.h"
#import "ZXPlanarYUVLuminanceSource.h"
#import "ZXReader.h"
#import "ZXResult.h"
#import "ZXResultMetadataType.h"
#import "ZXResultPoint.h"
#import "ZXResultPointCallback.h"
#import "ZXRGBLuminanceSource.h"
#import "ZXWriter.h"

#import "ZXByQuadrantReader.h"
#import "ZXGenericMultipleBarcodeReader.h"
#import "ZXMultipleBarcodeReader.h"

#endif
