
#import "UITableView+SCIndexView.h"
#import <objc/runtime.h>
#import "SCIndexView.h"

@interface UITableView () <SCIndexViewDelegate>

@property (nonatomic, strong) SCIndexView *sc_indexView;

@end

@implementation UITableView (SCIndexView)

#pragma mark - Life Cycle

+ (void)load
{
    Class class = [self class];
    SEL originalSelector = @selector(didMoveToSuperview);
    SEL swizzledSelector = @selector(SCIndexView_didMoveToSuperview);
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)SCIndexView_didMoveToSuperview
{
    [self SCIndexView_didMoveToSuperview];
    if (self.superview && self.sc_indexView) {
        [self.superview addSubview:self.sc_indexView];
    }
}

#pragma mark - SCIndexViewDelegate

- (void)indexView:(SCIndexView *)indexView didSelectAtSection:(NSUInteger)section
{
    if (self.sc_indexViewDelegate && [self.delegate respondsToSelector:@selector(tableView:didSelectIndexViewAtSection:)]) {
        [self.sc_indexViewDelegate tableView:self didSelectIndexViewAtSection:section];
    }
}

- (NSUInteger)sectionOfIndexView:(SCIndexView *)indexView tableViewDidScroll:(UITableView *)tableView
{
    if (self.sc_indexViewDelegate && [self.delegate respondsToSelector:@selector(sectionOfTableViewDidScroll:)]) {
        return [self.sc_indexViewDelegate sectionOfTableViewDidScroll:self];
    } else {
        return SCIndexViewInvalidSection;
    }
}

#pragma mark - Getter and Setter

- (SCIndexView *)sc_indexView
{
    return objc_getAssociatedObject(self, @selector(sc_indexView));
}

- (void)setSc_indexView:(SCIndexView *)sc_indexView
{
    if (self.sc_indexView == sc_indexView) return;
    
    objc_setAssociatedObject(self, @selector(sc_indexView), sc_indexView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SCIndexViewConfiguration *)sc_indexViewConfiguration
{
    SCIndexViewConfiguration *sc_indexViewConfiguration = objc_getAssociatedObject(self, @selector(sc_indexViewConfiguration));
    if (!sc_indexViewConfiguration) {
        sc_indexViewConfiguration = [SCIndexViewConfiguration configuration];
    }
    return sc_indexViewConfiguration;
}

- (void)setSc_indexViewConfiguration:(SCIndexViewConfiguration *)sc_indexViewConfiguration
{
    if (self.sc_indexViewConfiguration == sc_indexViewConfiguration) return;
    
    objc_setAssociatedObject(self, @selector(sc_indexViewConfiguration), sc_indexViewConfiguration, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<SCTableViewSectionIndexDelegate>)sc_indexViewDelegate
{
    return objc_getAssociatedObject(self, @selector(sc_indexViewDelegate));
}

- (void)setSc_indexViewDelegate:(id<SCTableViewSectionIndexDelegate>)sc_indexViewDelegate
{
    if (self.sc_indexViewDelegate == sc_indexViewDelegate) return;
    
    objc_setAssociatedObject(self, @selector(sc_indexViewDelegate), sc_indexViewDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sc_translucentForTableViewInNavigationBar
{
    NSNumber *number = objc_getAssociatedObject(self, @selector(sc_translucentForTableViewInNavigationBar));
    return number.boolValue;
}

- (void)setSc_translucentForTableViewInNavigationBar:(BOOL)sc_translucentForTableViewInNavigationBar
{
    if (self.sc_translucentForTableViewInNavigationBar == sc_translucentForTableViewInNavigationBar) return;
    
    objc_setAssociatedObject(self, @selector(sc_translucentForTableViewInNavigationBar), @(sc_translucentForTableViewInNavigationBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<NSString *> *)sc_indexViewDataSource
{
    return objc_getAssociatedObject(self, @selector(sc_indexViewDataSource));
}

- (void)setSc_indexViewDataSource:(NSArray<NSString *> *)sc_indexViewDataSource
{
    if (self.sc_indexViewDataSource == sc_indexViewDataSource) return;
    objc_setAssociatedObject(self, @selector(sc_indexViewDataSource), sc_indexViewDataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!sc_indexViewDataSource || sc_indexViewDataSource.count == 0) {
        [self.sc_indexView removeFromSuperview];
        self.sc_indexView = nil;
        return;
    }
    
    if (!self.sc_indexView) {
        SCIndexView *indexView = [[SCIndexView alloc] initWithTableView:self configuration:self.sc_indexViewConfiguration];
        indexView.translucentForTableViewInNavigationBar = self.sc_translucentForTableViewInNavigationBar;
        indexView.delegate = self;
        if (self.superview) {
            [self.superview addSubview:indexView];
        }
        self.sc_indexView = indexView;
    }
    
    self.sc_indexView.dataSource = sc_indexViewDataSource.copy;
}

@end
