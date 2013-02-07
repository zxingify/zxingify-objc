/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXMathUtils.h"
#import "ZXResultPoint.h"

@interface ZXResultPoint ()

@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;

+ (float)crossProductZ:(ZXResultPoint *)pointA pointB:(ZXResultPoint *)pointB pointC:(ZXResultPoint *)pointC;

@end

@implementation ZXResultPoint

@synthesize x;
@synthesize y;

- (id)initWithX:(float)anX y:(float)aY {
  if (self = [super init]) {
    self.x = anX;
    self.y = aY;
  }

  return self;
}

+ (id)resultPointWithX:(float)x y:(float)y {
  return [[[self alloc] initWithX:x y:y] autorelease];
}

- (id)copyWithZone:(NSZone *)zone {
  return [[ZXResultPoint allocWithZone:zone] initWithX:x y:y];
}

- (BOOL)isEqual:(id)other {
  if ([other isKindOfClass:[ZXResultPoint class]]) {
    ZXResultPoint *otherPoint = (ZXResultPoint *)other;
    return self.x == otherPoint.x && self.y == otherPoint.y;
  }
  return NO;
}

- (NSUInteger)hash {
  return 31 * *((int *)(&x)) + *((int *)(&y));
}

- (NSString *)description {
  return [NSString stringWithFormat:@"(%f,%f)", self.x, self.y];
}


/**
 * Orders an array of three ResultPoints in an order [A,B,C] such that AB < AC and
 * BC < AC and the angle between BC and BA is less than 180 degrees.
 */
+ (void)orderBestPatterns:(NSMutableArray *)patterns {
  float zeroOneDistance = [self distance:[patterns objectAtIndex:0] pattern2:[patterns objectAtIndex:1]];
  float oneTwoDistance = [self distance:[patterns objectAtIndex:1] pattern2:[patterns objectAtIndex:2]];
  float zeroTwoDistance = [self distance:[patterns objectAtIndex:0] pattern2:[patterns objectAtIndex:2]];
  ZXResultPoint *pointA;
  ZXResultPoint *pointB;
  ZXResultPoint *pointC;
  if (oneTwoDistance >= zeroOneDistance && oneTwoDistance >= zeroTwoDistance) {
    pointB = [patterns objectAtIndex:0];
    pointA = [patterns objectAtIndex:1];
    pointC = [patterns objectAtIndex:2];
  } else if (zeroTwoDistance >= oneTwoDistance && zeroTwoDistance >= zeroOneDistance) {
    pointB = [patterns objectAtIndex:1];
    pointA = [patterns objectAtIndex:0];
    pointC = [patterns objectAtIndex:2];
  } else {
    pointB = [patterns objectAtIndex:2];
    pointA = [patterns objectAtIndex:0];
    pointC = [patterns objectAtIndex:1];
  }

  if ([self crossProductZ:pointA pointB:pointB pointC:pointC] < 0.0f) {
    ZXResultPoint *temp = pointA;
    pointA = pointC;
    pointC = temp;
  }
  [patterns replaceObjectAtIndex:0 withObject:pointA];
  [patterns replaceObjectAtIndex:1 withObject:pointB];
  [patterns replaceObjectAtIndex:2 withObject:pointC];
}


/**
 * Returns distance between two points
 */
+ (float)distance:(ZXResultPoint *)pattern1 pattern2:(ZXResultPoint *)pattern2 {
  return [ZXMathUtils distance:pattern1.x aY:pattern1.y bX:pattern2.x bY:pattern2.y];
}


/**
 * Returns the z component of the cross product between vectors BC and BA.
 */
+ (float) crossProductZ:(ZXResultPoint *)pointA pointB:(ZXResultPoint *)pointB pointC:(ZXResultPoint *)pointC {
  float bX = pointB.x;
  float bY = pointB.y;
  return ((pointC.x - bX) * (pointA.y - bY)) - ((pointC.y - bY) * (pointA.x - bX));
}

@end
