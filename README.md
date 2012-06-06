ZXingObjC
=========

ZXingObjC is a full Objective-C port of [ZXing](http://code.google.com/p/zxing/) ("Zebra Crossing"), a Java barcode image processing library. It is designed to be used on both iOS devices and in Mac applications.

The following barcodes are currently supported for both encoding and decoding:

* UPC-A and UPC-E
* EAN-8 and EAN-13
* Code 39
* Code 93
* Code 128
* ITF
* Codabar
* RSS-14 (all variants)
* QR Code
* Data Matrix
* Aztec ('beta' quality)
* PDF 417 ('alpha' quality)

ZXingObjC currently has feature parity with ZXing version 2.0.

Usage
----

Encoding:

```objc
NSError* error = nil;
ZXMultiFormatWriter* writer = [ZXMultiFormatWriter writer];
ZXBitMatrix* result = [writer encode:@"A string to encode"
                              format:kBarcodeFormatQRCode
                               width:500
                              height:500
                               error:&error];
if (result) {
  CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage];

  // This CGImageRef image can be placed in a UIImage, NSImage, or written to a file.
} else {
  NSString* errorMessage = [error localizedDescription];
}
```

Decoding:

```objc
CGImageRef imageToDecode;  // Given a CGImage in which we are looking for barcodes

ZXLuminanceSource* source = [[[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode] autorelease];
ZXBinaryBitmap* bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];

NSError* error = nil;

// There are a number of hints we can give to the reader, including
// possible formats, allowed lengths, and the string encoding.
ZXDecodeHints* hints = [ZXDecodeHints hints];

ZXMultiFormatReader* reader = [ZXMultiFormatReader reader];
ZXResult* result = [reader decode:bitmap
                            hints:hints
                            error:&error];
if (result) {
  // The coded result as a string. The raw data can be accessed with
  // result.rawBytes and result.length.
  NSString* contents = result.text;

  // The barcode format, such as a QR code or UPC-A
  ZXBarcodeFormat format = result.barcodeFormat;
} else {
  // Use error to determine why we didn't get a result, such as a barcode
  // not being found, an invalid checksum, or a format inconsistency.
}
```

Examples
--------

ZXingObjC includes several example applications found in "examples" folder:

* BarcodeScanner - An iOS application that captures video from the camera, scans for barcodes and displays results on screen.
* QrCodeTest - A basic QR code generator that accepts input, encodes it as a QR code, and displays it on screen.

Getting Started
---------------

To add ZXingObjC to your project:

1. [Download ZXingObjC](https://github.com/TheLevelUp/ZXingObjC/tarball/master) or clone it from git: `git clone git://github.com/TheLevelUp/ZXingObjC.git`.

2. There are two ways to add ZXingObjC to your project, either as a static library dependency, or adding the files directly to the project.
    * As a static library:
        1. First drag the ZXingObjC.xcodeproj file into Xcode. Make sure "Copy items" is unchecked and "Reference Type" is "Relative to Project" before clicking "Add".
        2. Next, you must add the static library itself as a dependency. You can do this by selecting your project in the left sidebar, select your target, and choose the "Build Phases" tab. Under "Target Dependencies", click the plus button, and then choose either ZXingObjC-iOS for an iOS app, or ZXingObjC-osx for a Mac app.
        3. Now we need to tell XCode where to find the header files for ZXingObjC. While your target is still selected, choose the "Build Settings" tab. Look for "Header Search Paths" under "Search Paths", and add the relative path from your project's directory to the ZXingObjC folder.
    * To add the files directly, just drag the ZXingObjC folder into Xcode. You may choose to copy the files into your project folder, or reference them from the downloaded location.

3. In the "Build Phases" tab, we need to add the following frameworks under "Link Binary With Libraries":
    * ImageIO.framework
    * CoreGraphics.framework
    * If you added ZXingObjC as a static library, also add libZXingObjC-iOS.a (for iOS apps) or libZXingObjC-osx.a (for Mac apps)

License
-------

ZXingObjC is available under the [Apache 2.0 license](http://www.apache.org/licenses/LICENSE-2.0.html).
