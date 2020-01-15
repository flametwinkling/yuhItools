//
//  YPToast.h
//  YPItools
//
//  Created by qipeng_yuhao on 2020/1/15.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YPToast : NSObject

+ (void)showToast:(NSString *)message duration:(NSTimeInterval)interval window:(UIView *)window;

@end

NS_ASSUME_NONNULL_END
