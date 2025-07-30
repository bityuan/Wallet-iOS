//
//  PWVersionView.m
//  PWallet
//
//  Created by 于优 on 2018/11/14.
//  Copyright © 2018 陈健. All rights reserved.
//

#import "PWVersionView.h"
#import "PWVersionModel.h"

@interface PWVersionView ()

/** 底板 */
@property (nonatomic, strong) UIView *bgView;
/** icon */
@property (nonatomic, strong) UIImageView *iconImgView;
/** version */
@property (nonatomic, strong) UILabel *versionLab;
/** 内容 */
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *contentLab;
/** 取消 */
@property (nonatomic, strong) UIButton *cancalBtn;
/** 操作 */
@property (nonatomic, strong) UIButton *updateBtn;


@end

@implementation PWVersionView

+ (instancetype)shopView {
    
    return [[self alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self crtateView];
    }
    return self;
}

- (void)crtateView {
    self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.backgroundColor = CMColorRGBA(0, 0, 0, 0.5);
    
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.iconImgView];
    [self.bgView addSubview:self.versionLab];
    [self.bgView addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentLab];
    [self.bgView addSubview:self.cancalBtn];
    [self.bgView addSubview:self.updateBtn];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(38);
        make.right.equalTo(self).offset(-38);
        make.height.mas_offset(370);
        make.centerY.mas_equalTo(self);
    }];
    
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(99);
        make.width.mas_offset(99);
        make.top.equalTo(self.bgView).offset(30);
        make.centerX.mas_equalTo(self.bgView);
    }];
    
    [self.versionLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(15);
        make.right.equalTo(self.bgView).offset(-15);
        make.height.mas_offset(25);
        make.top.equalTo(self.iconImgView.mas_bottom).offset(10);
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(40);
        make.right.equalTo(self.bgView).offset(-40);
        make.top.equalTo(self.versionLab.mas_bottom).offset(30);
        make.height.mas_equalTo(100);
    }];
    
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView);
        make.left.equalTo(self.bgView).offset(40);
        make.right.equalTo(self.bgView).offset(-40);
    }];
    
   
    
}

#pragma mark - Action

- (void)removeView {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.1;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)cancalAction {
    
    [self removeView];
}

- (void)updateAction {
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.versionModel.download_url]];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.versionModel.download_url]  options:@{}
                                 completionHandler:^(BOOL success) {
                                     NSLog(@"Open %d",success);
                                 }];
    } else {
        BOOL success = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.versionModel.download_url]];
        NSLog(@"Open  %d",success);
    }
}

#pragma mark - setter & getter

- (void)setUpdateType:(PWUpdateType)updateType {
    _updateType = updateType;
    
    switch (updateType) {
        case PWUpdateTypeNormal:{
            
            CGFloat width = (kScreenWidth - 39 * 2 - 20 * 3) * 0.5;
            
            [self.cancalBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.bgView).offset(20);
                make.bottom.equalTo(self.bgView.mas_bottom).offset(-24);
                make.width.mas_equalTo(width);
                make.height.mas_equalTo(40);
            }];
            
            [self.updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.bgView).offset(-20);
                make.bottom.equalTo(self.bgView.mas_bottom).offset(-24);
                make.width.mas_equalTo(width);
                make.height.mas_equalTo(40);
            }];
        }
            break;
            
        case PWUpdateTypeMust:{
            
            [self.updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.bgView).offset(20);
                make.right.equalTo(self.bgView).offset(-20);
                make.bottom.equalTo(self.bgView.mas_bottom).offset(-24);
                make.height.mas_equalTo(40);
            }];
        }
            break;
    }
}

- (void)setVersionModel:(PWVersionModel *)versionModel {
    _versionModel = versionModel;

    self.versionLab.text = [NSString stringWithFormat:@"版本更新%@".localized,versionModel.version];
    
//    NSMutableArray *newTextArray = [[NSMutableArray alloc] init];
//    NSInteger index = 0;
//    for (NSString *text in versionModel.log) {
//        index = index + 1;
//        NSString *newText = [NSString stringWithFormat:@"%ld.%@",(long)index, text];
//        [newTextArray addObject:newText];
//    }
    self.contentLab.text = versionModel.log;
     CGRect rect = [self.contentLab.text boundingRectWithSize:CGSizeMake(kScreenWidth - 176, MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.f]}
                                                      context:nil];
    self.scrollView.contentSize = CGSizeMake(kScreenWidth - 176, rect.size.height);
    if (rect.size.height <= 100) {
        self.scrollView.scrollEnabled = NO;
    }
    else
    {
        self.scrollView.scrollEnabled = YES;
    }
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [UIView new];
        _bgView.backgroundColor = CMColorFromRGB(0xFFFFFF);
        _bgView.layer.cornerRadius = 6.f;
        _bgView.clipsToBounds = YES;
    }
    return _bgView;
}

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [UIImageView new];
        _iconImgView.image = [UIImage imageNamed:@"public_version"];
    }
    return _iconImgView;
}

- (UILabel *)versionLab {
    if (!_versionLab) {
        _versionLab = [UILabel new];
        _versionLab.font = [UIFont boldSystemFontOfSize:18];
        _versionLab.textColor = CMColorFromRGB(0x333649);
        _versionLab.textAlignment = NSTextAlignmentCenter;
    }
    return _versionLab;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = UIColor.whiteColor;
        
    }
    return _scrollView;
}

- (UILabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [UILabel new];
        _contentLab.numberOfLines = 0;
        _contentLab.font = [UIFont systemFontOfSize:14];
        _contentLab.textColor = CMColorFromRGB(0x8E92A3);
    }
    return _contentLab;
}

- (UIButton *)cancalBtn {
    if (!_cancalBtn) {
        _cancalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancalBtn setTitle:@"暂不更新".localized forState:UIControlStateNormal];
        [_cancalBtn setTitleColor:CMColorFromRGB(0xD9DCE9) forState:UIControlStateNormal];
        _cancalBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        _cancalBtn.layer.borderColor = CMColorFromRGB(0xD9DCE9).CGColor;
        _cancalBtn.layer.borderWidth = 0.5;
        _cancalBtn.layer.cornerRadius = 3.f;
        _cancalBtn.clipsToBounds = YES;
        [_cancalBtn addTarget:self action:@selector(cancalAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancalBtn;
}

- (UIButton *)updateBtn {
    if (!_updateBtn) {
        _updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_updateBtn setTitle:@"更新".localized forState:UIControlStateNormal];
        _updateBtn.backgroundColor = CMColorFromRGB(0x7190FF);
        [_updateBtn setTitleColor:CMColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        _updateBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        _updateBtn.layer.cornerRadius = 3.f;
        _updateBtn.clipsToBounds = YES;
        [_updateBtn addTarget:self action:@selector(updateAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _updateBtn;
}

@end
