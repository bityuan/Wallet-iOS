//
//  PWMessageCell.m
//  PWallet
//
//  Created by 陈健 on 2018/11/19.
//  Copyright © 2018 陈健. All rights reserved.
//

#import "PWMessageCell.h"
@interface PWMessageCell()
/**title*/
@property (nonatomic,weak) UILabel *titleLab;
/**infor*/
@property (nonatomic,weak) UILabel *inforLab;
/**time*/
@property (nonatomic,weak) UILabel *timeLab;
/**badge*/
@property (nonatomic,weak) UILabel *badge;
@end
@implementation PWMessageCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = SGColorRGBA(247, 247, 251, 1);
        [self initViews];
        return self;
    }
    return nil;
}

- (void)initViews {
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 6;
    bgView.layer.masksToBounds = true;
    [self.contentView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(15);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.bottom.equalTo(self.contentView);
    }];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    [bgView addSubview:titleLabel];
    self.titleLab = titleLabel;
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = SGColorRGBA(51, 54, 73, 1);
    titleLabel.adjustsFontSizeToFitWidth = false;
    titleLabel.numberOfLines=2;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView).offset(13);
        make.left.equalTo(bgView).offset(14);
        make.right.mas_equalTo(bgView).offset(-14);
//        make.height.mas_equalTo(22);
    }];
    
    UILabel *inforLabel = [[UILabel alloc]init];
    [bgView addSubview:inforLabel];
    self.inforLab = inforLabel;
    inforLabel.font = [UIFont systemFontOfSize:13];
    inforLabel.textColor = SGColorRGBA(142, 146, 163, 1);
    inforLabel.numberOfLines = 2;
    [inforLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(4);
        make.left.equalTo(titleLabel);
        make.right.equalTo(titleLabel);
        make.height.mas_equalTo(20);
    }];
    
    UIView *line = [[UIView alloc]init];
    [bgView addSubview:line];
    line.backgroundColor = SGColorFromRGB(0xECECEC);
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bgView);
        make.right.equalTo(bgView);
        make.top.equalTo(inforLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(1);
        
    }];
    
    UILabel *timeLabel = [[UILabel alloc]init];
    [bgView addSubview:timeLabel];
    self.timeLab = timeLabel;
    timeLabel.font = [UIFont systemFontOfSize:13];
    timeLabel.textColor = SGColorRGBA(142, 146, 163, 1);
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel);
        make.right.equalTo(titleLabel);
        make.height.mas_equalTo(18);
        make.top.equalTo(line.mas_bottom).offset(10);
    }];
}

//- (void)setMessage:(PWMessage *)message {
//    _message = message;
//    self.titleLab.text = message.title;
//    self.inforLab.text = message.content;
//    self.timeLab.text = message.create_at;
//    CGRect infoRect = [self.inforLab.text boundingRectWithSize:CGSizeMake(kScreenWidth - 28, 50)
//                                                       options:NSStringDrawingUsesLineFragmentOrigin
//                                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}
//                                                       context:nil];
//
//    CGFloat height = infoRect.size.height;
//    if([self.inforLab.text isEqual:@""]){
//        height=0;
//    }
//    [self.inforLab mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(height);
//    }];
//
//    CGRect titleRect = [self.titleLab.text boundingRectWithSize:CGSizeMake(kScreenWidth - 28, 60)
//       options:NSStringDrawingUsesLineFragmentOrigin
//    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}
//       context:nil];
//
//
//    CGRect rect = self.frame;
//    rect.size.height = height+titleRect.size.height + 80;
//    self.frame = rect;
//
//}

-(void)hideContent:(BOOL)hide{
    self.titleLab.text = _message.title;
    self.inforLab.text=hide?@"":_message.content;
    self.timeLab.text = _message.create_time;
    CGRect infoRect = [self.inforLab.text boundingRectWithSize:CGSizeMake(kScreenWidth - 28, 50)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}
                                                       context:nil];

    CGFloat height = infoRect.size.height;
    if([self.inforLab.text isEqual:@""]){
        height=0;
    }
    [self.inforLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    CGRect titleRect = [self.titleLab.text boundingRectWithSize:CGSizeMake(kScreenWidth - 28, 60)
       options:NSStringDrawingUsesLineFragmentOrigin
    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}
       context:nil];
    

    CGRect rect = self.frame;
    rect.size.height = height+titleRect.size.height + 80;
    self.frame = rect;
}

-(void)showBadge{
    if (self.badge == nil) {
        UILabel *badgeView=[[UILabel alloc] init];
        [self.contentView addSubview:badgeView];
        self.badge = badgeView;
        badgeView.layer.backgroundColor = [UIColor colorWithRed:204/255.0 green:57/255.0 blue:105/255.0 alpha:1.0].CGColor;
            //圆角为宽度的一半
        badgeView.layer.cornerRadius = 4;
        [badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.titleLab.mas_left).offset(-2);
            make.height.mas_equalTo(8);
            make.width.mas_equalTo(8);
            make.top.equalTo(self.titleLab).offset(6);
        }];

    }
}

-(void)hideBadge{
    [self.badge removeFromSuperview];
    self.badge=nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
