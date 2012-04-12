/**
 * <p>This class attempts to find alignment patterns in a QR Code. Alignment patterns look like finder
 * patterns but are smaller and appear at regular intervals throughout the image.</p>
 * 
 * <p>At the moment this only looks for the bottom-right alignment pattern.</p>
 * 
 * <p>This is mostly a simplified copy of {@link FinderPatternFinder}. It is copied,
 * pasted and stripped down here for maximum performance but does unfortunately duplicate
 * some code.</p>
 * 
 * <p>This class is thread-safe but not reentrant. Each thread must allocate its own object.
 * 
 * @author Sean Owen
 */

@class ZXAlignmentPattern, ZXBitMatrix;
@protocol ZXResultPointCallback;

@interface ZXAlignmentPatternFinder : NSObject {
  ZXBitMatrix * image;
  NSMutableArray * possibleCenters;
  int startX;
  int startY;
  int width;
  int height;
  float moduleSize;
  int * crossCheckStateCount;
  id <ZXResultPointCallback> resultPointCallback;
}

- (id) initWithImage:(ZXBitMatrix *)image startX:(int)startX startY:(int)startY width:(int)width height:(int)height moduleSize:(float)moduleSize resultPointCallback:(id <ZXResultPointCallback>)resultPointCallback;
- (ZXAlignmentPattern *) find;

@end
