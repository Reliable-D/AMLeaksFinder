//
//  UIPageViewController+AMLeaksFinderSwizzleDealloc.m
//  AMLeaksFinder
//
//  Created by liangdahong on 2020/5/20.
//

#import "UIPageViewController+AMLeaksFinderSwizzleDealloc.h"
#import "UIViewController+AMLeaksFinderUI.h"
#import "UIViewController+AMLeaksFinderTools.h"

@implementation UIPageViewController (AMLeaksFinderSwizzleDealloc)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        amleaks_finder_swizzleInstanceMethod(self.class,
                              @selector(setViewControllers:direction:animated:completion:),
                              @selector(amleaks_finder_setViewControllers:direction:animated:completion:));
    });
}

- (void)amleaks_finder_setViewControllers:(NSArray<UIViewController *> *)viewControllers direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    NSMutableArray <UIViewController *> *muarray = @[].mutableCopy;
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __block BOOL flag = NO;
        [viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
            if (obj == obj1) {
                flag = YES;
                *stop1 = YES;
            }
        }];
        if (!flag) {
            [muarray addObject:obj];
        }
    }];
    [muarray enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 设置为将要释放
        [obj amleaks_finder_shouldDealloc];
    }];
    [self amleaks_finder_setViewControllers:viewControllers direction:direction animated:animated completion:completion];
}

@end
