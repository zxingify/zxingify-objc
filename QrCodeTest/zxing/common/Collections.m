#import "Collections.h"

@implementation Collections

- (id) init {
  if (self = [super init]) {
  }
  return self;
}


/**
 * Sorts its argument (destructively) using insert sort; in the context of this package
 * insertion sort is simple and efficient given its relatively small inputs.
 * 
 * @param vector vector to sort
 * @param comparator comparator to define sort ordering
 */
+ (void) insertionSort:(NSMutableArray *)vector comparator:(Comparator *)comparator {
  int max = [vector count];

  for (int i = 1; i < max; i++) {
    NSObject * value = [vector objectAtIndex:i];
    int j = i - 1;
    NSObject * valueB;

    while (j >= 0 && [comparator compare:(valueB = [vector objectAtIndex:j]) param1:value] > 0) {
      [vector setObjectAtIndex:valueB param1:j + 1];
      j--;
    }

    [vector setObjectAtIndex:value param1:j + 1];
  }

}

@end
