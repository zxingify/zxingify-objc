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

#import "ViewController.h"

@implementation ViewController

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.textView.text = @"http://github.com/TheLevelUp/ZXingObjC";
  [self updatePressed:nil];
}

#pragma mark - Events

- (IBAction)updatePressed:(id)sender {
  [self.textView resignFirstResponder];

  NSString *data = self.textView.text;
  if (data == 0) return;

  ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
  ZXBitMatrix *result = [writer encode:data
                                format:kBarcodeFormatQRCode
                                 width:self.imageView.frame.size.width
                                height:self.imageView.frame.size.width
                                 error:nil];

  if (result) {
    ZXImage *image = [ZXImage imageWithMatrix:result];
    self.imageView.image = [UIImage imageWithCGImage:image.cgimage];
  } else {
    self.imageView.image = nil;
  }
}

@end
