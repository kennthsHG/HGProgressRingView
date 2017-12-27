//
//  HGProgressRingView.m
//  HGProgressRingView
//
//  Created by gang on 2017/12/14.
//  Copyright © 2017年 gang. All rights reserved.
//

#import "HGProgressRingView.h"

#define kDeviceWidth                [UIScreen mainScreen].bounds.size.width
#define KDeviceHeight               [UIScreen mainScreen].bounds.size.height
//Degress to PI
#define CATDegreesToRadians(x) (M_PI*(x)/180.0)
#define kRGBAColor(R,G,B,A) [UIColor colorWithRed:(R)/255.0f green:(G)/255.0f blue:(B)/255.0f alpha:(A)]
#define kPieRandColor [UIColor colorWithRed:arc4random() % 255 / 255.0f green:arc4random() % 255 / 255.0f blue:arc4random() % 255 / 255.0f alpha:1.0f]
#define kLabelLoctionRatio (1.2*bgRadius)

//Defalut value
#define HGProgressLineWidth      (13)
#define HGProgressStartAngle     (-90)
#define HGProgressEndAngle       (275)
#define HGProgressNullColor       kRGBAColor(232, 232, 232, 1)
#define HGAnimationDuration 1.f
@interface HGProgressRingView()

@property (nonatomic, assign) int allCount;

@property (nonatomic, strong) CAShapeLayer * nullProgressLayer;

@property (nonatomic, strong) NSMutableArray * LayersArray;
@property (nonatomic, strong) UIBezierPath * path;

@property (nonatomic, strong) CAShapeLayer *bgCircleLayer;

//ProgressType
@property (nonatomic, assign) HGProgressRingType type;

//show if clockwise
@property (nonatomic, assign) BOOL clockwise;

/**
 *  共传入的圆环条数数组的总量
 */
@property (nonatomic,copy) NSArray * ProgressDetailsArray;  //如有三条 @[@"20",@"30",40]; 则总量为90

/**
 *  共传入的圆环颜色数组
 */
@property (nonatomic,copy) NSArray * ProgressColorArray;  //如有三条 @[[UIColor redColor],[UIColor blackColor],[UIColor whiteColor]];

/**
 *  共传入的圆环百分比数组
 */
@property (nonatomic,copy) NSArray * ProgressPercentageArray;

@end

@implementation HGProgressRingView


- (instancetype) initWithFrame:(CGRect)frame ProgressDetailsArray:(NSArray*)ProgressDetailsArray ProgressColorArray:(NSArray*)ProgressColorArray type:(HGProgressRingType)type clockwise:(BOOL)clockwise{

    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor whiteColor]];
        self.ProgressDetailsArray = ProgressDetailsArray;
        self.ProgressColorArray = ProgressColorArray;
        self.type = type;
        self.progressLineWidth = HGProgressLineWidth;
        self.clockwise = clockwise;
        self.showNum = NO;
        self.NumColor = [UIColor blackColor];
        
        self.type == HGProgressRingTypeRing ? [self initRingUI] : nil;
        
        
    }
    return self;

}

- (void)initPieUI{
    
    self.hidden = YES;
    
    CGFloat centerWidth = self.frame.size.width * 0.5f;
    CGFloat centerHeight = self.frame.size.height * 0.5f;
    CGFloat centerX = centerWidth;
    CGFloat centerY = centerHeight;
    CGPoint centerPoint = CGPointMake(centerX, centerY);
    CGFloat radiusBasic = centerWidth > centerHeight ? centerHeight : centerWidth;
    
    self.allCount = 0.0f;
    for (int i = 0; i < self.ProgressDetailsArray.count; i++) {
        self.allCount += [self.ProgressDetailsArray[i] floatValue];
    }
    
    //2.背景路径
    CGFloat bgRadius = radiusBasic * 0.5;
    UIBezierPath *bgPath;
    UIBezierPath *otherPath;
    
    CGFloat otherRadius = radiusBasic * 0.5 - 3.0;
    CGFloat start = 0.0f;
    CGFloat end = 0.0f;
    
    if (self.clockwise == YES) {
        bgPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                radius:bgRadius
                                            startAngle:-M_PI_2
                                              endAngle:M_PI_2 * 3
                                             clockwise:self.clockwise];
        otherPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                   radius:otherRadius
                                               startAngle:-M_PI_2
                                                 endAngle:M_PI_2 * 3
                                                clockwise:self.clockwise];
    }
    else{
        
        bgPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                radius:bgRadius
                                            startAngle:M_PI_2 * 3
                                              endAngle:-M_PI_2
                                             clockwise:self.clockwise];
        otherPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                   radius:otherRadius
                                               startAngle:M_PI_2 * 3
                                                 endAngle:-M_PI_2
                                                clockwise:self.clockwise];
        
    }

    _bgCircleLayer = [CAShapeLayer layer];
    _bgCircleLayer.fillColor   = [UIColor clearColor].CGColor;
    _bgCircleLayer.strokeColor = [UIColor redColor].CGColor;
    _bgCircleLayer.strokeStart = 0.0f;
    _bgCircleLayer.strokeEnd   = 1.0f;
    _bgCircleLayer.zPosition   = 1;
    _bgCircleLayer.lineWidth   = bgRadius * 2.0f;
    _bgCircleLayer.path        = bgPath.CGPath;
    
    
    for (int i = 0; i < self.ProgressDetailsArray.count; i++) {

        end = [self.ProgressDetailsArray[i] floatValue] / _allCount + start;
        
        CAShapeLayer *pie = [CAShapeLayer layer];
        [self.layer addSublayer:pie];
        pie.fillColor   = [UIColor clearColor].CGColor;
        if (i > self.ProgressColorArray.count - 1 || !self.ProgressColorArray  || self.ProgressColorArray.count == 0) {
            pie.strokeColor = kPieRandColor.CGColor;
        } else {
            pie.strokeColor = ((UIColor *)self.ProgressColorArray[i]).CGColor;
        }
        pie.strokeStart = start;
        pie.strokeEnd   = end;
        pie.lineWidth   = otherRadius * 2.0f;
        pie.zPosition   = 2;
        pie.path        = otherPath.CGPath;
        
        
        CGFloat centerAngle = M_PI * (start + end);
        
        !_clockwise ? centerAngle = -centerAngle : 0;
        
        CGFloat labelCenterX = kLabelLoctionRatio * sinf(centerAngle) + centerX;
        CGFloat labelCenterY = -kLabelLoctionRatio * cosf(centerAngle) + centerY;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, radiusBasic * 0.7f, radiusBasic * 0.7f)];
        label.center = CGPointMake(labelCenterX, labelCenterY);
        
        if (_showNum) {
            label.text = [NSString stringWithFormat:@"%@",self.ProgressDetailsArray[i]];
        }
        
        if (_showPercentage) {
             label.text = [NSString stringWithFormat:@"%ld%%",(NSInteger)((end - start + 0.005) * 100)];
        }
        
        
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = self.NumColor;
        label.layer.zPosition = 3;
        [self addSubview:label];
        
        start = end;
    }
    
    self.layer.mask = _bgCircleLayer;
    
}

- (void)initRingUI{
    
    self.LayersArray = @[].mutableCopy;
    [self.ProgressDetailsArray enumerateObjectsUsingBlock:^(NSString * _Nonnull num, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CAShapeLayer * progressLayer = [CAShapeLayer layer];
        progressLayer.fillColor = [[UIColor clearColor] CGColor];
       
        if (idx > self.ProgressColorArray.count - 1 || !self.ProgressColorArray  || self.ProgressColorArray.count == 0) {
            progressLayer.strokeColor = kPieRandColor.CGColor;
        } else {
            progressLayer.strokeColor = ((UIColor *)self.ProgressColorArray[idx]).CGColor;
        }
        
        progressLayer.lineCap = kCALineCapRound;
        progressLayer.strokeEnd = 0.f;
        [self.LayersArray addObject:progressLayer];
    }];
    
    NSArray* reversedArray = [[self.LayersArray reverseObjectEnumerator] allObjects];
    [reversedArray enumerateObjectsUsingBlock:^(CAShapeLayer *  _Nonnull progressLayer, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.layer addSublayer:progressLayer];
    }];
    
    [self.layer addSublayer:self.nullProgressLayer];
    
}

- (void)updateProgress:(NSNumber*)animated{
    
    
    if (self.type == HGProgressRingTypePie) {
        
        self.hidden = NO;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration  = HGAnimationDuration;
        animation.fromValue = @0.0f;
        animation.toValue   = @1.0f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.removedOnCompletion = YES;
        [_bgCircleLayer addAnimation:animation forKey:@"circleAnimation"];
        
        return;
    }
    
    
    [self setLayerPath];
    
    [self.ProgressDetailsArray enumerateObjectsUsingBlock:^(NSString * _Nonnull num, NSUInteger idx, BOOL * _Nonnull stop) {
        _allCount = _allCount + [num intValue];
    }];
    
    [CATransaction begin];
    [CATransaction setDisableActions:![animated boolValue]];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [CATransaction setAnimationDuration:HGAnimationDuration];
    
    CGFloat nowPercentage = 0.f;
    NSInteger lastCount = 0;
    
    for (int i = 0 ; i < self.ProgressDetailsArray.count; i++) {
        
        CGFloat progressValue = [self.ProgressDetailsArray[i] floatValue] / _allCount;
        
        CAShapeLayer * progressLayer = self.LayersArray[i];
        progressLayer.strokeStart = nowPercentage;
        progressLayer.strokeEnd = progressValue + nowPercentage;
        nowPercentage = nowPercentage + progressValue;
        lastCount = [self.ProgressDetailsArray[i] floatValue] + lastCount;
        
        if (_showNum) {
          [self setText:progressLayer.strokeStart end:progressLayer.strokeEnd progress:progressValue withText:self.ProgressDetailsArray[i]];
        }
        
        if (_showPercentage) {
            
            CGFloat Percentage = [self.ProgressDetailsArray[i] floatValue] / self.allCount;
            NSString * str = [NSString stringWithFormat:@"%.1f%%",Percentage * 100];
            
            [self setText:progressLayer.strokeStart end:progressLayer.strokeEnd progress:progressValue withText:str];
        }
    }
    
    if (self.ProgressDetailsArray.count == 0) {
        _nullProgressLayer.strokeStart = 0.f;
        _nullProgressLayer.strokeEnd = 1.f;
    }

    [CATransaction commit];
}

- (void)startProgress:(BOOL)animated{
    
    self.type == HGProgressRingTypePie ? [self initPieUI] : nil;
    [self performSelector:@selector(updateProgress:) withObject:[NSNumber numberWithBool:animated] afterDelay:.1f];
}

- (void)setText:(double)start end:(double)end progress:(CGFloat)progress withText:(NSString*)text{
    
    CGFloat percentage = .81 - (self.progressLineWidth - 15.f)*.01;
    
    CGSize size = CGSizeMake(self.bounds.size.width * percentage, self.bounds.size.height * percentage);
    CGFloat pieRadius = size.width/ 2;
    
    CGFloat centerAngle = M_PI * (start + end);
    
    !_clockwise ? centerAngle = -centerAngle : 0;
    
    CGFloat centerWidth = self.bounds.size.width * 0.5f;
    CGFloat centerHeight = self.bounds.size.height * 0.5f;
    
    CGFloat centerX = pieRadius * sinf(centerAngle) + centerWidth;
    CGFloat centerY = -pieRadius * cosf(centerAngle) + centerHeight;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    ![text isEqualToString:@"0"] ? label.text = text : nil;
    label.font = [UIFont systemFontOfSize:8.f];
    label.textColor = self.NumColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    label.center = CGPointMake(centerX, centerY);
    label.alpha = 0.f;
    [self addSubview:label];
    
    [UIView animateWithDuration:2.f animations:^{
        [label setAlpha:1.f];
    }];
    
}

#pragma mark - Getters
-(UIBezierPath*)path{
    if (nil == _path) {
        CGFloat radius = self.frame.size.width/2-self.progressLineWidth;
        _path=[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:radius startAngle:CATDegreesToRadians(HGProgressStartAngle) endAngle:CATDegreesToRadians(HGProgressEndAngle) clockwise:self.clockwise];
    }
    return _path;
}

- (CAShapeLayer*)nullProgressLayer{
    if (nil == _nullProgressLayer) {
        _nullProgressLayer = [CAShapeLayer layer];
        _nullProgressLayer.frame = self.bounds;
        _nullProgressLayer.strokeColor = HGProgressNullColor.CGColor;
        _nullProgressLayer.fillColor = [[UIColor clearColor] CGColor];
        _nullProgressLayer.lineCap = kCALineCapRound;
        _nullProgressLayer.strokeEnd = 0.f;
    }
    return _nullProgressLayer;
}

#pragma mark - Setters
-(void)setProgressLineWidth:(CGFloat)progressLineWidth{
    progressLineWidth < 15.f ? progressLineWidth = 15.f : 0;
    _progressLineWidth = progressLineWidth;
    
}

- (void)setLayerPath{
    
    [self.LayersArray enumerateObjectsUsingBlock:^(CAShapeLayer *  _Nonnull progressLayer, NSUInteger idx, BOOL * _Nonnull stop) {
        progressLayer.frame = self.bounds;
        progressLayer.path = self.path.CGPath;
        progressLayer.lineWidth = _progressLineWidth;
    }];
    
    self.nullProgressLayer.frame = self.bounds;
    self.nullProgressLayer.path = self.path.CGPath;
    self.nullProgressLayer.lineWidth = _progressLineWidth;
}
@end
