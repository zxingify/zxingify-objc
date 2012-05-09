#import "ZXBlockParsedResult.h"
#import "ZXDecodedInformation.h"

@interface ZXBlockParsedResult ()

@property (nonatomic, retain) ZXDecodedInformation * decodedInformation;
@property (nonatomic, assign) BOOL finished;

@end

@implementation ZXBlockParsedResult

@synthesize decodedInformation;
@synthesize finished;

- (id)initWithFinished:(BOOL)isFinished {
  return [self initWithInformation:nil finished:isFinished];
}

- (id)initWithInformation:(ZXDecodedInformation *)information finished:(BOOL)isFinished {
  if (self = [super init]) {
    self.decodedInformation = information;
    self.finished = isFinished;
  }

  return self;
}

- (void)dealloc {
  [decodedInformation release];

  [super dealloc];
}

@end
