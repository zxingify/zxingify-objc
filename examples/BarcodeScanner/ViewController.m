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

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) ZXCapture* capture;
@property (nonatomic, weak) IBOutlet UILabel* decodedLabel;

@end

@implementation ViewController

#pragma mark - View Controller Methods

- (void)viewDidLoad {
  [super viewDidLoad];

  self.capture = [[ZXCapture alloc] init];
  self.capture.rotation = 90.0f;

  // Use the back camera
  self.capture.camera = self.capture.back;

  self.capture.layer.frame = self.view.bounds;
  [self.view.layer addSublayer:self.capture.layer];
  [self.view bringSubviewToFront:self.decodedLabel];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.capture.delegate = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return toInterfaceOrientation == UIInterfaceOrientationPortrait;
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

#pragma mark - ZXCaptureDelegate Methods

- (void)captureResult:(ZXCapture*)capture result:(ZXResult*)result {
  if (result) {
    // We got a result. Display information about the result onscreen.
    [self.decodedLabel performSelectorOnMainThread:@selector(setText:) withObject:[self displayForResult:result] waitUntilDone:YES];

    // Vibrate
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  }
}

- (void)captureSize:(ZXCapture*)capture width:(NSNumber*)width height:(NSNumber*)height {
}

@end
