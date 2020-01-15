//
//  YPToast.m
//  YPItools
//
//  Created by qipeng_yuhao on 2020/1/15.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import "YPToast.h"

static const float kYPToastMaxWidth = 0.8; //window宽度的80%
static const float kYPToastFontSize = 14;
static const float kYPToastHorizontalSpacing = 8.0;
static const float kYPToastVerticalSpacing = 6.0;

@implementation YPToast

+ (void)showToast:(NSString *)message duration:(NSTimeInterval)interval window:(UIView *)window{
        CGSize windowSize          = window.frame.size;

        UILabel* titleLabel        = [[UILabel alloc] init];
        titleLabel.numberOfLines   = 0;
        titleLabel.font            = [UIFont boldSystemFontOfSize:kYPToastFontSize];
        titleLabel.textAlignment   = NSTextAlignmentCenter;
        titleLabel.lineBreakMode   = NSLineBreakByWordWrapping;
        titleLabel.textColor       = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.alpha           = 1.0;
        titleLabel.text            = message;
        
        CGSize maxSizeTitle      = CGSizeMake(windowSize.width * kYPToastMaxWidth, windowSize.height);
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGSize expectedSizeTitle = [message sizeWithFont:titleLabel.font constrainedToSize:maxSizeTitle lineBreakMode:titleLabel.lineBreakMode];
    #pragma clang diagnostic pop
        titleLabel.frame         = CGRectMake(kYPToastHorizontalSpacing, kYPToastVerticalSpacing, expectedSizeTitle.width + 4, expectedSizeTitle.height);
        
        UIView* view             = [[UIView alloc] init];
        view.frame               = CGRectMake((windowSize.width - titleLabel.frame.size.width) / 2 - kYPToastHorizontalSpacing,
                                              windowSize.height * .85 - titleLabel.frame.size.height,
                                              titleLabel.frame.size.width + kYPToastHorizontalSpacing * 2,
                                              titleLabel.frame.size.height + kYPToastVerticalSpacing * 2);
        view.backgroundColor     = [UIColor colorWithWhite:.2 alpha:.7];
        view.alpha               = 0;
        view.layer.cornerRadius  = view.frame.size.height * .15;
        view.layer.masksToBounds = YES;
        [view addSubview:titleLabel];
        
        [window addSubview:view];

        [UIView animateWithDuration:.25 animations:^{
            view.alpha = 1;
        } completion:^(BOOL finished) {
            if (interval > 0) {
                dispatch_time_t popTime =
                dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [UIView animateWithDuration:.25 animations:^{
                        view.alpha = 0;
                    } completion:^(BOOL finished) {
                        [view removeFromSuperview];
                    }];
                });
            }

        }];

}
@end
