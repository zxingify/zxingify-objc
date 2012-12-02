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

#import <ZXingObjC/ZXingObjC.h>
#import "ViewController.h"

@implementation ViewController

@synthesize imageView;
@synthesize textView;

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.imageView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // Default qr data
  self.textView.text = @"http://code.google.com/p/zxing/";
  [self updatePressed:nil];
}

- (void)dealloc {
  [imageView release];
  [textView release];

  [super dealloc];
}

#pragma mark - Events

- (IBAction)updatePressed:(id)sender {
  NSString *data = self.textView.text;
  if (data && ![data isEqualToString:@""]) {
    [self.textView resignFirstResponder];

    ZXMultiFormatWriter* writer = [[ZXMultiFormatWriter alloc] init];
    ZXBitMatrix* result = [writer encode:data format:kBarcodeFormatQRCode width:self.imageView.frame.size.width height:self.imageView.frame.size.width error:nil];
    if (result) {
      self.imageView.image = [UIImage imageWithCGImage:[ZXImage imageWithMatrix:result].cgimage];
    } else {
      self.imageView.image = nil;
    }
  }
}

@end
