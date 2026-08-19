//
//  NAScrollLabel.h
//  NoahSDK
//
//  Created by wcz on 2023/12/7.
//  Copyright © 2023 Alibaba Inc. All rights reserved.
//

#if NA_EXTERNAL == 0

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NAScrollLabel : UIView

- (void)updateTitle:(NSString *)title slotKey:(NSString *)slotKey;

- (void)updateViewColor:(BOOL)isNightMode;

@end

NS_ASSUME_NONNULL_END

#endif
