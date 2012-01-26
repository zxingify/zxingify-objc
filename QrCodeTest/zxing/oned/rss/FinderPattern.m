#import "FinderPattern.h"

@implementation FinderPattern

@synthesize value;
@synthesize startEnd;
@synthesize resultPoints;

- (id) init:(int)value startEnd:(NSArray *)startEnd start:(int)start end:(int)end rowNumber:(int)rowNumber {
  if (self = [super init]) {
    value = value;
    startEnd = startEnd;
    resultPoints = [NSArray arrayWithObjects:[[[ResultPoint alloc] init:(float)start param1:(float)rowNumber] autorelease], [[[ResultPoint alloc] init:(float)end param1:(float)rowNumber] autorelease], nil];
  }
  return self;
}

- (void) dealloc {
  [startEnd release];
  [resultPoints release];
  [super dealloc];
}

@end
