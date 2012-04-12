#import "ViewController.h"
#import "ZXBarcodeFormat.h"
#import "ZXBitMatrix.h"
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
  [self.textView resignFirstResponder];

  self.imageView.image = nil;

  ZXMultiFormatWriter* writer = [[ZXMultiFormatWriter alloc] init];
  ZXBitMatrix* result = [writer encode:data format:kBarcodeFormatQRCode width:self.imageView.frame.size.width height:self.imageView.frame.size.width];

  int width = result.width;
  int height = result.height;
  unsigned char *bytes = (unsigned char *)malloc(width * height * 4);
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      BOOL bit = [result get:x y:y];
      unsigned char intensity = bit ? 0 : 255;
      for(int i = 0; i < 3; i++) {
        bytes[y * width * 4 + x * 4 + i] = intensity;
      }
      bytes[y * width * 4 + x * 4 + 3] = 255;
    }
  }

  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef c = CGBitmapContextCreate(bytes, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast);
  CFRelease(colorSpace);
  CGImageRef image = CGBitmapContextCreateImage(c);
  CFRelease(c);
  UIImage *image2 = [UIImage imageWithCGImage:image];
  CFRelease(image);

  free(bytes);
  self.imageView.image = image2;

  [writer release];
}

@end
