/**
 * <p>Encapsulates information about finder patterns in an image, including the location of
 * the three finder patterns, and their estimated module size.</p>
 * 
 * @author Sean Owen
 */

@class QRCodeFinderPattern;

@interface FinderPatternInfo : NSObject {
  QRCodeFinderPattern * bottomLeft;
  QRCodeFinderPattern * topLeft;
  QRCodeFinderPattern * topRight;
}

@property(nonatomic, retain, readonly) QRCodeFinderPattern * bottomLeft;
@property(nonatomic, retain, readonly) QRCodeFinderPattern * topLeft;
@property(nonatomic, retain, readonly) QRCodeFinderPattern * topRight;

- (id) initWithPatternCenters:(NSArray *)patternCenters;

@end
