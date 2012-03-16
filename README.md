ZXingObjC
=========

ZXingObjC is a full Objective-C port of [ZXing](http://code.google.com/p/zxing/) ("Zebra Crossing"), a Java barcode image processing library.

It should be noted that although all barcodes supported by ZXing are also supported by ZXingObjC, only the QR code encoding has been well tested. However, this project should provide a good starting point for anyone looking to work with the other barcode formats.

TODO
----

* Use NSError for error handling rather than exceptions
* Port unit tests to Objective-C as well