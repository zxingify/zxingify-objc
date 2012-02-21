/**
 * Adapted from listings in ISO/IEC 24724 Appendix B and Appendix G.
 */

@interface RSSUtils : NSObject

+ (NSArray *) getRSSwidths:(int)val n:(int)n elements:(int)elements maxWidth:(int)maxWidth noNarrow:(BOOL)noNarrow;
+ (int) getRSSvalue:(NSArray *)widths maxWidth:(int)maxWidth noNarrow:(BOOL)noNarrow;
+ (int) combins:(int)n r:(int)r;
+ (NSArray *) elements:(NSArray *)eDist N:(int)N K:(int)K;

@end
