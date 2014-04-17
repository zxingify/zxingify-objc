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
#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) ZXCapture *capture;
@property (nonatomic, weak) IBOutlet UIView *scanRectView;
@property (nonatomic, weak) IBOutlet UILabel *decodedLabel;

@end

@implementation ViewController

#pragma mark - View Controller Methods

- (void)viewDidLoad {
  [super viewDidLoad];

  self.capture = [[ZXCapture alloc] init];
  self.capture.camera = self.capture.back;
  self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
  self.capture.rotation = 90.0f;

  self.capture.layer.frame = self.view.bounds;
  [self.view.layer addSublayer:self.capture.layer];

  [self.view bringSubviewToFront:self.scanRectView];
  [self.view bringSubviewToFront:self.decodedLabel];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.capture.delegate = self;
  self.capture.layer.frame = self.view.bounds;

  CGAffineTransform captureSizeTransform = CGAffineTransformMakeScale(320 / self.view.frame.size.width, 480 / self.view.frame.size.height);
  self.capture.scanRect = CGRectApplyAffineTransform(self.scanRectView.frame, captureSizeTransform);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - Private Methods

- (NSString *)barcodeFormatToString:(ZXBarcodeFormat)format {
  switch (format) {
    case kBarcodeFormatAztec:
      return @"Aztec";

    case kBarcodeFormatCodabar:
      return @"CODABAR";

    case kBarcodeFormatCode39:
      return @"Code 39";

    case kBarcodeFormatCode93:
      return @"Code 93";

    case kBarcodeFormatCode128:
      return @"Code 128";

    case kBarcodeFormatDataMatrix:
      return @"Data Matrix";

    case kBarcodeFormatEan8:
      return @"EAN-8";

    case kBarcodeFormatEan13:
      return @"EAN-13";

    case kBarcodeFormatITF:
      return @"ITF";

    case kBarcodeFormatPDF417:
      return @"PDF417";

    case kBarcodeFormatQRCode:
      return @"QR Code";

    case kBarcodeFormatRSS14:
      return @"RSS 14";

    case kBarcodeFormatRSSExpanded:
      return @"RSS Expanded";

    case kBarcodeFormatUPCA:
      return @"UPCA";

    case kBarcodeFormatUPCE:
      return @"UPCE";

    case kBarcodeFormatUPCEANExtension:
      return @"UPC/EAN extension";

    default:
      return @"Unknown";
  }
}

#pragma mark - ZXCaptureDelegate Methods

- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
  if (!result) return;

  // We got a result. Display information about the result onscreen.
  NSString *formatString = [self barcodeFormatToString:result.barcodeFormat];
  NSString *display = [NSString stringWithFormat:@"Scanned!\n\nFormat: %@\n\nContents:\n%@", formatString, result.text];
  [self.decodedLabel performSelectorOnMainThread:@selector(setText:) withObject:display waitUntilDone:YES];

  // Vibrate
  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
