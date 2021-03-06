//
//  UITableView+Placeholder.m
//  HTCart
//
//  Created by Huiting Mao on 2017/6/2.
//  Copyright © 2017年 Martell. All rights reserved.
//

#import "UITableView+Placeholder.h"

@implementation UITableView (Placeholder)

- (void)placeholderBaseOnNumber:(NSInteger)numberOfRows iconConfig:(void (^) (UIImageView *imageView))iconConfig textConfig:(void (^) (UILabel *label))textConfig {
    // initial UITableViewPlaceholderView
    UITableViewPlaceholderView *placeholderView = [self viewWithTag:300323];
    if (!placeholderView) {
        placeholderView = [[UITableViewPlaceholderView alloc] init];
        placeholderView.tag = 300323;
    }
    
    // config the imageView and label
    if (iconConfig) {
        iconConfig(placeholderView.placeholderImageView);
    }
    if (textConfig) {
        textConfig(placeholderView.placeholderLabel);
    }
    
    // setup tableview background view
    if (!self.didSetup) {
        self.originalSeparatorStyle = self.separatorStyle;
        self.didSetup = YES;
        
        if (self.backgroundView) {
            [self.backgroundView addSubview:self.placeholderView];
        }
        else {
            self.backgroundView = placeholderView;
        }
    }
    
    // hide or show
    if (numberOfRows) {
        self.separatorStyle = self.originalSeparatorStyle;
        placeholderView.hidden = YES;
    }
    else {
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        placeholderView.hidden = NO;
    }
    
    // change frame
    placeholderView.frame = self.bounds;
}

- (void)placeholderBaseOnNumber:(NSInteger)numberOfRows withConf:(HTTablePlaceholderConf *)conf {
    [self placeholderBaseOnNumber:numberOfRows iconConfig:^(UIImageView *imageView) {
        imageView.animationImages = conf.animImages;
        imageView.animationDuration = conf.animDuration;
        imageView.image = conf.placeholderImage;
        if (conf.loadingData) {
            [imageView startAnimating];
        }
        else {
            [imageView stopAnimating];
        }
    } textConfig:^(UILabel *label) {
        label.text   = conf.placeholderText;
        label.font   = conf.placeholderFont;
        label.textColor = conf.placeholderColor;
        label.hidden = conf.loadingData;
    }];
}

#pragma mark setter/getter

- (void)setOriginalSeparatorStyle:(UITableViewCellSeparatorStyle)originalSeparatorStyle {
    objc_setAssociatedObject(self, @"originalSeparatorStyle", @(originalSeparatorStyle), OBJC_ASSOCIATION_ASSIGN);
}

- (UITableViewCellSeparatorStyle)originalSeparatorStyle {
    return [objc_getAssociatedObject(self, @"originalSeparatorStyle") integerValue];
}

// did setup
- (void)setDidSetup:(BOOL)didSetup {
    objc_setAssociatedObject(self, @"didSetup", @(didSetup), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)didSetup {
    return [objc_getAssociatedObject(self, @"didSetup") boolValue];
}

// placeholder view
- (void)setPlaceholderView:(UITableViewPlaceholderView *)placeholderView {
    objc_setAssociatedObject(self, @"placeholderView", placeholderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITableViewPlaceholderView *)placeholderView {
    return objc_getAssociatedObject(self, @"placeholderView");
}

@end

@implementation UITableViewPlaceholderView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.placeholderImageView = [UIImageView new];
        self.placeholderLabel     = [UILabel new];
        
        [self addSubview:_placeholderImageView];
        [self addSubview:_placeholderLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat maxHeight = 0;
    if (_placeholderImageView.image) {
        maxHeight += _placeholderImageView.image.size.height;
    }
    
    CGSize textSize = CGSizeZero;
    if (_placeholderLabel.text.length) {
        NSString *text = _placeholderLabel.text;
        textSize = [text sizeWithAttributes:@{NSFontAttributeName:_placeholderLabel.font}];
        maxHeight += textSize.height;
    }
    
    CGFloat offset = 0;
    if (_placeholderImageView.image && _placeholderLabel.text.length) {
        offset = 8;
    }
    maxHeight += offset;
    
    _placeholderImageView.frame = CGRectMake((CGRectGetMaxX(self.frame)-_placeholderImageView.image.size.width)/2,
                                             (CGRectGetMaxY(self.frame)-maxHeight)/2,
                                             _placeholderImageView.image.size.width,
                                             _placeholderImageView.image.size.height);
    _placeholderLabel.frame = CGRectMake(0,
                                         CGRectGetMaxY(_placeholderImageView.frame) + offset,
                                         textSize.width,
                                         textSize.height);
    CGPoint center = _placeholderLabel.center;
    center.x = self.center.x;
    _placeholderLabel.center = center;
}

@end


@implementation HTTablePlaceholderConf

+ (instancetype)defaultConf {
    static dispatch_once_t onceToken;
    static HTTablePlaceholderConf *sharedObject = nil;
    dispatch_once(&onceToken, ^{
        if (!sharedObject) {
            sharedObject = [HTTablePlaceholderConf new];
            [sharedObject _setupDefaultValue];
        }
    });
    return sharedObject;
}

- (void)_setupDefaultValue {
    self.placeholderText = @"没有发现数据";
    self.placeholderImage= nil;
    self.animImages      = nil;
    self.loadingData     = NO;
    
    self.placeholderFont = [UIFont systemFontOfSize:15];
    self.placeholderColor= [UIColor lightGrayColor];
    
    self.animDuration    = 2;
}

@end
