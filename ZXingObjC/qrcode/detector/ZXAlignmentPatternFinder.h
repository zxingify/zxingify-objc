/**
 * This class attempts to find alignment patterns in a QR Code. Alignment patterns look like finder
 * patterns but are smaller and appear at regular intervals throughout the image.
 * 
 * At the moment this only looks for the bottom-right alignment pattern.
 * 
 * This is mostly a simplified copy of {@link FinderPatternFinder}. It is copied,
 * pasted and stripped down here for maximum performance but does unfortunately duplicate
 * some code.
 * 
 * This class is thread-safe but not reentrant. Each thread must allocate its own object.
 */

@class ZXAlignmentPattern, ZXBitMatrix;
@protocol ZXResultPointCallback;

@interface ZXAlignmentPatternFinder : NSObject

- (id)initWithImage:(ZXBitMatrix *)image startX:(int)startX startY:(int)startY width:(int)width height:(int)height moduleSize:(float)moduleSize resultPointCallback:(id <ZXResultPointCallback>)resultPointCallback;
- (ZXAlignmentPattern *)find;

@end
