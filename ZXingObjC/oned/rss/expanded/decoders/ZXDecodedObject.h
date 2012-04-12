/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */

@interface ZXDecodedObject : NSObject {
  int theNewPosition;
}

@property (nonatomic, readonly) int theNewPosition;

- (id) initWithNewPosition:(int)newPosition;

@end
