/*
 * Copyright 2014 ZXing authors
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

#import "BarcodeScannerDocument.h"

@interface BarcodeScannerDocument ()

@property (nonatomic, strong) ZXCapture *capture;

@end

@implementation BarcodeScannerDocument

#pragma mark - NSDocument Methods

- (NSString *)windowNibName {
	return @"BarcodeScannerDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)controller {
  [super windowControllerDidLoadNib:controller];

  self.capture = [[ZXCapture alloc] init];
  self.capture.rotation = 90.0f;

  self.capture.layer.frame = self.previewView.bounds;
  [self.previewView.layer addSublayer:self.capture.layer];

  self.capture.delegate = self;
}

#pragma mark - ZXCaptureDelegate Methods

- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
  if (result) {
    NSLog(@"%@", [self displayForResult:result]);
  }
}

#pragma mark - Private Methods

- (NSString*)displayForResult:(ZXResult*)result {
  NSString *formatString;
  switch (result.barcodeFormat) {
    case kBarcodeFormatAztec:
      formatString = @"Aztec";
      break;

    case kBarcodeFormatCodabar:
      formatString = @"CODABAR";
      break;

    case kBarcodeFormatCode39:
      formatString = @"Code 39";
      break;

    case kBarcodeFormatCode93:
      formatString = @"Code 93";
      break;

    case kBarcodeFormatCode128:
      formatString = @"Code 128";
      break;

    case kBarcodeFormatDataMatrix:
      formatString = @"Data Matrix";
      break;

    case kBarcodeFormatEan8:
      formatString = @"EAN-8";
      break;

    case kBarcodeFormatEan13:
      formatString = @"EAN-13";
      break;

    case kBarcodeFormatITF:
      formatString = @"ITF";
      break;

    case kBarcodeFormatPDF417:
      formatString = @"PDF417";
      break;

    case kBarcodeFormatQRCode:
      formatString = @"QR Code";
      break;

    case kBarcodeFormatRSS14:
      formatString = @"RSS 14";
      break;

    case kBarcodeFormatRSSExpanded:
      formatString = @"RSS Expanded";
      break;

    case kBarcodeFormatUPCA:
      formatString = @"UPCA";
      break;

    case kBarcodeFormatUPCE:
      formatString = @"UPCE";
      break;

    case kBarcodeFormatUPCEANExtension:
      formatString = @"UPC/EAN extension";
      break;

    default:
      formatString = @"Unknown";
      break;
  }

  return [NSString stringWithFormat:@"Scanned!\n\nFormat: %@\n\nContents:\n%@", formatString, result.text];
}

@end
