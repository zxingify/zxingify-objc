
/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */

@interface DecodedObject : NSObject {
  int newPosition;
}

- (id) initWithNewPosition:(int)newPosition;
- (int) getNewPosition;
@end
