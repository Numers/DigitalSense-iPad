//
//  SmellFakeView.h
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Smell;
@interface SmellFakeView : UIView
@property(nonatomic, strong) Smell *smell;
@property(nonatomic, strong) UIImageView *fakeImageView;
@property(nonatomic, assign) CGPoint originalCenter;
@property(nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign)CGRect cellFrame;

@property(nonatomic, assign) CGPoint toBackViewCenter;
-(instancetype)initWithView:(UIView *)view;

- (void)pushFowardViewWithScale:(CGFloat)scale completion:(void(^)(BOOL isFinished))completion;
- (void)pushBackView:(void(^)(BOOL isFinished))completion;
@end
