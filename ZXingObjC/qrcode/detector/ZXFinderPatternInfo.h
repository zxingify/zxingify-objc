/**
 * <p>Encapsulates information about finder patterns in an image, including the location of
 * the three finder patterns, and their estimated module size.</p>
 * 
 * @author Sean Owen
 */

@class ZXQRCodeFinderPattern;

@interface ZXFinderPatternInfo : NSObject {
  ZXQRCodeFinderPattern * bottomLeft;
  ZXQRCodeFinderPattern * topLeft;
  ZXQRCodeFinderPattern * topRight;
}

@property(nonatomic, retain, readonly) ZXQRCodeFinderPattern * bottomLeft;
@property(nonatomic, retain, readonly) ZXQRCodeFinderPattern * topLeft;
@property(nonatomic, retain, readonly) ZXQRCodeFinderPattern * topRight;

- (id) initWithPatternCenters:(NSArray *)patternCenters;

@end
