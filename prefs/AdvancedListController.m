#import <UIKit/UIKit.h>
#import <Preferences/PSSpecifier.h>
#import "RootListController.h"

@implementation AdvancedListController
- (NSArray *)specifiers {
    if (!_specifiers) _specifiers = [self loadSpecifiersFromPlistName:@"Advanced" target:self];
    return _specifiers;
}

static UIColor *axisColor(NSString *a) {
    if ([a isEqualToString:@"X"]) return [UIColor systemRedColor];
    if ([a isEqualToString:@"Y"]) return [UIColor systemGreenColor];
    return [UIColor systemBlueColor];
}

- (NSDictionary *)axisInfoForSection:(NSInteger)s {
    if ([self.table numberOfRowsInSection:s] < 1) return nil;
    PSSpecifier *sp = [self specifierAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:s]];
    NSString *axis = [sp propertyForKey:@"axis"];
    NSString *name = [sp propertyForKey:@"sensor"];
    return axis ? @{@"axis": axis, @"name": name ?: @"", @"letter": [sp propertyForKey:@"axisName"] ?: axis} : nil;
}

- (UIView *)tableView:(UITableView *)tv viewForHeaderInSection:(NSInteger)s {
    NSDictionary *info = [self axisInfoForSection:s];
    if (!info) return nil;
    UIView *v = [[UIView alloc] init];
    UILabel *l = [[UILabel alloc] init];
    l.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableAttributedString *t = [[NSMutableAttributedString alloc]
        initWithString:[[info[@"name"] uppercaseString] stringByAppendingString:@"   "]
        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightMedium],
                     NSForegroundColorAttributeName: [UIColor secondaryLabelColor]}];
    [t appendAttributedString:[[NSAttributedString alloc] initWithString:info[@"letter"]
        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightBold],
                     NSForegroundColorAttributeName: axisColor(info[@"axis"])}]];
    l.attributedText = t;
    [v addSubview:l];
    [NSLayoutConstraint activateConstraints:@[
        [l.leadingAnchor constraintEqualToAnchor:v.leadingAnchor constant:20],
        [l.bottomAnchor constraintEqualToAnchor:v.bottomAnchor constant:-4]]];
    return v;
}

- (CGFloat)tableView:(UITableView *)tv heightForHeaderInSection:(NSInteger)s {
    return [self axisInfoForSection:s] ? 38 : UITableViewAutomaticDimension;
}
@end
