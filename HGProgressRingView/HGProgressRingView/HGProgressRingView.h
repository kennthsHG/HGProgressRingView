//
//  HGProgressRingView.h
//  HGProgressRingView
//
//  Created by gang on 2017/12/14.
//  Copyright © 2017年 gang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HGProgressRingType) {
    HGProgressRingTypeRing,      //圆环图
    HGProgressRingTypePie      //饼状图
};

@interface HGProgressRingView : UIView

/**
 *  圆环图圆环大小
 */
@property (nonatomic, assign) CGFloat progressLineWidth;
/**
 *  显示数字值
 */
@property (nonatomic, assign) BOOL showNum;
/**
 *  显示数字值比例
 */
@property (nonatomic, assign) BOOL showPercentage;
/**
 *  数字值颜色
 */
@property (nonatomic, strong) UIColor * NumColor;

- (instancetype) initWithFrame:(CGRect)frame ProgressDetailsArray:(NSArray*)ProgressDetailsArray ProgressColorArray:(NSArray*)ProgressColorArray type:(HGProgressRingType)type clockwise:(BOOL)clockwise;

- (void)startProgress:(BOOL)animated;
@end
