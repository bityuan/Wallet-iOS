//
//  PWContactsCell.m
//  PWallet
//
//  Created by 陈健 on 2018/11/13.
//  Copyright © 2018 陈健. All rights reserved.
//

#import "PWContactsCell.h"
@interface PWContactsCell()
@property (nonatomic,weak) UILabel *circleLab;
@property (nonatomic,weak) UILabel *textLab;
@property (nonatomic,weak) UILabel *detailLab;
@property (nonatomic,weak) UIView  *line;
@end

@implementation PWContactsCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    UILabel *circleLab = [[UILabel alloc]init];
    circleLab.font = [UIFont boldSystemFontOfSize:18];
    circleLab.textColor = [UIColor whiteColor];
    circleLab.textAlignment = NSTextAlignmentCenter;
    [self.swipeContentView addSubview:circleLab];
    self.circleLab = circleLab;
    
    UILabel *textLab = [[UILabel alloc]init];
    textLab.font = [UIFont boldSystemFontOfSize:18];
    textLab.textColor = SGColorFromRGB(0x333649);
    [self.swipeContentView addSubview:textLab];
    self.textLab = textLab;
    
    UILabel *detailLab = [[UILabel alloc]init];
    detailLab.font = [UIFont systemFontOfSize:15];
    detailLab.textColor = SGColorFromRGB(0x8E92A3);
    detailLab.textAlignment = NSTextAlignmentRight;
    [self.swipeContentView addSubview:detailLab];
    self.detailLab = detailLab;
    
    //分割线
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = SGColorFromRGB(0xD9DCE9);
    [self.swipeContentView addSubview:line];
    self.line = line;
}

- (void)layoutSubviews {
    [self.circleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.left.equalTo(self.swipeContentView).offset(24);
        make.centerY.equalTo(self.swipeContentView);
    }];
    self.circleLab.layer.cornerRadius = 20;
    self.circleLab.layer.masksToBounds = true;
    
    [self.detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.swipeContentView);
        make.right.equalTo(self.swipeContentView);
        make.width.mas_equalTo(105);
    }];
    
    [self.textLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.swipeContentView);
        make.left.equalTo(self.circleLab.mas_right).offset(11);
        make.right.equalTo(self.detailLab.mas_left).offset(-15);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textLab);
        make.height.mas_equalTo(0.5);
        make.right.equalTo(self.detailLab);
        make.bottom.equalTo(self.swipeContentView);
    }];
}

- (void)setText:(NSString *)text {
    self.textLab.text = text;
    if (text.length >= 1) {
        self.circleLab.text = [text substringToIndex:1];
    }
}

- (void)setDetailText:(NSString *)detailText {
    self.detailLab.text = detailText;
}

- (void)setIndex:(NSInteger)index {
    switch (index % 3) {
        case 0:
            self.circleLab.backgroundColor = SGColorFromRGB(0x7190FF);
            break;
        case 1:
            self.circleLab.backgroundColor = SGColorFromRGB(0x57C0B1);
            break;
        case 2:
            self.circleLab.backgroundColor = SGColorFromRGB(0x9A72FF);
            break;
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
