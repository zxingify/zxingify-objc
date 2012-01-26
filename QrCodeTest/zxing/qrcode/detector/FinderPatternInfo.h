
/**
 * <p>Encapsulates information about finder patterns in an image, including the location of
 * the three finder patterns, and their estimated module size.</p>
 * 
 * @author Sean Owen
 */

@interface FinderPatternInfo : NSObject {
  FinderPattern * bottomLeft;
  FinderPattern * topLeft;
  FinderPattern * topRight;
}

@property(nonatomic, retain, readonly) FinderPattern * bottomLeft;
@property(nonatomic, retain, readonly) FinderPattern * topLeft;
@property(nonatomic, retain, readonly) FinderPattern * topRight;
- (id) initWithPatternCenters:(NSArray *)patternCenters;
@end
