#import "BarcodeFormat.h"
#import "BitMatrix.h"
#import "MultiFormatWriter.h"
#import "ViewController.h"

@implementation ViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // Try to create a basic QR code
  NSString* data = @"http://code.google.com/p/zxing/";
  MultiFormatWriter* writer = [[MultiFormatWriter alloc] init];
  BitMatrix* result = [writer encode:data format:kBarcodeQRCode width:300 height:300];
}

@end
