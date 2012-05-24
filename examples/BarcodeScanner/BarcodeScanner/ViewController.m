/*
 * Copyright 2011 ZXing authors
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
#import "ZXCapture.h"
#import "ZXResult.h"

@interface ViewController ()

@property (nonatomic, retain) ZXCapture* capture;
@property (nonatomic, retain) IBOutlet UILabel* decodedLabel;

@end


@implementation ViewController

@synthesize capture;
@synthesize decodedLabel;

#pragma mark - Creation/Deletion Methods

- (void)dealloc {
  [capture release];
  [decodedLabel release];

  [super dealloc];
}

#pragma mark - View Controller Methods

- (void)viewDidLoad {
  [super viewDidLoad];

  self.capture = [[[ZXCapture alloc] init] autorelease];
  self.capture.delegate = self;
  self.capture.camera = self.capture.back;

  self.capture.layer.frame = self.view.frame;
  [self.view.layer addSublayer:self.capture.layer];
  [self.view bringSubviewToFront:self.decodedLabel];

  [self.capture start];
}

- (void)viewDidUnload {
  [super viewDidUnload];

  [self.capture stop];
  self.decodedLabel = nil;
}

#pragma mark - ZXCaptureDelegate Methods

- (void)captureResult:(ZXCapture*)capture result:(ZXResult*)result {
  if (result) {
    // We got a result. Display information about the result onscreen.
    [self.decodedLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"Scanned:\n%@", result.text] waitUntilDone:YES];
  }
}

- (void)captureSize:(ZXCapture*)capture width:(NSNumber*)width height:(NSNumber*)height {  
}

@end
