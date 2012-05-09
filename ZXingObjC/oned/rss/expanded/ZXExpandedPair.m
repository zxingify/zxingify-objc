#import "ZXExpandedPair.h"
#import "ZXDataCharacter.h"
#import "ZXRSSFinderPattern.h"

@interface ZXExpandedPair ()

@property (nonatomic, retain) ZXDataCharacter * leftChar;
@property (nonatomic, retain) ZXDataCharacter * rightChar;
@property (nonatomic, retain) ZXRSSFinderPattern * finderPattern;
@property (nonatomic, assign) BOOL mayBeLast;

@end

@implementation ZXExpandedPair

@synthesize finderPattern;
@synthesize leftChar;
@synthesize mayBeLast;
@synthesize rightChar;

- (id)initWithLeftChar:(ZXDataCharacter *)aLeftChar rightChar:(ZXDataCharacter *)aRightChar
         finderPattern:(ZXRSSFinderPattern *)aFinderPattern mayBeLast:(BOOL)aMayBeLast {
  if (self = [super init]) {
    self.leftChar = aLeftChar;
    self.rightChar = aRightChar;
    self.finderPattern = aFinderPattern;
    mayBeLast = aMayBeLast;
  }

  return self;
}

- (void)dealloc {
  [leftChar release];
  [rightChar release];
  [finderPattern release];

  [super dealloc];
}

- (BOOL)mustBeLast {
  return self.rightChar == nil;
}

@end
