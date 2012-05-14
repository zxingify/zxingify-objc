/**
 * Adapted from listings in ISO/IEC 24724 Appendix B and Appendix G.
 */

@interface ZXRSSUtils : NSObject

+ (NSArray *)rssWidths:(int)val n:(int)n elements:(int)elements maxWidth:(int)maxWidth noNarrow:(BOOL)noNarrow;
+ (int)rssValue:(int *)widths widthsLen:(unsigned int)widthsLen maxWidth:(int)maxWidth noNarrow:(BOOL)noNarrow;
+ (int)combins:(int)n r:(int)r;
+ (NSArray *)elements:(NSArray *)eDist N:(int)N K:(int)K;

@end
