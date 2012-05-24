#import "ViewController.h"
#import "ZXBarcodeFormat.h"
#import "ZXBitMatrix.h"
#import "ZXImage.h"
#import "ZXMultiFormatWriter.h"

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
