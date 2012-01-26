
@interface Pair : DataCharacter {
  FinderPattern * finderPattern;
  int count;
}

- (id) init:(int)value checksumPortion:(int)checksumPortion finderPattern:(FinderPattern *)finderPattern;
- (FinderPattern *) getFinderPattern;
- (int) getCount;
- (void) incrementCount;
@end
