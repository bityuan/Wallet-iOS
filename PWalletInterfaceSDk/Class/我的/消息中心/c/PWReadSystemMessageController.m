//
//  PWReadSystemMessageController.m
//  PWallet
//
//  Created by 杨威 on 2019/11/5.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWReadSystemMessageController.h"

@interface PWReadSystemMessageController ()
@end

@implementation PWReadSystemMessageController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SGColorRGBA(247, 247, 251, 1);
    self.title = @"系统消息".localized;
    [self initMessageView];
}

-(void)initMessageView{
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.left.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(isIPhoneXSeries ? 34 : 10));
        make.width.mas_equalTo(kScreenWidth);
    }];
    
    CGFloat left = (kScreenWidth - 336) / 2.0;
    
    UILabel *title = [[UILabel alloc] init];
    title.frame = CGRectMake(left,23,336,0);
    title.numberOfLines = 2;
    [scrollView addSubview:title];
    NSString *titleText=IS_BLANK(self.message.title)?@"":self.message.title;
    NSMutableAttributedString *titleString=[[NSMutableAttributedString alloc]initWithString:titleText attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size:16],NSForegroundColorAttributeName: [UIColor colorWithRed:51/255.0 green:54/255.0 blue:73/255.0 alpha:1.0]}];
    title.text=titleText;
    title.attributedText = titleString;
    title.textAlignment = NSTextAlignmentLeft;
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(scrollView).offset(23);
        make.left.equalTo(scrollView).offset(left);
        make.width.mas_equalTo(336);
//        make.height.mas_equalTo(45);
    }];
    [title sizeToFit];


    UILabel *time = [[UILabel alloc] init];
    time.frame = CGRectMake(left,91,131,18);
    time.numberOfLines = 0;
    [scrollView addSubview:time];
    NSString *timeText=IS_BLANK(self.message.create_time)?@"":self.message.create_time;
    NSMutableAttributedString *timeString = [[NSMutableAttributedString alloc] initWithString:timeText attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:13],NSForegroundColorAttributeName: [UIColor colorWithRed:142/255.0 green:146/255.0 blue:163/255.0 alpha:1.0]}];
    time.text=timeText;
    time.attributedText = timeString;
    time.textAlignment = NSTextAlignmentCenter;
    [time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(title.mas_bottom).offset(23);
        make.left.equalTo(title.mas_left);
        make.height.mas_equalTo(18);
    }];


    UILabel *article = [[UILabel alloc] init];
//    article.frame = CGRectMake((kScreenWidth-336)/2,114,336,399);
    article.numberOfLines = 0;
    article.font = [UIFont systemFontOfSize:15];
    [scrollView addSubview:article];
    NSString *artText = IS_BLANK(self.message.content) ? @"" : self.message.content;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.lineSpacing = 10;
//    paragraphStyle.paragraphSpacing = 15;
//    paragraphStyle.firstLineHeadIndent = 16;
    NSMutableAttributedString *artString = [[NSMutableAttributedString alloc] initWithString:artText attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:15],NSForegroundColorAttributeName: [UIColor colorWithRed:142/255.0 green:146/255.0 blue:163/255.0 alpha:1.0],NSParagraphStyleAttributeName:paragraphStyle}];
    article.attributedText = artString;
    article.textAlignment = NSTextAlignmentJustified;
    
    article.frame = CGRectMake(4, 0, 334, 0);
    [article sizeToFit];
    
    [article mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(time.mas_bottom).offset(23);
        make.left.equalTo(title.mas_left).offset(-4);
//        make.bottom.equalTo(self.view).offset(-kIphoneXBottomOffset);
        make.width.mas_equalTo(344);
    }];
    CGFloat height = title.frame.size.height + time.frame.size.height + article.frame.size.height+69;
    CGSize size = {kScreenWidth,height};
    scrollView.contentSize = size;
}

@end
