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

#import <Foundation/Foundation.h>

// ZXingObjC/aztec/decoder
#import <ZXingObjC/ZXAztecDecoder.h>

// ZXingObjC/aztec/detector
#import <ZXingObjC/ZXAztecDetector.h>

// ZXingObjC/aztec
#import <ZXingObjC/ZXAztecDetectorResult.h>
#import <ZXingObjC/ZXAztecReader.h>

// ZXingObjC/client/result
#import <ZXingObjC/ZXAbstractDoCoMoResultParser.h>
#import <ZXingObjC/ZXAddressBookAUResultParser.h>
#import <ZXingObjC/ZXAddressBookDoCoMoResultParser.h>
#import <ZXingObjC/ZXAddressBookParsedResult.h>
#import <ZXingObjC/ZXBizcardResultParser.h>
#import <ZXingObjC/ZXBookmarkDoCoMoResultParser.h>
#import <ZXingObjC/ZXCalendarParsedResult.h>
#import <ZXingObjC/ZXEmailAddressParsedResult.h>
#import <ZXingObjC/ZXEmailAddressResultParser.h>
#import <ZXingObjC/ZXEmailDoCoMoResultParser.h>
#import <ZXingObjC/ZXExpandedProductParsedResult.h>
#import <ZXingObjC/ZXExpandedProductResultParser.h>
#import <ZXingObjC/ZXGeoParsedResult.h>
#import <ZXingObjC/ZXGeoResultParser.h>
#import <ZXingObjC/ZXISBNParsedResult.h>
#import <ZXingObjC/ZXISBNResultParser.h>
#import <ZXingObjC/ZXParsedResult.h>
#import <ZXingObjC/ZXParsedResultType.h>
#import <ZXingObjC/ZXProductParsedResult.h>
#import <ZXingObjC/ZXProductResultParser.h>
#import <ZXingObjC/ZXResultParser.h>
#import <ZXingObjC/ZXSMSMMSResultParser.h>
#import <ZXingObjC/ZXSMSParsedResult.h>
#import <ZXingObjC/ZXSMSTOMMSTOResultParser.h>
#import <ZXingObjC/ZXSMTPResultParser.h>
#import <ZXingObjC/ZXTelParsedResult.h>
#import <ZXingObjC/ZXTelResultParser.h>
#import <ZXingObjC/ZXTextParsedResult.h>
#import <ZXingObjC/ZXURIParsedResult.h>
#import <ZXingObjC/ZXURIResultParser.h>
#import <ZXingObjC/ZXURLTOResultParser.h>
#import <ZXingObjC/ZXVCardResultParser.h>
#import <ZXingObjC/ZXVEventResultParser.h>
#import <ZXingObjC/ZXWifiParsedResult.h>
#import <ZXingObjC/ZXWifiResultParser.h>

// ZXingObjC/client
#import <ZXingObjC/ZXCapture.h>
#import <ZXingObjC/ZXCaptureDelegate.h>
#import <ZXingObjC/ZXCaptureView.h>
#import <ZXingObjC/ZXCGImageLuminanceSource.h>
#import <ZXingObjC/ZXImage.h>
#import <ZXingObjC/ZXView.h>

// ZXingObjC/common/detector
#import <ZXingObjC/ZXMathUtils.h>
#import <ZXingObjC/ZXMonochromeRectangleDetector.h>
#import <ZXingObjC/ZXWhiteRectangleDetector.h>

// ZXingObjC/common/reedsolomon
#import <ZXingObjC/ZXGenericGF.h>
#import <ZXingObjC/ZXGenericGFPoly.h>
#import <ZXingObjC/ZXReedSolomonDecoder.h>
#import <ZXingObjC/ZXReedSolomonEncoder.h>

// ZXingObjC/common
#import <ZXingObjC/ZXBitArray.h>
#import <ZXingObjC/ZXBitMatrix.h>
#import <ZXingObjC/ZXBitSource.h>
#import <ZXingObjC/ZXCharacterSetECI.h>
#import <ZXingObjC/ZXDecoderResult.h>
#import <ZXingObjC/ZXDefaultGridSampler.h>
#import <ZXingObjC/ZXDetectorResult.h>
#import <ZXingObjC/ZXECI.h>
#import <ZXingObjC/ZXGlobalHistogramBinarizer.h>
#import <ZXingObjC/ZXGridSampler.h>
#import <ZXingObjC/ZXHybridBinarizer.h>
#import <ZXingObjC/ZXPerspectiveTransform.h>
#import <ZXingObjC/ZXStringUtils.h>

// ZXingObjC/datamatrix/decoder
#import <ZXingObjC/ZXDataMatrixBitMatrixParser.h>
#import <ZXingObjC/ZXDataMatrixDataBlock.h>
#import <ZXingObjC/ZXDataMatrixDecodedBitStreamParser.h>
#import <ZXingObjC/ZXDataMatrixDecoder.h>
#import <ZXingObjC/ZXDataMatrixVersion.h>

// ZXingObjC/datamatrix/detector
#import <ZXingObjC/ZXDataMatrixDetector.h>

// ZXingObjC/datamatrix
#import <ZXingObjC/ZXDataMatrixReader.h>

// ZXingObjC/maxicode/decoder
#import <ZXingObjC/ZXMaxiCodeBitMatrixParser.h>
#import <ZXingObjC/ZXMaxiCodeDecodedBitStreamParser.h>
#import <ZXingObjC/ZXMaxiCodeDecoder.h>

// ZXingObjC/maxicode
#import <ZXingObjC/ZXMaxiCodeReader.h>

// ZXingObjC/multi/qrcode/detector
#import <ZXingObjC/ZXMultiDetector.h>
#import <ZXingObjC/ZXMultiFinderPatternFinder.h>

// ZXingObjC/multi/qrcode
#import <ZXingObjC/ZXQRCodeMultiReader.h>

// ZXingObjC/multi
#import <ZXingObjC/ZXByQuadrantReader.h>
#import <ZXingObjC/ZXGenericMultipleBarcodeReader.h>
#import <ZXingObjC/ZXMultipleBarcodeReader.h>

// ZXingObjC/oned/rss/expanded/decoders
#import <ZXingObjC/ZXAbstractExpandedDecoder.h>
#import <ZXingObjC/ZXAI013103decoder.h>
#import <ZXingObjC/ZXAI01320xDecoder.h>
#import <ZXingObjC/ZXAI01392xDecoder.h>
#import <ZXingObjC/ZXAI01393xDecoder.h>
#import <ZXingObjC/ZXAI013x0x1xDecoder.h>
#import <ZXingObjC/ZXAI013x0xDecoder.h>
#import <ZXingObjC/ZXAI01AndOtherAIs.h>
#import <ZXingObjC/ZXAI01decoder.h>
#import <ZXingObjC/ZXAI01weightDecoder.h>
#import <ZXingObjC/ZXAnyAIDecoder.h>
#import <ZXingObjC/ZXBlockParsedResult.h>
#import <ZXingObjC/ZXCurrentParsingState.h>
#import <ZXingObjC/ZXDecodedChar.h>
#import <ZXingObjC/ZXDecodedInformation.h>
#import <ZXingObjC/ZXDecodedNumeric.h>
#import <ZXingObjC/ZXDecodedObject.h>
#import <ZXingObjC/ZXFieldParser.h>
#import <ZXingObjC/ZXGeneralAppIdDecoder.h>

// ZXingObjC/oned/rss/expanded
#import <ZXingObjC/ZXBitArrayBuilder.h>
#import <ZXingObjC/ZXExpandedPair.h>
#import <ZXingObjC/ZXRSSExpandedReader.h>

// ZXingObjC/oned/rss
#import <ZXingObjC/ZXAbstractRSSReader.h>
#import <ZXingObjC/ZXDataCharacter.h>
#import <ZXingObjC/ZXPair.h>
#import <ZXingObjC/ZXRSS14Reader.h>
#import <ZXingObjC/ZXRSSFinderPattern.h>
#import <ZXingObjC/ZXRSSUtils.h>

// ZXingObjC/oned
#import <ZXingObjC/ZXCodaBarReader.h>
#import <ZXingObjC/ZXCodaBarWriter.h>
#import <ZXingObjC/ZXCode128Reader.h>
#import <ZXingObjC/ZXCode128Writer.h>
#import <ZXingObjC/ZXCode39Reader.h>
#import <ZXingObjC/ZXCode39Writer.h>
#import <ZXingObjC/ZXCode93Reader.h>
#import <ZXingObjC/ZXEAN13Reader.h>
#import <ZXingObjC/ZXEAN13Writer.h>
#import <ZXingObjC/ZXEAN8Reader.h>
#import <ZXingObjC/ZXEAN8Writer.h>
#import <ZXingObjC/ZXEANManufacturerOrgSupport.h>
#import <ZXingObjC/ZXITFReader.h>
#import <ZXingObjC/ZXITFWriter.h>
#import <ZXingObjC/ZXMultiFormatOneDReader.h>
#import <ZXingObjC/ZXMultiFormatUPCEANReader.h>
#import <ZXingObjC/ZXOneDimensionalCodeWriter.h>
#import <ZXingObjC/ZXOneDReader.h>
#import <ZXingObjC/ZXUPCAReader.h>
#import <ZXingObjC/ZXUPCAWriter.h>
#import <ZXingObjC/ZXUPCEANExtension2Support.h>
#import <ZXingObjC/ZXUPCEANExtension5Support.h>
#import <ZXingObjC/ZXUPCEANExtensionSupport.h>
#import <ZXingObjC/ZXUPCEANReader.h>
#import <ZXingObjC/ZXUPCEANWriter.h>
#import <ZXingObjC/ZXUPCEReader.h>

// ZXingObjC/pdf417/decoder/ec
#import <ZXingObjC/ZXModulusGF.h>
#import <ZXingObjC/ZXModulusPoly.h>
#import <ZXingObjC/ZXPDF417ECErrorCorrection.h>

// ZXingObjC/pdf417/decoder
#import <ZXingObjC/ZXPDF417BitMatrixParser.h>
#import <ZXingObjC/ZXPDF417DecodedBitStreamParser.h>
#import <ZXingObjC/ZXPDF417Decoder.h>

// ZXingObjC/pdf417/detector
#import <ZXingObjC/ZXPDF417Detector.h>

// ZXingObjC/pdf417/encoder
#import <ZXingObjC/ZXBarcodeMatrix.h>
#import <ZXingObjC/ZXBarcodeRow.h>
#import <ZXingObjC/ZXCompaction.h>
#import <ZXingObjC/ZXDimensions.h>
#import <ZXingObjC/ZXPDF417.h>
#import <ZXingObjC/ZXPDF417ErrorCorrection.h>
#import <ZXingObjC/ZXPDF417HighLevelEncoder.h>
#import <ZXingObjC/ZXPDF417Writer.h>

// ZXingObjC/pdf417
#import <ZXingObjC/ZXPDF417Reader.h>

// ZXingObjC/qrcode/decoder
#import <ZXingObjC/ZXDataMask.h>
#import <ZXingObjC/ZXErrorCorrectionLevel.h>
#import <ZXingObjC/ZXFormatInformation.h>
#import <ZXingObjC/ZXMode.h>
#import <ZXingObjC/ZXQRCodeBitMatrixParser.h>
#import <ZXingObjC/ZXQRCodeDataBlock.h>
#import <ZXingObjC/ZXQRCodeDecodedBitStreamParser.h>
#import <ZXingObjC/ZXQRCodeDecoder.h>
#import <ZXingObjC/ZXQRCodeVersion.h>

// ZXingObjC/qrcode/detector
#import <ZXingObjC/ZXAlignmentPattern.h>
#import <ZXingObjC/ZXAlignmentPatternFinder.h>
#import <ZXingObjC/ZXFinderPatternFinder.h>
#import <ZXingObjC/ZXFinderPatternInfo.h>
#import <ZXingObjC/ZXQRCodeDetector.h>
#import <ZXingObjC/ZXQRCodeFinderPattern.h>

// ZXingObjC/qrcode/encoder
#import <ZXingObjC/ZXBlockPair.h>
#import <ZXingObjC/ZXByteMatrix.h>
#import <ZXingObjC/ZXEncoder.h>
#import <ZXingObjC/ZXMaskUtil.h>
#import <ZXingObjC/ZXMatrixUtil.h>
#import <ZXingObjC/ZXQRCode.h>

// ZXingObjC/qrcode
#import <ZXingObjC/ZXQRCodeReader.h>
#import <ZXingObjC/ZXQRCodeWriter.h>

// ZXingObjC
#import <ZXingObjC/ZXBarcodeFormat.h>
#import <ZXingObjC/ZXBinarizer.h>
#import <ZXingObjC/ZXBinaryBitmap.h>
#import <ZXingObjC/ZXDecodeHints.h>
#import <ZXingObjC/ZXEncodeHints.h>
#import <ZXingObjC/ZXErrors.h>
#import <ZXingObjC/ZXLuminanceSource.h>
#import <ZXingObjC/ZXMultiFormatReader.h>
#import <ZXingObjC/ZXMultiFormatWriter.h>
#import <ZXingObjC/ZXReader.h>
#import <ZXingObjC/ZXResult.h>
#import <ZXingObjC/ZXResultMetadataType.h>
#import <ZXingObjC/ZXResultPoint.h>
#import <ZXingObjC/ZXResultPointCallback.h>
#import <ZXingObjC/ZXWriter.h>
#import <ZXingObjC/ZXingObjC.h>
