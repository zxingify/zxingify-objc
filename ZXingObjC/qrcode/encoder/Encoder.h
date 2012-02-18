/**
 * @author satorux@google.com (Satoru Takabayashi) - creator
 * @author dswitkin@google.com (Daniel Switkin) - ported from C++
 */

@class BitArray, ErrorCorrectionLevel, Mode, QRCode;

@interface Encoder : NSObject

+ (void) encode:(NSString *)content ecLevel:(ErrorCorrectionLevel *)ecLevel qrCode:(QRCode *)qrCode;
+ (void) encode:(NSString *)content ecLevel:(ErrorCorrectionLevel *)ecLevel hints:(NSMutableDictionary *)hints qrCode:(QRCode *)qrCode;
+ (int) alphanumericCode:(int)code;
+ (Mode *) chooseMode:(NSString *)content;
+ (Mode *) chooseMode:(NSString *)content encoding:(NSString *)encoding;
+ (void) terminateBits:(int)numDataBytes bits:(BitArray *)bits;
+ (void) getNumDataBytesAndNumECBytesForBlockID:(int)numTotalBytes numDataBytes:(int)numDataBytes numRSBlocks:(int)numRSBlocks blockID:(int)blockID numDataBytesInBlock:(NSMutableArray *)numDataBytesInBlock numECBytesInBlock:(NSMutableArray *)numECBytesInBlock;
+ (void) interleaveWithECBytes:(BitArray *)bits numTotalBytes:(int)numTotalBytes numDataBytes:(int)numDataBytes numRSBlocks:(int)numRSBlocks result:(BitArray *)result;
+ (char *) generateECBytes:(char *)dataBytes numEcBytesInBlock:(int)numEcBytesInBlock;
+ (void) appendModeInfo:(Mode *)mode bits:(BitArray *)bits;
+ (void) appendLengthInfo:(int)numLetters version:(int)version mode:(Mode *)mode bits:(BitArray *)bits;
+ (void) appendBytes:(NSString *)content mode:(Mode *)mode bits:(BitArray *)bits encoding:(NSString*)encoding;
+ (void) appendNumericBytes:(NSString *)content bits:(BitArray *)bits;
+ (void) appendAlphanumericBytes:(NSString *)content bits:(BitArray *)bits;
+ (void) append8BitBytes:(NSString *)content bits:(BitArray *)bits encoding:(NSString *)encoding;
+ (void) appendKanjiBytes:(NSString *)content bits:(BitArray *)bits;

@end
