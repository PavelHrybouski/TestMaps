//
//  UIView+MKAnnotationView.m
//  TestMaps
//
//  Created by Pavel Hrybouski on 12.10.16.
//  Copyright © 2016 Pavel Hrybouski. All rights reserved.
//

#import "UIView+MKAnnotationView.h"
#import <MapKit/MKAnnotationView.h>
@implementation UIView (MKAnnotationView)

- (MKAnnotationView *) superAnnotationView {
    if ([self isKindOfClass:[MKAnnotationView class]]) {
        return (MKAnnotationView *)self;
    }
    if (!self.superview) {
        return nil;
    }
    
    return [self.superview superAnnotationView];
}
@end
