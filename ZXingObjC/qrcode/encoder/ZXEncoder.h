/**
 * @author satorux@google.com (Satoru Takabayashi) - creator
 * @author dswitkin@google.com (Daniel Switkin) - ported from C++
 */

@class ZXBitArray, ZXEncodeHints, ZXErrorCorrectionLevel, ZXMode, ZXQRCode;

@interface ZXEncoder : NSObject

+ (void) encode:(NSString *)content ecLevel:(ZXErrorCorrectionLevel *)ecLevel qrCode:(ZXQRCode *)qrCode;
+ (void) encode:(NSString *)content ecLevel:(ZXErrorCorrectionLevel *)ecLevel hints:(ZXEncodeHints *)hints qrCode:(ZXQRCode *)qrCode;
+ (int) alphanumericCode:(int)code;
+ (ZXMode *) chooseMode:(NSString *)content;
+ (ZXMode *) chooseMode:(NSString *)content encoding:(NSStringEncoding)encoding;
+ (void) terminateBits:(int)numDataBytes bits:(ZXBitArray *)bits;
+ (void) getNumDataBytesAndNumECBytesForBlockID:(int)numTotalBytes numDataBytes:(int)numDataBytes numRSBlocks:(int)numRSBlocks blockID:(int)blockID numDataBytesInBlock:(int[])numDataBytesInBlock numECBytesInBlock:(int[])numECBytesInBlock;
+ (void) interleaveWithECBytes:(ZXBitArray *)bits numTotalBytes:(int)numTotalBytes numDataBytes:(int)numDataBytes numRSBlocks:(int)numRSBlocks result:(ZXBitArray *)result;
+ (unsigned char *) generateECBytes:(unsigned char *)dataBytes numDataBytes:(int)numDataBytes numEcBytesInBlock:(int)numEcBytesInBlock;
+ (void) appendModeInfo:(ZXMode *)mode bits:(ZXBitArray *)bits;
+ (void) appendLengthInfo:(int)numLetters version:(int)version mode:(ZXMode *)mode bits:(ZXBitArray *)bits;
+ (void) appendBytes:(NSString *)content mode:(ZXMode *)mode bits:(ZXBitArray *)bits encoding:(NSStringEncoding)encoding;
+ (void) appendNumericBytes:(NSString *)content bits:(ZXBitArray *)bits;
+ (void) appendAlphanumericBytes:(NSString *)content bits:(ZXBitArray *)bits;
+ (void) append8BitBytes:(NSString *)content bits:(ZXBitArray *)bits encoding:(NSStringEncoding)encoding;
+ (void) appendKanjiBytes:(NSString *)content bits:(ZXBitArray *)bits;

@end
