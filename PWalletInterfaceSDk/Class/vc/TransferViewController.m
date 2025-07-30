//
//  TransferViewController.m
//  PWallet
//
//  Created by 宋刚 on 2018/5/29.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "TransferViewController.h"

#import "TransferTopView.h"
#import "TransferMidView.h"
#import "TransferBottomView.h"
#import "PWTransferNoteView.h"
#import "PWNewInfoAlertView.h"

#import "PWSignalCoinRecordView.h"

#import "SGNetWork.h"
#include <CommonCrypto/CommonCrypto.h>
#import "PWSingelCoinTransListViewController.h"
#import "PWTransTipAlertView.h"
#import <YYModel/YYModel.h>
#import "STPickerSingle.h"
#import "PWBtyDomainNameOrAddressView.h"
#import "PWContactsController.h"
#import "JKBigInteger.h"
#import "PWContractRequest.h"

NSString *const kInitVector = @"33878402";

NSString *const DESKey = @"008f80e79e6b8c6a500e54e216e38ac2";

static NSString * const XYFeePri            = @"";
static NSString * const WFeePri             = @"";
static NSString * const DouziFeePri         = @"";
static NSString * const StoFeePri           = @"";

@interface TransferViewController ()<STPickerSingleDelegate>

@property (nonatomic,copy) NSString *execerp;
@property (nonatomic,copy) NSString *prikeyp;

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) TransferTopView *topView;
@property (nonatomic,strong) TransferMidView *midView;
@property (nonatomic,strong) TransferBottomView *bottomView;
@property (nonatomic, strong) PWTransferNoteView *cloudNoteView;
@property (nonatomic,strong) UIButton *bottomBtn;
@property (nonatomic,strong) dispatch_source_t timer;
@property (nonatomic,assign) CGFloat feeValue;
@property (nonatomic,copy) NSString *feeAddress;
@property (nonatomic,copy) NSString *coins_name;
@property (nonatomic,copy) NSString *tokensymbol;
@property (nonatomic,assign) CGFloat btyFeeValue;

@property (nonatomic, strong) PWSignalCoinRecordView *coinRecordView;
@property (nonatomic, assign) NSInteger recordCount;
@property (nonatomic, assign) BOOL showTip;

@property(nonatomic,copy)NSString *fromAddress;
@property(nonatomic,copy)NSString *toAddress;

@property (nonatomic, strong) UIButton *nftBtn;
@property (nonatomic, strong) NSArray *nftIdArray;
@property (nonatomic, strong) NSString *selectedNftId;

@property (nonatomic, strong) PWBtyDomainNameOrAddressView *domainView;
@property (nonatomic, strong) NSString *gasPrice;

@end

@implementation TransferViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hideSameAlert"];
    [self createView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        // Fallback on earlier versions
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    [self requestWithHold];
//    if ([self.coin.coin_chain isEqualToString:@"ETH"] && [self.coin.coin_type isEqualToString:@"ETH"]) {
//        [self getGasPrice];
//    } else if ([self.coin.coin_chain isEqualToString:@"BNB"] && [self.coin.coin_type isEqualToString:@"BNB"]){
//        [self getGasPrice];
//    }else{
        [self requestFee];
//    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self openGCDBalance];
    });
   
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopGCDBalance];
}

- (void)createView {
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    self.showMaskLine = false;
    self.view.backgroundColor = CMColorFromRGB(0xFFFFFF);
    
    [self.view addSubview: self.scrollView];
    [self.scrollView addSubview: self.topView];
    WEAKSELF
    self.topView.choiceNFTIDBlock = ^(UIButton *btn) {
        weakSelf.nftBtn = btn;
        [weakSelf showMoreNFTID];
    };
    [self.scrollView addSubview: self.midView];
    
    self.midView.midViewBlock = ^(NSString *str) {
        
        if (str.length != 0) {
            if ([weakSelf needDomain]) {
                [weakSelf getBtyDomainNameOrAddressWithInput:str];
            }else{
                [weakSelf getRecodeCountWithAddr:str];
            }
        }
    };
    if (![self.coin.coin_chain isEqualToString:@"TRX"]) {
        [self.scrollView addSubview: self.bottomView];
    }
    [self.scrollView addSubview: self.cloudNoteView];
   
    [self.view addSubview: self.bottomBtn];
    
    // scrollView
    CGFloat scrollViewBottom = (isIPhoneXSeries)?74 + kIphoneXBottomOffset:74;
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-scrollViewBottom);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat scrollViewContentHeight = self.cloudNoteView.frame.size.height + self.cloudNoteView.frame.origin.y;
        self.scrollView.contentSize = CGSizeMake(kScreenWidth, scrollViewContentHeight);
    });
    
    // midView
    [self.midView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(self.scrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(162);
    }];
    
    // topView
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.midView.mas_bottom);
        make.left.mas_equalTo(self.scrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(110);
    }];
    if (![self.coin.coin_chain isEqualToString:@"TRX"]) {
        if(_coin.isBtyChild)
        {
            // BTY下的token币需要特殊处理
            if (self.coins_name.length != 0 && self.coins_name != nil)
            {
                
                [self.bottomView setHiddenSlider:YES];
                [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.topView.mas_bottom);
                    make.left.mas_equalTo(self.scrollView);
                    make.width.mas_equalTo(kScreenWidth);
                    make.height.mas_equalTo(50);
                }];
                
            }
            else
            {
                [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.topView.mas_bottom);
                    make.left.mas_equalTo(self.scrollView);
                    make.width.mas_equalTo(kScreenWidth);
                    make.height.mas_equalTo(140);
                }];
                
            }
        }
        else if ([_coin.coin_chain isEqualToString:@"ETH"] && ![_coin.coin_platform isEqualToString:@"ethereum"]){
            [self.bottomView setHiddenSlider:YES];
            [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.topView.mas_bottom);
                make.left.mas_equalTo(self.scrollView);
                make.width.mas_equalTo(kScreenWidth);
                make.height.mas_equalTo(50);
            }];
        }else if ([_coin.coin_chain isEqualToString:@"WW"]){
            [self.bottomView setHiddenSlider:YES];
            [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.topView.mas_bottom);
                make.left.mas_equalTo(self.scrollView);
                make.width.mas_equalTo(kScreenWidth);
                make.height.mas_equalTo(50);
            }];
        }else if ([_coin.coin_chain isEqualToString:@"ETH"] && [_coin.coin_platform isEqualToString:@"ethereum"] && ![_coin.coin_type isEqualToString:@"ETH"]){
            [self.bottomView setHiddenSlider:YES];
            [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.topView.mas_bottom);
                make.left.mas_equalTo(self.scrollView);
                make.width.mas_equalTo(kScreenWidth);
                make.height.mas_equalTo(50);
            }];
        }
        else{
            
            
            // bottomView
            [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.topView.mas_bottom);
                make.left.mas_equalTo(self.scrollView);
                make.width.mas_equalTo(kScreenWidth);
                make.height.mas_equalTo(140);
            }];
        }
        // 上链备注
        [self.cloudNoteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bottomView.mas_bottom);
            make.left.mas_equalTo(self.scrollView);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(80);
        }];
    }else{
        // 上链备注
        [self.cloudNoteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.topView.mas_bottom);
            make.left.mas_equalTo(self.scrollView);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(80);
        }];
    }
   
    // 确定按钮
    CGFloat bottomBtnBottom = (isIPhoneXSeries)?30 + kIphoneXBottomOffset:30;
    
    [self.bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.bottom.equalTo(self.view).offset(-bottomBtnBottom);
        make.height.mas_equalTo(44);
    }];
    
    [self addAction];
}

- (void)showMoreNFTID
{
    if (self.nftIdArray.count != 0) {
        [self showMorenftid:self.nftIdArray];
        return;
    }
    
    [self showProgressWithMessage:@""];
    CoinPrice *coinPrice = [[PWDataBaseManager shared] queryCoinPriceBasedOn:self.coin.coin_type platform:self.coin.coin_platform andTreaty:self.coin.treaty];
    
    [PWNFTRequest requestNFTTokenIdListWithCoinType:self.coin.coin_chain
                                               from:self.coin.coin_address
                                       contractAddr:coinPrice.coinprice_heyueAddress
                                            success:^(id  _Nonnull object) {
        [self hideProgress];
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:object options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"result is %@",result);
        if (![result[@"result"] isKindOfClass:[NSNull class]]) {
            self.nftIdArray = result[@"result"];
            
            [self showMorenftid:self.nftIdArray];
        }else{
            [self showCustomMessage:@"暂无此NFT".localized hideAfterDelay:2.f];
        }
        
    } failure:^(NSString * _Nullable errorMsg) {
        [self hideProgress];
    }];
}

- (void)showMorenftid:(NSArray *)array
{
    [self.view endEditing:YES];
    STPickerSingle *pick = [[STPickerSingle alloc] init];
    pick.widthPickerComponent = 200;
    [pick setArrayData:[NSMutableArray arrayWithArray:array]];
    [pick setTitle:@"选择编号".localized];
    [pick setDelegate:self];
    
    [pick showWithView:self.view];
}

- (void)pickerSingle:(STPickerSingle *)pickerSingle selectedTitle:(NSString *)selectedTitle
{
    self.selectedNftId = selectedTitle;
    [self.nftBtn setTitle:[NSString stringWithFormat:@"编号 %@".localized,selectedTitle] forState:UIControlStateNormal];
}

#pragma mark -- nft转账
- (void)transForNFTWithText:(NSString *)passwd
{
#warning 需要判断一下手续费够不够
//    CGFloat fee = [self.bottomView getFee];
    [self showProgressWithMessage:@""];
    CoinPrice *coinPrice = [[PWDataBaseManager shared] queryCoinPriceBasedOn:self.coin.coin_type platform:self.coin.coin_platform andTreaty:self.coin.treaty];
    [PWNFTRequest nftTransferWithoinType:self.coin.coin_chain
                                    from:self.coin.coin_address
                                      to:self.toAddress
                            contractAddr:coinPrice.coinprice_heyueAddress
                                 tokenId:self.selectedNftId
                                     fee:0.001
                                 success:^(id  _Nonnull object) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:object options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"result is %@",result);
        [self hideProgress];
        if (![result[@"error"] isKindOfClass:[NSNull class]]) {
            [self showCustomMessage:result[@"error"] hideAfterDelay:2.f];
        }else{
            NSData *createData = WalletapiHexTobyte(result[@"result"]);
            if ([createData isEqual:[NSNull null]] || createData == nil) {
                [self showCustomMessage:@"转币失败".localized hideAfterDelay:2.f];
                return;
            }
            
            NSError *error;
            LocalWallet *wallet = [[PWDataBaseManager shared] queryWalletIsSelected];
            NSString *remembercode = [GoFunction deckey:wallet.wallet_remembercode password:passwd];//助记词
           
            WalletapiHDWallet *hdWallet = [GoFunction goCreateHDWallet:self.coin.coin_chain  rememberCode:remembercode];
            
            NSString *priKey = [[hdWallet newKeyPriv:0 error:&error] hexString];
            
            NSString *signedData = [GoFunction goWalletSignRawTransaction:self.coin.coin_chain
                                                                 platform:self.coin.coin_platform
                                                             unSignedData:createData
                                                                  privKey:priKey
                                                                andTreaty:self.coin.treaty];
            
            NSString *signTx = signedData;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
    #pragma mark =========在这============
                NSError *error;
                NSData *resultData = [GoFunction goWalletSendRawTransaction:self.coin.coin_chain
                                                                   platform:self.coin.coin_platform
                                                                     signTx:signTx
                                                                  andTreaty:self.coin.treaty];
                if ([resultData isKindOfClass:[NSNull class]])
                {
                    [self showCustomMessage:@"转币失败".localized hideAfterDelay:2.0];
                   return;
                }
                NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableLeaves error:&error];
                
                if (resultDic[@"result"] == nil || [resultDic[@"result"] isEqual:[NSNull null]]) {
                    NSLog(@"resultDic==%@",resultDic);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showCustomMessage:@"转币失败".localized hideAfterDelay:2.0];
                    });
                }else{
                   
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [CommonFunction playAudioFile];
                       
                        [self showCustomMessage:@"转币成功".localized hideAfterDelay:2.0];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            [self.view endEditing:YES];
                            [self.navigationController popViewControllerAnimated:YES];
                        });
                    });
                }
                NSLog(@"__ERROR：%@",error);
                NSLog(@"__结果：%@",[[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding]);
                
            });
        }
    } failure:^(NSString * _Nonnull errorMsg) {
        [self hideProgress];
        [self showCustomMessage:errorMsg hideAfterDelay:2.f];
    }];
}
// 绑定数据、事件
- (void)addAction {
    
    self.midView.coin = _coin;
    [self.midView setDestinationAddress:_addressStr];
    
    if(self.pwcontact != nil){
        self.midView.index = self.selectIndex;
        self.midView.contact = _pwcontact;
    }
    
    self.topView.coin = _coin;
    self.topView.scanMoney = _moneyStr;
    self.bottomView.coin = _coin;
    
    WEAKSELF
   
    self.cloudNoteView.didExplainMessageHandle = ^{
        [weakSelf.view endEditing:true];
        PWNewInfoAlertView *view = [[PWNewInfoAlertView alloc]initWithTitle:@"上链备注".localized message:@"上链备注：信息上链，可以在链上查询".localized buttonName:@"知道了".localized];
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    };
    
    [self.midView addContactTarget:self action:@selector(friendAction) forControlEvents:UIControlEventTouchUpInside];
    [self.midView addScanTarget:self action:@selector(scanAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBtn addTarget:self action:@selector(inputPwd) forControlEvents:UIControlEventTouchUpInside];
    if (_addressStr.length == 0)
    {
        // 不是从专属地址过来的。可以点击输入
        [self.topView setKeybordBtn:self.bottomBtn action:@selector(inputPwd)];
        [self.midView setKeybordBtn:self.bottomBtn action:@selector(inputPwd)];
    }
    
   
    [self.cloudNoteView setKeybordBtn:self.bottomBtn action:@selector(inputPwd)];
}

#pragma mark- 获取地址转币次数
- (void)getRecodeCountWithAddr:(NSString *)addr
{
    NSString *platformStr = self.coin.coin_platform;
    NSString *coinType = self.coin.coin_type;
    CoinPrice *coinPrice = [[PWDataBaseManager shared] queryCoinPriceBasedOn:coinType platform:platformStr andTreaty:self.coin.treaty];
    NSString *tokenSymbol = coinType;
    
    if (coinPrice.treaty == 2)
    {
        tokenSymbol = [NSString stringWithFormat:@"%@.coins",coinPrice.coinprice_platform];
    }
    else
    {
        if ([coinPrice.coinprice_chain isEqualToString:@"BTY"] && ![coinPrice.coinprice_platform isEqualToString:@"bty"]) {
            NSString *platformStr = coinPrice.coinprice_platform;
            tokenSymbol = [NSString stringWithFormat:@"%@.%@",platformStr,coinType];
        }
    }
    
    if ([coinPrice.coinprice_chain isEqualToString:coinType]) {
        tokenSymbol = @"";
    }
    
    NSDictionary *payload = @{@"cointype":self.coin.coin_chain,
                              @"tokensymbol":tokenSymbol,
                              @"from":self.coin.coin_address,
                              @"to":addr
    };
    
    NSDictionary *rawdata = @{@"method":@"QueryTxHistoryCount",
                              @"payload":payload};
    
    NSDictionary *infoParam = @{@"cointype":self.coin.coin_chain,
                                @"tokensymbol":tokenSymbol,
                                @"rawdata":rawdata
    };
    NSDictionary *param = @{@"id":@1,
                            @"method":@"Wallet.Transport",
                            @"params":@[infoParam]
    };
    
    [[SGNetWork defaultManager] sendRequestMethod:HTTPMethodPOST
                                        serverUrl:GoNodeUrl
                                          apiPath:@""
                                       parameters:param
                                         progress:nil
                                          success:^(BOOL isSuccess, id  _Nullable responseObject) {
        NSLog(@"reply json %@",responseObject);
        NSDictionary *responseObjects = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if ([responseObjects[@"result"] isKindOfClass:[NSNull class]]) {
            return;
        }
        self.recordCount = [responseObjects[@"result"] integerValue];

        if (self.coinRecordView) {
            [self.coinRecordView removeFromSuperview];
            self.coinRecordView = nil;
        }
        self.coinRecordView = [[PWSignalCoinRecordView alloc] init];
        [self.scrollView addSubview:self.coinRecordView];
        WEAKSELF
        // 查看历史转账记录
        self.coinRecordView.recordListBlock = ^{
            PWSingelCoinTransListViewController *vc = [[PWSingelCoinTransListViewController alloc] init];
            vc.selectedCoin = weakSelf.coin;
            vc.toAddr = addr;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
        self.coinRecordView.recordCount = self.recordCount;
        
        [self.coinRecordView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.midView.mas_bottom);
            make.left.equalTo(self.scrollView);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(45);
        }];
        
        [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.coinRecordView.mas_bottom);
            make.left.mas_equalTo(self.scrollView);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(110);
        }];
    } failure:^(NSString * _Nullable errorMessage) {
        
    }];
}

- (void)getBtyDomainNameOrAddressWithInput:(NSString *)inputStr
{
    
   
   
    // 域名转账
    // type 记录类型 1-地址类型 2-身份类型 9-自定义，默认为地址
    // key 解析关键字，正向为域名，反向为地址或取值
    // kind 正向（0） 反向（1）解析，默认为正向
    NSInteger kind = [inputStr containsString:@"."] ? 0 : 1;
    if(kind == 0){
        NSInteger count = [[inputStr mutableCopy] replaceOccurrencesOfString:@"."
                                                                  withString:@"a"
                                                                     options:NSLiteralSearch
                                                                       range:NSMakeRange(0, [inputStr length])];
        if (count == 1){
            NSString *pre = [self getDomainNamePre];
            inputStr = [pre stringByAppendingString:inputStr];
        }else{
            // do nothing
        }
    }
    
    
    NSString *url = @"https://dns.bityuan.com/dns/dns/resolve";
    NSDictionary *param = @{@"type":@1,@"key":inputStr,@"kind":@(kind)};
    [PWNetworkingTool getRequestWithUrl:url
                             parameters:param
                           successBlock:^(id object) {
        NSLog(@"域名所指向的地址是：%@",object);
        NSArray *addr = object;
        if (addr.count == 0) {
            if (![inputStr containsString:@"."]) {
                [self getRecodeCountWithAddr:inputStr];
            }
            
            return;
        }
        WEAKSELF
        self.domainView = [[PWBtyDomainNameOrAddressView alloc] initWithData:addr];
        self.domainView.domainNameOrAddressChoiceBlock = ^(NSString * _Nonnull str) {
            if (kind == 0) {
                [weakSelf.midView setDestinationAddress:str];
            }else{
                weakSelf.midView.addressText.text = str;
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf getBtyDomainNameOrAddressWithInput:str];
            });
        };
        [self.scrollView addSubview:self.domainView];
        [self.domainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.midView.mas_bottom);
            make.left.equalTo(self.scrollView);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(44);
        }];
        
        [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.domainView.mas_bottom);
            make.left.mas_equalTo(self.scrollView);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(110);
        }];
    } failureBlock:^(NSError *error) {
        if (![inputStr containsString:@"."]) {
            [self getRecodeCountWithAddr:inputStr];
        }
    }];
    
}

- (BOOL)needDomain
{
    if([self.coin.coin_type isEqualToString:@"BTY"])
    {
        return YES;
    }
    else if ([self.coin.coin_chain isEqualToString:@"ETH"] || [self.coin.coin_type isEqualToString:@"ETH"])
    {
        return YES;
    }
    else if ([self.coin.coin_chain isEqualToString:@"BNB"] || [self.coin.coin_type isEqualToString:@"BNB"])
    {
        return YES;
    }
    else if ([self.coin.coin_chain isEqualToString:@"TRX"] || [self.coin.coin_type isEqualToString:@"TRX"])
    {
        return YES;
    }
    else if ([self.coin.coin_chain isEqualToString:@"BTC"] || [self.coin.coin_type isEqualToString:@"BTC"])
    {
        return YES;
    }
    
    return NO;
}

// 获取域名前缀
- (NSString *)getDomainNamePre
{
    if([self.coin.coin_chain isEqualToString:@"BTY"] || [self.coin.coin_type isEqualToString:@"BTY"])
    {
        return @"bty.";
    }
    else if ([self.coin.coin_chain isEqualToString:@"ETH"] || [self.coin.coin_type isEqualToString:@"ETH"])
    {
        return @"eth.";
    }
    else if ([self.coin.coin_chain isEqualToString:@"BNB"] || [self.coin.coin_type isEqualToString:@"BNB"])
    {
        return @"bnb.";
    }
    else if ([self.coin.coin_chain isEqualToString:@"TRX"] || [self.coin.coin_type isEqualToString:@"TRX"])
    {
        return @"trx.";
    }
    else if ([self.coin.coin_chain isEqualToString:@"BTC"] || [self.coin.coin_type isEqualToString:@"BTC"])
    {
        return @"btc.";
    }
    
    return @"";
}

#pragma mark Action

// 转币验证
- (void)inputPwd {
    
    [self.view endEditing:true];
    
    if (self.coin.coin_type_nft == 1) {
        // NFT转币
        self.toAddress = [self.midView getToAddress];//接收方地址
        if ([self.coin.coin_address isEqualToString:self.toAddress]) {
            [self showCustomMessage:@"收币地址和发币地址一致".localized hideAfterDelay:2.0];
            return;
        }
        if (self.toAddress.length == 0 || self.toAddress == nil) {
            [self showCustomMessage:@"请输入收币地址".localized hideAfterDelay:2.f];
            return;
        }
        if (self.selectedNftId == nil || self.selectedNftId.length == 0) {
            [self showCustomMessage:@"请选择编号".localized hideAfterDelay:2.f];
            return;
        }
        LocalWallet *selectedWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
        if (self.walletId != 0) {
            selectedWallet = [[PWDataBaseManager shared] queryWallet:self.walletId];
        }else{
            selectedWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
        }
        [self authWithPswwdwithWallet:selectedWallet];
        return;
    }
    
    NSString *toAddress = [self.midView getToAddress];//接收方地址
    if ([self needDomain]) {
        if ([toAddress containsString:@"."])
        {
            // 域名转账
            NSString *url = @"https://dns.bityuan.com/dns/dns/resolve";
            // type 记录类型 1-地址类型 2-身份类型 9-自定义，默认为地址
            // key 解析关键字，正向为域名，反向为地址或取值
            // kind 正向（0） 反向（1）解析，默认为正向
            [self showProgressWithMessage:@""];
            NSDictionary *param = @{@"type":@1,@"key":toAddress,@"kind":@0};
            [PWNetworkingTool getRequestWithUrl:url
                                     parameters:param
                                   successBlock:^(id object) {
                NSLog(@"域名所指向的地址是：%@",object);
                NSArray *addr = object;
                
                [self hideProgress];
                self.toAddress = addr.firstObject;
                if (self.toAddress.length == 0) {
                    [self showCustomMessage:@"域名解析失败，请查看域名是否正确".localized hideAfterDelay:2.f];
                    return;
                }
                [self forwardTrans];
                
            } failureBlock:^(NSError *error) {
                [self showCustomMessage:@"域名解析失败，请稍后再试".localized hideAfterDelay:2.f];
                [self hideProgress];
            }];
        }else{
            self.toAddress = [self.midView getToAddress];//接收方地址
            [self forwardTrans];
        }
    }else{
        self.toAddress = [self.midView getToAddress];//接收方地址
        [self forwardTrans];
    }
    
    
}

- (void)forwardTrans
{
    double inputMoney = [self.topView getInputMoney];//转币金额
    if (_coin.treaty == 1)
    {
        inputMoney = [self.topView getTokenInputMoney];
    }
    
    NSString *fromAddress = [self.midView getFromAddress];//发送方地址
    // 判断是否给同一个地址转一样的金额
    if (self.orderModel != nil) {
        if ([self.orderModel.toAddress isEqualToString:self.toAddress]
            && self.orderModel.coinNum == inputMoney ) {
            BOOL hideSameAlert = [[[NSUserDefaults standardUserDefaults] objectForKey:@"hideSameAlert"] boolValue];
            if (!hideSameAlert) {
                PWTransTipAlertView *tipAlertView = [[PWTransTipAlertView alloc] initWithTipStr:@"此交易与上一笔交易的地址、转账金额相同，请仔细核对！".localized];
                tipAlertView.tipBlock = ^{
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hideSameAlert"];
                };
                [tipAlertView show];
                return;
            }
        }
    }

    CoinPrice *coinPrice = [[PWDataBaseManager shared] queryCoinPriceBasedOn:_coin.coin_type platform:_coin.coin_platform andTreaty:_coin.treaty];
    
    
    if ([fromAddress isEqualToString:self.toAddress]) {
        [self showCustomMessage:@"收币地址和发币地址一致".localized hideAfterDelay:2.0];
        return;
    }
    
    if ([self.toAddress isEqualToString:@""] || self.topView.moneyText.text.length == 0) {
        [self showCustomMessage:@"金额或地址未输入".localized hideAfterDelay:2.0];
        return;
    }

    CGFloat fee = [self.coin.coin_chain isEqualToString:@"TRX"] ? 0 : [self.bottomView getFee];
    NSString *balanceStr = [CommonFunction removeZeroFromMoney:[NSString stringWithFormat:@"%f",_coin.coin_balance]];
    CGFloat allMoney = [balanceStr doubleValue];
    
    
    if(_coin.coin_type_nft == 10){ // 合约币
        
        self.fromAddress = fromAddress;
        if (allMoney < inputMoney) {
            [self showCustomMessage:@"余额不足".localized hideAfterDelay:2.f];
            return;
        }
        LocalWallet *selectedWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
        if (self.walletId != 0) {
            selectedWallet = [[PWDataBaseManager shared] queryWallet:self.walletId];
        }else{
            selectedWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
        }
        NSMutableDictionary *mudict = [[PWAppsettings instance] getWalletInfo];
        // 如果没有密码数据，指纹or面容支付没有开启
        if (mudict == nil) {
            [self authWithPswwdwithWallet:selectedWallet];
        }else{
            NSString *walletId = [NSString stringWithFormat:@"%ld",selectedWallet.wallet_id];
            NSString *passwd = [mudict objectForKey:walletId];
            if (passwd == nil)
            {
                // 如果当前钱包没有密码数据，指纹or面容支付没有开启
                [self authWithPswwdwithWallet:selectedWallet];
            }
            else
            {
                [self authPayWithPasswd:passwd localWallet:selectedWallet];
                return;
            }
        }
       
        
        return;
    }
    
    if ([_coin.coin_type isEqualToString:coinPrice.coinprice_chain]) {
        // 主链币
         if (allMoney < fee)
         {
             [self showCustomMessage:@"余额不足".localized hideAfterDelay:2.0];
             return;
         }
        
        if (inputMoney + fee > allMoney)
        {
            CGFloat money = _coin.coin_balance - fee;
            [self showCustomMessage:[NSString stringWithFormat:@"余额不足，最大可转出%f%@".localized,money,_coin.coin_type ] hideAfterDelay:2.f];
            self.topView.scanMoney = [NSString stringWithFormat:@"%.4f", money];

            return;
        }
        if ([_coin.coin_type isEqualToString:@"DCR"])
        {
            if (inputMoney <= fee)
            {
                [self showCustomMessage:@"转账金额不能小于矿工费".localized hideAfterDelay:2.0];
                return;
            }
        }
    }else if ([_coin.coin_platform isEqualToString:@"wwchain"]){
        if (fee > 0 && _coin.coin_balance < fee)
        {
            [self showCustomMessage:@"余额不足".localized hideAfterDelay:2.f];
            return;
        }
        
        if (inputMoney > allMoney) {
            // 余额不足
            [self showCustomMessage:[NSString stringWithFormat:@"余额不足，最大可转出%f%@".localized,allMoney,_coin.coin_type ] hideAfterDelay:2.f];
            
            self.topView.scanMoney = [NSString stringWithFormat:@"%.4f", allMoney];
            return;
        }
    }else if ([_coin.coin_chain isEqualToString:@"ETH"] && [_coin.coin_platform isEqualToString:@"ethereum"] && ![_coin.coin_type isEqualToString:@"ETH"]){
        if (fee > 0 && _coin.coin_balance < fee)
        {
            [self showCustomMessage:@"余额不足".localized hideAfterDelay:2.f];
            return;
        }
        
        if (inputMoney > allMoney) {
            // 余额不足
            [self showCustomMessage:[NSString stringWithFormat:@"余额不足，最大可转出%f%@".localized,allMoney,_coin.coin_type ] hideAfterDelay:2.f];
            
            self.topView.scanMoney = [NSString stringWithFormat:@"%.4f", allMoney];
            return;
        }
    }
    else if ([_coin.coin_chain isEqualToString:@"ETH"] && [_coin.coin_platform isEqualToString:@"yhchain"]){

        if(inputMoney < 1){
            [self showCustomMessage:@"最少转币1个".localized hideAfterDelay:2.f];
            return;
        }
        
        if (fee > 0 && _coin.coin_balance < fee)
        {
            [self showCustomMessage:@"余额不足".localized hideAfterDelay:2.f];
            return;
        }
        if (inputMoney > allMoney) {
            // 余额不足
            [self showCustomMessage:[NSString stringWithFormat:@"余额不足，最大可转出%f%@".localized,allMoney,_coin.coin_type ] hideAfterDelay:2.f];
            
            self.topView.scanMoney = [NSString stringWithFormat:@"%.4f", allMoney];
            return;
        }
        
    }
    else
    {
        if (_coin.treaty == 2) {
            // 是平行链的coins币
            if (_coin.isBtyChild) {
                if (allMoney < fee)
                {
                    [self showCustomMessage:@"余额不足".localized hideAfterDelay:2.0];
                    return;
                }

                if (inputMoney > allMoney) {
                    // 余额不足
                    [self showCustomMessage:[NSString stringWithFormat:@"余额不足，最大可转出%f%@".localized,allMoney,_coin.coin_type ] hideAfterDelay:2.f];
                    self.topView.scanMoney = [NSString stringWithFormat:@"%.4f", allMoney];
                    return;
                }
                
                
            }
        }
        else if (_coin.treaty == 1)
        {
            // coins的token币
            if (_coin.isBtyChild)
            {
                NSArray *coinDataArray =  [[PWDataBaseManager shared] queryCoinArrayBasedOnSelectedWalletID];
                LocalCoin *coin = [[LocalCoin alloc] init];
                for (LocalCoin *localCoin in coinDataArray) {
                    if ([localCoin.coin_platform isEqualToString:_coin.coin_platform]
                        && localCoin.treaty == 2)
                    {
                        coin = localCoin;
                        break;
                    }
                }
                
                // 如果没有找到对应的coins币，那么这个币所对应的就是BTY下的币，矿工费从自己的余额里扣
                if (coin.coin_platform == nil && coin.coin_type == nil)
                {
                    coin = _coin;
                }
                
                if (fee > 0 && coin.coin_balance < fee)
                {
                    [self showCustomMessage:@"余额不足".localized hideAfterDelay:2.f];
                    return;
                }
                
                if (inputMoney > _coin.coin_balance) {
                    [self showCustomMessage:@"余额不足".localized hideAfterDelay:2.0];
                    return;
                }
                
            }
            else
            {
                // 主链下的token币 YCC需要特殊处理
                if ([_coin.coin_type isEqualToString:@"YCC"] && ([_coin.coin_chain isEqualToString:@"ETH"]||[_coin.coin_chain isEqualToString:@"BTC"])) {
                    if (inputMoney > _coin.coin_balance) {
                        [self showCustomMessage:@"余额不足".localized hideAfterDelay:2.0];
                        return;
                    }

                }else if ([_coin.coin_type isEqualToString:@"BTY"] && ([_coin.coin_chain isEqualToString:@"ETH"])) {
                    if (allMoney < fee)
                    {
                        [self showCustomMessage:@"余额不足".localized hideAfterDelay:2.0];
                        return;
                    }
                   
                   if (inputMoney + fee > allMoney)
                   {
                       CGFloat money = _coin.coin_balance - fee;
                       [self showCustomMessage:[NSString stringWithFormat:@"余额不足，最大可转出%f%@".localized,money,_coin.coin_type ] hideAfterDelay:2.f];
                       self.topView.scanMoney = [NSString stringWithFormat:@"%.4f", money];

                       return;
                   }
                    if (inputMoney > _coin.coin_balance) {
                        [self showCustomMessage:@"余额不足".localized hideAfterDelay:2.0];
                        return;
                    }
                    
                }else if ([_coin.coin_type isEqualToString:@"WW"] && [_coin.coin_chain isEqualToString:@"WW"]){
                    if (inputMoney > _coin.coin_balance) {
                        [self showCustomMessage:@"余额不足".localized hideAfterDelay:2.0];
                        return;
                    }
                }
                else{
                    NSArray *coinDataArray =  [[PWDataBaseManager shared] queryCoinArrayBasedOnSelectedWalletID];
                    LocalCoin *coin = [[LocalCoin alloc] init];
                    for (LocalCoin *localCoin in coinDataArray) {
                        if ([localCoin.coin_chain isEqualToString:coinPrice.coinprice_chain] && [localCoin.coin_type isEqualToString:coinPrice.coinprice_chain])
                        {
                            // 主链币
                            coin = localCoin;
                            break;
                        }
                    }
                    
                    if (fee > 0 && coin.coin_balance < fee)
                    {
                        [self showCustomMessage:@"余额不足".localized hideAfterDelay:2.f];
                        return;
                    }
                }
            }
            
        }

    }
    
    self.fromAddress = fromAddress;
   
    LocalWallet *selectedWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
    if (self.walletId != 0) {
        selectedWallet = [[PWDataBaseManager shared] queryWallet:self.walletId];
    }else{
        selectedWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
    }
    
    NSMutableDictionary *mudict = [[PWAppsettings instance] getWalletInfo];
    // 如果没有密码数据，指纹or面容支付没有开启
    if (mudict == nil) {
        [self authWithPswwdwithWallet:selectedWallet];
    }else{
        NSString *walletId = [NSString stringWithFormat:@"%ld",selectedWallet.wallet_id];
        NSString *passwd = [mudict objectForKey:walletId];
        if (passwd == nil)
        {
            // 如果当前钱包没有密码数据，指纹or面容支付没有开启
            [self authWithPswwdwithWallet:selectedWallet];
        }
        else
        {
            [self authPayWithPasswd:passwd localWallet:selectedWallet];
        }
    }

}

#pragma mark -- 合约币转账
- (void)contratcorPay:(NSString *)passwd
{
    CGFloat fee = [self.bottomView getFee];
    double inputMoney = [self.topView getInputMoney];
    [self showProgressWithMessage:@""];
    WEAKSELF
    CoinPrice *coinPrice = [[PWDataBaseManager shared] queryCoinPriceBasedOn:_coin.coin_type platform:_coin.coin_platform andTreaty:_coin.treaty];
    
    [PWContractRequest createRawTranscationWithCoinType:_coin.coin_chain
                                            tokensymbol:_coin.coin_type
                                               fromAddr:self.fromAddress
                                                 toAddr:self.toAddress
                                                 amount:inputMoney
                                                    fee:fee
                                              tokenAddr:coinPrice != nil ? coinPrice.coinprice_heyueAddress : _coin.coin_pubkey
                                                success:^(id  _Nonnull object) {
        NSError *error;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:object options:NSJSONReadingAllowFragments error:&error];
        [self hideProgress];
        if (result[@"result"] == nil || [result[@"result"] isEqual:[NSNull null]]) {
            NSLog(@"resultDic==%@",result);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showCustomMessage:@"转币失败".localized hideAfterDelay:2.0];
            });
        }else{
//            txid = result[@"result"];
        
            
            NSData *createData = [NSJSONSerialization dataWithJSONObject:result[@"result"] options:NSJSONWritingPrettyPrinted error:nil];
            if ([createData isEqual:[NSNull null]] || createData == nil) {
                [self showCustomMessage:@"转账失败".localized hideAfterDelay:2.f];
                return;
            }
            LocalWallet *wallet = [[PWDataBaseManager shared] queryWalletIsSelected];
            NSString *remembercode = [GoFunction deckey:wallet.wallet_remembercode password:passwd];//助记词
            WalletapiHDWallet *hdWallet = [GoFunction goCreateHDWallet:weakSelf.coin.coin_chain rememberCode:remembercode];
           
            NSString *priKey = [[hdWallet newKeyPriv:0 error:&error] hexString];
            
            //
            NSString *signedData = [GoFunction goWalletSignRawTransaction:weakSelf.coin.coin_chain platform:@"" unSignedData:createData privKey:priKey andTreaty:weakSelf.coin.treaty];
            
            NSString *signTx = signedData;
//            NSDictionary *signDic = [NSJSONSerialization JSONObjectWithData:signedData options:NSJSONReadingMutableLeaves error:&error];
//            NSLog(@"sign dic %@",signDic);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
    #pragma mark =========在这============
                NSError *error;
                NSData *resultData = [GoFunction goWalletSendRawTransaction:[NSString stringWithFormat:@"%@$%@", weakSelf.coin.coin_chain,weakSelf.coin.coin_type] platform:@"" signTx:signTx andTreaty:weakSelf.coin.treaty];
                if ([resultData isKindOfClass:[NSNull class]] || resultData == nil)
                {
                    [self showCustomMessage:@"转账失败".localized hideAfterDelay:2.0];
                   return;
                }
                NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableLeaves error:&error];
                
                if (resultDic[@"result"] == nil || [resultDic[@"result"] isEqual:[NSNull null]]) {
                    NSLog(@"resultDic==%@",resultDic);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showCustomMessage:@"转账失败".localized hideAfterDelay:2.0];
                    });
                }else{
                    NSString *txid = resultDic[@"result"];
                
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [CommonFunction playAudioFile];
                        
                        [self showCustomMessage:@"转账成功".localized hideAfterDelay:2.0];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            [self.view endEditing:YES];
                            [self.navigationController popViewControllerAnimated:YES];
                        });
                    });
                }
                NSLog(@"__ERROR：%@",error);
                NSLog(@"__结果：%@",[[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding]);
            });
        }
        NSLog(@"__ERROR：%@",error);
        NSLog(@"__结果：%@",[[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding]);
    } failure:^(NSString * _Nonnull errorMsg) {
        [self hideProgress];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showCustomMessage:@"转币失败".localized hideAfterDelay:2.0];
        });
    }];
}

- (void)authPayWithPasswd:(NSString *)passwd localWallet:(LocalWallet *)wallet
{
    YZAuthID *authId = [[YZAuthID alloc] init];
    
    [authId yz_showAuthIDWithDescribe:nil block:^(YZAuthIDState state, NSError *error) {
        switch (state) {
            case YZAuthIDStateNotSupport:
            {
                NSLog(@"当前设备不支持TouchId、FaceId");
                [self authWithPswwdwithWallet:wallet];
            }
                break;
            case YZAuthIDStateSuccess:
            {
                NSLog(@"验证成功");
                if (self.coin.coin_type_nft == 10) { // 合约币
                    [self contratcorPay:passwd];
                } else{
                    NSString *passwdStr = [PWUtils decryptString:passwd];
                    [self transferAction:passwdStr];
                }
               
            }
                break;
            case YZAuthIDStateFail:
            {
                NSLog(@" 验证失败");
            }
                break;
            case YZAuthIDStateUserCancel:
            {
                NSLog(@"TouchID/FaceID 被用户手动取消");
            }
                break;
            case YZAuthIDStateInputPassword:
            {
                NSLog(@"用户不使用TouchID/FaceID,选择手动输入密码");
                [self authWithPswwdwithWallet:wallet];
            }
                break;
            case YZAuthIDStateSystemCancel:
            {
                NSLog(@"TouchID/FaceID 被系统取消 (如遇到来电,锁屏,按了Home键等)");
            }
                break;
            case YZAuthIDStatePasswordNotSet:
            {
                NSLog(@" TouchID/FaceID 无法启动,因为用户没有设置密码");
                [self authWithPswwdwithWallet:wallet];
            }
                break;
            case YZAuthIDStateTouchIDNotSet:
            {
                NSLog(@"TouchID/FaceID 无法启动,因为用户没有设置TouchID/FaceID");
                [self authWithPswwdwithWallet:wallet];
            }
                break;
            case YZAuthIDStateTouchIDNotAvailable:
            {
                NSLog(@"TouchID/FaceID 无效");
                [self authWithPswwdwithWallet:wallet];
            }
                break;
            case YZAuthIDStateTouchIDLockout:
            {
                NSLog(@"TouchID/FaceID 被锁定(连续多次验证TouchID/FaceID失败,系统需要用户手动输入密码)");
            }
                break;
            case YZAuthIDStateAppCancel:
            {
                NSLog(@"当前软件被挂起并取消了授权 (如App进入了后台等)");
            }
                break;
            case YZAuthIDStateInvalidContext:
            {
                NSLog(@" 当前软件被挂起并取消了授权 (LAContext对象无效)");
            }
                break;
            case YZAuthIDStateVersionNotSupport:
            {
                NSLog(@"系统版本不支持TouchID/FaceID (必须高于iOS 8.0才能使用)");
                [self authWithPswwdwithWallet:wallet];
            }
                break;
                
            default:
                break;
        }
    }];
}


- (NSString *)jsonStringWithDict:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

- (void)handleDataWithStr:(NSString *)str{
    NSString *coinType = _coin.coin_type;
    NSString *platStr = _coin.coin_platform;
    CoinPrice *coinPrice = [[PWDataBaseManager shared] queryCoinPriceBasedOn:coinType platform:_coin.coin_platform andTreaty:_coin.treaty];
    NSString *signTx = str;
    [self showProgressWithMessage:@""];
    __block NSString *txid = @"";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        NSData *resultData = [GoFunction goWalletSendRawTransaction:coinType platform:platStr signTx:signTx andTreaty:coinPrice.treaty];
        if ([resultData isKindOfClass:[NSNull class]])
        {
            [self showCustomMessage:@"转币失败".localized hideAfterDelay:2.0];
           return;
        }
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableLeaves error:&error];
        
        if (resultDic[@"result"] == nil || [resultDic[@"result"] isEqual:[NSNull null]]) {
            NSLog(@"resultDic==%@",resultDic);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showCustomMessage:@"转币失败".localized hideAfterDelay:2.0];
            });
        }else{
            txid = resultDic[@"result"];
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [CommonFunction playAudioFile];
                [self showCustomMessage:@"转币成功".localized hideAfterDelay:2.0];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.view endEditing:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            });
        }
    });
}


#pragma mark -- 弹出密码框支付
- (void)authWithPswwdwithWallet:(LocalWallet *)wallet
{

    WEAKSELF
    PWAlertController *alertVC = [[PWAlertController alloc] initWithTitle:@"请输入钱包密码".localized withTextValue:@"" leftButtonName:nil rightButtonName:@"确定".localized handler:^(ButtonType type,
                                                                                                                                                                              NSString *text) {
        if (type == ButtonTypeLeft) { }
        if (type == ButtonTypeRight) {
            if ([GoFunction checkPassword:text hash:wallet.wallet_password]) {
                if(wallet.wallet_issmall == 4){
                    // 找回钱包提取资产
                    [weakSelf crkSendtransferAction:text];
                }else{
                    if (self.coin.coin_type_nft == 1) {
                        [weakSelf transForNFTWithText:text];
                    }else if(self.coin.coin_type_nft == 10){
                        [self contratcorPay:text];
                    }else{
                        [weakSelf transferAction:text];
                    }
                }
            } else {
                [self showCustomMessage:@"密码错误".localized hideAfterDelay:2];
            }
        }
    }];
    alertVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self presentViewController:alertVC animated:false completion:nil];
    
    
    
}
#pragma mark - 找回钱包，从找回地址找回资产
// 找回钱包，从找回地址找回资产
- (void)crkSendtransferAction:(NSString *)password
{
    LocalWallet *wallet = [[PWDataBaseManager shared] queryWalletIsSelected];
    NSString *remembercode = [GoFunction deckey:wallet.wallet_remembercode password:password];//助记词
   
    NSString *priKey = remembercode;// 找回钱包存的助记词就是私钥
   
    NSError *error;
    WalletapiUtil *util = [[WalletapiUtil alloc] init];
    util.node = GoNodeUrl;
    WalletapiWalletRecover *recover = [[WalletapiWalletRecover alloc] init];
    WalletapiQueryRecoverParam *param = [[WalletapiQueryRecoverParam alloc] init];
    param.cointype = self.coin.coin_type;
    param.address = self.coin.coin_address;
    param.tokensymbol = @"";
    WalletapiWalletRecoverParam *recoverParam = [recover transportQueryRecoverInfo:param util:util error:&error];
    if(error != nil){
        [self showError:error hideAfterDelay:2.f];
        return;
    }
    
    recover.param = recoverParam;
    
    CGFloat fee = [self.bottomView getFee];
    double inputMoney = [self.topView getInputMoney];
    NSString *note = self.cloudNoteView.noteTextView.text;
    WalletapiWalletTx *walletTx = [[WalletapiWalletTx alloc] init];
    walletTx.cointype = self.coin.coin_type;
    walletTx.tokenSymbol = @"";
    WalletapiTxdata *txdata = [[WalletapiTxdata alloc] init];
    txdata.from = self.coin.coin_address;
    txdata.amount = inputMoney;
    txdata.fee = fee;
    txdata.note = note;
    txdata.to = self.toAddress;
    walletTx.tx = txdata;
    
    walletTx.util = util;
    
    
    NSData *ranTrawData = WalletapiCreateRawTransaction(walletTx, &error);
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:ranTrawData options:NSJSONReadingMutableLeaves error:&error];
    NSDictionary *jsonResult = result[@"result"];
    NSData *jsonData = [jsonResult yy_modelToJSONData];
   // 从找回地址提取资产
    WalletapiNoneDelayTxParam *noneDelayTxParam = [[WalletapiNoneDelayTxParam alloc] init];
    noneDelayTxParam.execer = @"none";
    noneDelayTxParam.addressID = recover.param.addressID;
    noneDelayTxParam.chainID = recover.param.chainID;
    noneDelayTxParam.fee = 0.002;
    NSData *noneDelayData = [recover createNoneDelayTx:noneDelayTxParam error:&error];
    NSString *signTx = [recover signRecoverTxWithRecoverKey:jsonData
                                             recoverPrivKey:priKey
                                                noneDelayTx:noneDelayData
                                                      error:&error ];
    
    WalletapiWalletSendTx *sendTx = [[WalletapiWalletSendTx alloc] init];
    sendTx.cointype = self.coin.coin_type;
    sendTx.signedTx = signTx;
    sendTx.tokenSymbol = @"";
    
     sendTx.util = util;
     NSData *sendRawTransactionData = WalletapiSendRawTransaction(sendTx, &error);
//    // 从控制地址提取资产
//    NSString *signTx = [recover signRecoverTxWithCtrKey:jsonData ctrPrivKey:priKey error:&error];
//    WalletapiWalletSendTx *sendTX = [[WalletapiWalletSendTx alloc] init];
//    sendTX.cointype = self.coin.coin_type;
//    sendTX.signedTx = signTx;
//    sendTX.tokenSymbol = @"";
//    sendTX.util = util;
//    NSData *sendRawTransactionData = WalletapiSendRawTransaction(sendTX, &error);
    if ([sendRawTransactionData isKindOfClass:[NSNull class]])
    {
        [self showCustomMessage:@"转币失败".localized hideAfterDelay:2.0];
       return;
    }
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:sendRawTransactionData options:NSJSONReadingMutableLeaves error:&error];
   
    if (resultDic[@"result"] == nil || [resultDic[@"result"] isEqual:[NSNull null]]) {
        NSLog(@"resultDic==%@",resultDic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showCustomMessage:@"转币失败".localized hideAfterDelay:2.0];
        });
    }else{
        NSString *jsonResults = resultDic[@"result"];
        NSLog(@"jsonResult------>%@",jsonResults);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [CommonFunction playAudioFile];
            
            [self showCustomMessage:@"转币成功".localized hideAfterDelay:2.0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self.view endEditing:YES];
                [self.navigationController popViewControllerAnimated:YES];
            });
        });
    }
    NSLog(@"__ERROR：%@",error);
    NSLog(@"__结果：%@",[[NSString alloc] initWithData:sendRawTransactionData encoding:NSUTF8StringEncoding]);
}

// 转币
- (void)transferAction:(NSString *)password {
    NSString *coinType = _coin.coin_type;
    NSString *platStr = _coin.coin_platform;
    CGFloat fee = [self.bottomView getFee];
    CoinPrice *coinPrice = [[PWDataBaseManager shared] queryCoinPriceBasedOn:coinType platform:_coin.coin_platform andTreaty:_coin.treaty];
    double inputMoney = [self.topView getInputMoney];
    if (_coin.treaty == 1)
    {
        inputMoney = [self.topView getTokenInputMoney];
    }
    
    //去掉地址中所有的空格和换行
    NSString *fromAddress = [[self.midView getFromAddress] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    NSString *note = self.cloudNoteView.noteTextView.text;
    NSError *error;
    
    LocalWallet *wallet = [[PWDataBaseManager shared] queryWalletIsSelected];
    NSString *remembercode = [GoFunction deckey:wallet.wallet_remembercode password:password];//助记词
   
    WalletapiHDWallet *hdWallet;
    // eth地址下的YCC 需要用eth的私钥进行转币   btc地址下的ycc 需要用btc的私钥进行转币
    if ([coinType isEqualToString:@"YCC"] && [coinPrice.coinprice_chain isEqualToString:@"ETH"])
    {
        hdWallet = [GoFunction goCreateHDWallet:@"ETH" rememberCode:remembercode];
    }
    else if ([coinType isEqualToString:@"YCC"] && [coinPrice.coinprice_chain isEqualToString:@"BTC"])
    {
        hdWallet = [GoFunction goCreateHDWallet:@"BTC" rememberCode:remembercode];
    }
    else if ([coinType isEqualToString:@"BTY"] && [coinPrice.coinprice_chain isEqualToString:@"ETH"])
    {
        hdWallet = [GoFunction goCreateHDWallet:@"ETH" rememberCode:remembercode];
    }
    else if ([coinPrice.coinprice_platform isEqualToString:@"yhchain"] && [coinPrice.coinprice_chain isEqualToString:@"ETH"])
    {
        // 元宝枫
        hdWallet = [GoFunction goCreateHDWallet:@"ETH" rememberCode:remembercode];
    }
    else
    {
        hdWallet = [GoFunction goCreateHDWallet:coinType rememberCode:remembercode];
    }
    
    NSString *priKey = [[hdWallet newKeyPriv:0 error:&error] hexString];
    if (wallet.wallet_issmall == 2)
    {
        // 私钥钱包的话，私钥直接就有。
        priKey = remembercode;
    }
    __block NSString *txid = @"";
    if ([coinPrice.coinprice_chain isEqualToString:@"BTY"] && ![coinPrice.coinprice_platform isEqualToString:@"bty"] && ![coinPrice.coinprice_platform isEqualToString:@"malltest"]) {
        
        WalletapiGsendTx *gtx = [[WalletapiGsendTx alloc] init];
        
        if (coinPrice.treaty == 2)
        {
            [gtx setCoinsForFee:NO];
            [gtx setFee:_btyFeeValue*3];
            [gtx setTokenFee:self.feeValue];
            [gtx setTokenFeeAddr:self.feeAddress];
        }
        else
        {
            // token币分两种情况来设置参数
            if (_coins_name.length != 0)
            {
                [gtx setCoinsForFee:YES];
                [gtx setFee:_btyFeeValue*3];
                [gtx setTokenFee:self.feeValue];
                [gtx setTokenFeeAddr:self.feeAddress];
            }
            else
            {
                [gtx setCoinsForFee:YES];
                [gtx setFee:fee];
                
            }
            
        }
        
        [gtx setAmount:inputMoney];
        [gtx setExecer:self.execerp];
        [gtx setNote:note];
        [gtx setTo:self.toAddress];
        [gtx setTxpriv:priKey];
        [gtx setFeepriv:self.prikeyp.length == 0 ? priKey : self.prikeyp];
        [gtx setTokenSymbol:self.tokensymbol];
        txid = [GoFunction goWalletSendRawTransaction_Douzi:gtx platfrom:platStr coinName:coinPrice.coinprice_name andTreaty:coinPrice.treaty];
        if (![txid isEqualToString:@""]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [CommonFunction playAudioFile];
                [self showCustomMessage:@"转币成功".localized hideAfterDelay:2.0];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [self.view endEditing:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showCustomMessage:@"转币失败".localized hideAfterDelay:2.0];
            });
        }
    }
    else if([coinPrice.coinprice_chain isEqualToString:@"ETH"] && ![coinPrice.coinprice_platform isEqualToString:@"ethereum"]){
    
        // ybf币
        WalletapiGsendTx *gtx = [[WalletapiGsendTx alloc] init];
        gtx.feepriv = @"6f0f84130c6e4c5a72fc0ff3d0a325f1e9826f74221754b4ae982a4e10071e35";
        gtx.to = self.toAddress;
        gtx.tokenSymbol = coinPrice.treaty == 1 ? [NSString stringWithFormat:@"%@.%@",coinPrice.coinprice_platform,_coin.coin_type]:[NSString stringWithFormat:@"%@.coins",coinPrice.coinprice_platform];
        gtx.execer = coinPrice.treaty == 1 ? [NSString stringWithFormat:@"user.p.%@.token",coinPrice.coinprice_platform]:[NSString stringWithFormat:@"user.p.%@.coins",coinPrice.coinprice_platform];
        gtx.amount = inputMoney;
        gtx.txpriv = priKey;
        gtx.fee = 0.003; // 消耗的BTY
        gtx.tokenFeeAddr = @"0x8610c906C2190FC98D04307D18c9ee4a110B968d"; // 扣的手续费接收地址
        gtx.tokenFee = fee; // 扣的手续费
        if(coinPrice.treaty == 2){
            gtx.coinsForFee = YES;
        }else{
            gtx.coinsForFee = NO;
            gtx.tokenFeeSymbol = coinType;
        }
        gtx.feeAddressID = 2;
        gtx.txAddressID = 2;
        
        txid = [GoFunction goWalletSendRawTransaction_Douzi:gtx platfrom:platStr coinName:coinPrice.coinprice_name andTreaty:coinPrice.treaty];
        if (![txid isEqualToString:@""]) {
            // 保存本地备注
           
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [CommonFunction playAudioFile];
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                [user setValue:[NSString stringWithFormat:@"%@|%@|%ld",self.fromAddress,self.toAddress,(long)self.coin.coin_id] forKey:@"fromtoAddrsss"];
                [user synchronize];
                [self showCustomMessage:@"转币成功".localized hideAfterDelay:2.0];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"kjSuccess" object:[NSString stringWithFormat:@"%@|%@|%ld",self.fromAddress,self.toAddress,(long)self.coin.coin_id]];
                    [self.view endEditing:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showCustomMessage:@"转币失败".localized hideAfterDelay:2.0];
            });
        }
    }
    else
    {
        NSData *result = [GoFunction goCreateRawTransaction:coinType platForm:platStr fromAddress:fromAddress toAddress:self.toAddress amount:inputMoney fee:fee note:note andTreaty:coinPrice.treaty];
        if (result == nil || [result isEqual:[NSNull null]]) {
            [self showCustomMessage:@"构造签名失败".localized hideAfterDelay:2.0];
            return;
        }
        NSDictionary *createDic = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:nil];
        if ([createDic[@"result"] isEqual:[NSNull null]] || createDic[@"result"] == nil) {
            if (![createDic[@"error"] isEqual:[NSNull null]] && createDic[@"error"] != nil) {
                [self showCustomMessage:@"转币失败".localized hideAfterDelay:2.0];
            }
            return;
        }
#pragma mark ========bug========
        NSData *createData = [NSJSONSerialization dataWithJSONObject:createDic[@"result"] options:NSJSONWritingPrettyPrinted error:nil];
        if ([createData isEqual:[NSNull null]] || createData == nil) {
            [self showCustomMessage:@"转币失败".localized hideAfterDelay:2.f];
            return;
        }
        NSString *signedData = [GoFunction goWalletSignRawTransaction:coinType platform:platStr unSignedData:createData privKey:priKey andTreaty:coinPrice.treaty];
        
        NSString *signTx = signedData;
        [self showProgressWithMessage:@""];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
#pragma mark =========在这============
            NSError *error;
            NSData *resultData = [GoFunction goWalletSendRawTransaction:coinType platform:platStr signTx:signTx andTreaty:coinPrice.treaty];
            if ([resultData isKindOfClass:[NSNull class]])
            {
                [self showCustomMessage:@"转币失败".localized hideAfterDelay:2.0];
               return;
            }
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableLeaves error:&error];
            
            if (resultDic[@"result"] == nil || [resultDic[@"result"] isEqual:[NSNull null]]) {
                NSLog(@"resultDic==%@",resultDic);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showCustomMessage:@"转币失败".localized hideAfterDelay:2.0];
                });
            }else{
                txid = resultDic[@"result"];
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [CommonFunction playAudioFile];
                    
                    [self showCustomMessage:@"转币成功".localized hideAfterDelay:2.0];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        [self.view endEditing:YES];
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                });
            }
            NSLog(@"__ERROR：%@",error);
            NSLog(@"__结果：%@",[[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding]);
        });
    }
    if([txid isEqualToString:@""])
    {
            return;
    }
}

// 二维码扫描
- (void)scanAction {
    [self.view endEditing:true];
    __weak typeof(self) weakself = self;
    ScanViewController *vc = [[ScanViewController alloc] init];
    [self.navigationController pushViewController:vc animated:true];
    vc.scanResult = ^(NSString *address) {
        if([address containsString:@":"] || [address containsString:@"?"])
        {
            address = [CommonFunction queryImTokenAddress:address];
        }
        else
        {
            if ([address containsString:@","])
            {
                NSArray *array = [address componentsSeparatedByString:@","];
                if (array.count == 3) {
                    //
                    address = [NSString stringWithFormat:@"%@",array[2]];
                    NSString *moneyStr = [NSString stringWithFormat:@"%@",array[1]];
                    self.topView.scanMoney = moneyStr;
                }
                else if (array.count == 2)
                {
                    address = [NSString stringWithFormat:@"%@",array[1]];
                    NSString *moneyStr = [NSString stringWithFormat:@"%@",array[0]];
                    self.topView.scanMoney = moneyStr;
                }
            }
            
        }
        
        [weakself.midView setDestinationAddress:address];
    };
}

- (void)friendAction{
    __weak typeof(self) weakself = self;
    PWContactsController *vc = [[PWContactsController alloc] init];
    vc.parentController = ContactParentTransfer;
    vc.transferCoinType = _coin.coin_type;
    [self.navigationController pushViewController:vc animated:YES];
   
    vc.selectContact = ^(PWContacts *contact) {
        weakself.midView.index = 10000;
        weakself.midView.contact = contact;
    };
   
}


#pragma mark 网络请求
- (void)requestFee {
    NSString *name = _coin.coin_chain;
    if ([_coin.coin_chain isEqualToString:@"ETH"] && ![_coin.coin_type isEqualToString:_coin.coin_chain]) {
            name = [NSString stringWithFormat:@"%@%@",_coin.coin_chain,@"TOKEN"];
    }
    if ([_coin.coin_type isEqualToString:@"YCC"]) {
        name = _coin.coin_type;
    }
    if ([_coin.coin_type isEqualToString:@"WW"]) {
        name = _coin.coin_type;
    }
    NSDictionary *param = @{@"name":name};
    [[SGNetWork defaultManager] sendRequestMethod:HTTPMethodGET serverUrl:WalletURL apiPath:@"/goapi/interface/fees/recommended" parameters:param progress:nil success:^(BOOL isSuccess, id  _Nullable responseObject) {
         NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
         NSLog(@"%@",result[@"msg"]);
        NSInteger code = [result[@"code"] integerValue];
        if(code == 0) {
            NSDictionary *dict = (NSDictionary *)result[@"data"];
            Fee *feeModel = [Fee yy_modelWithJSON:dict];
            self.bottomView.feeModel = feeModel;
            
        }else{
            
        }
    } failure:^(NSString * _Nullable errorMessage) {
        
    }];
}

- (void)requestWithHold{
    WEAKSELF
    
    CoinPrice *coinPrice = [[PWDataBaseManager shared] queryCoinPriceBasedOn:_coin.coin_type platform:_coin.coin_platform andTreaty:_coin.treaty];
    if ([coinPrice.coinprice_chain isEqualToString:@"BTY"] && ![coinPrice.coinprice_platform isEqualToString:@"bty"]) {
        
        NSDictionary *param = @{@"platform":_coin.coin_platform,@"coinname":_coin.coin_type};
        
        [[SGNetWork defaultManager] sendRequestMethod:HTTPMethodGET
                                            serverUrl:WalletURL
                                              apiPath:@"/interface/coin/get-with-hold"
                                           parameters:param
                                             progress:nil
                                              success:^(BOOL isSuccess, id  _Nullable responseObject) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            NSInteger code = [result[@"code"] integerValue];
            NSDictionary *dict = result[@"data"];
            if(code == 0 && ![dict isKindOfClass:[NSNull class]]) {
                weakSelf.execerp = result[@"data"][@"exer"];
                weakSelf.prikeyp = [self decodeDesWithString:result[@"data"][@"private_key"]];
                weakSelf.btyFeeValue = [result[@"data"][@"bty_fee"] doubleValue];
                weakSelf.feeAddress = result[@"data"][@"address"];
                weakSelf.tokensymbol = result[@"data"][@"tokensymbol"];
                weakSelf.coins_name = result[@"data"][@"coins_name"];
                weakSelf.feeValue = [result[@"data"][@"fee"] doubleValue];
                [self createView];
            }else{
                [self showCustomMessage:@"矿工费获取失败".localized hideAfterDelay:2.0];
                [weakSelf.navigationController popViewControllerAnimated:true];
            }
            
        } failure:^(NSString * _Nullable errorMessage) {
            
            [self showCustomMessage:errorMessage hideAfterDelay:2.0];
            [weakSelf.navigationController popViewControllerAnimated:true];
        }];
    }else if([coinPrice.coinprice_chain isEqualToString:@"ETH"] && ![_coin.coin_type isEqualToString:@"ETH"] &&[coinPrice.coinprice_platform isEqualToString:@"ethereum"]) {
        NSDictionary *param = @{@"platform":@"wwchain",@"coinname":_coin.coin_type};
        
        [[SGNetWork defaultManager] sendRequestMethod:HTTPMethodGET
                                            serverUrl:WalletURL
                                              apiPath:@"/interface/coin/get-with-hold"
                                           parameters:param
                                             progress:nil
                                              success:^(BOOL isSuccess, id  _Nullable responseObject) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            NSInteger code = [result[@"code"] integerValue];
            NSDictionary *dict = result[@"data"];
            if(code == 0 && ![dict isKindOfClass:[NSNull class]]) {
                weakSelf.execerp = result[@"data"][@"exer"];
                weakSelf.prikeyp = [self decodeDesWithString:result[@"data"][@"private_key"]];
                weakSelf.btyFeeValue = [result[@"data"][@"bty_fee"] doubleValue];
                weakSelf.feeAddress = result[@"data"][@"address"];
                weakSelf.tokensymbol = result[@"data"][@"tokensymbol"];
                weakSelf.coins_name = result[@"data"][@"coins_name"];
                weakSelf.feeValue = [result[@"data"][@"fee"] doubleValue];
                [self createView];
            }else{
                [self showCustomMessage:@"矿工费获取失败".localized hideAfterDelay:2.0];
                [weakSelf.navigationController popViewControllerAnimated:true];
            }
            
        } failure:^(NSString * _Nullable errorMessage) {
            
            [self showCustomMessage:errorMessage hideAfterDelay:2.0];
            [weakSelf.navigationController popViewControllerAnimated:true];
        }];
    }
}

#pragma mark - 获取gsaprice
- (void)getGasPrice{
    
    NSString *rpcurl = @"https://rpc.flashbots.net";
    if ([self.coin.coin_chain isEqualToString:@"ETH"]){
        rpcurl = @"https://rpc.flashbots.net";
    }else if ([self.coin.coin_chain isEqualToString:@"BNB"]){
        rpcurl = @"https://bsc.publicnode.com";
    }
    
    NSDictionary *params = @{@"id":@1,
                             @"jsonrpc":@"2.0",
                             @"method":@"eth_gasPrice",
                             @"params":@[]};
    
    [[SGNetWork defaultManager] sendRequestMethod:HTTPMethodPOST
                                        serverUrl:rpcurl
                                          apiPath:@""
                                       parameters:params
                                         progress:nil
                                          success:^(BOOL isSuccess, id  _Nullable responseObject) {
        
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"eth_gasPrice is %@",jsonData);
        NSString *result = jsonData[@"result"];
        if(result != nil || result.length != 0){
            self.gasPrice = [self sixteenToTen:result];
        }
        self.bottomView.gasPrice = self.gasPrice;
        self.bottomView.coin = self.coin;
        
    } failure:^(NSString * _Nullable errorMessage) {
        NSLog(@"error is %@",errorMessage);
        
    }];
}

- (NSString *)sixteenToTen:(NSString *)str{

    if(str == nil){
        return @"0";
    }
    
    if([str hasPrefix:@"0x"]){
        str = [str stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    }

    JKBigInteger *hexint = [[JKBigInteger alloc] initWithString:str andRadix:16];

    return [NSString stringWithFormat:@"%@",hexint];

}

// 轮询
- (void)openGCDBalance {
    WEAKSELF
    NSTimeInterval period = 5.0; //设置时间间隔
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0);
    dispatch_source_set_timer(_timer, start, period * NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        if (self.coin.coin_type_nft  == 1) {
            // nft 获取余额
            CoinPrice *coinPrice = [[PWDataBaseManager shared] queryCoinPriceBasedOn:weakSelf.coin.coin_type platform:weakSelf.coin.coin_platform andTreaty:weakSelf.coin.treaty];
            [PWNFTRequest requestNFTBalanceWithCoinType:weakSelf.coin.coin_chain
                                                   from:weakSelf.coin.coin_address
                                           contractAddr:coinPrice.coinprice_heyueAddress
                                                success:^(id  _Nonnull object) {
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:object options:NSJSONReadingAllowFragments error:nil];
                NSLog(@"balance result is %@",result);
                if (![result[@"result"] isKindOfClass:[NSNull class]]) {
                    NSInteger balance = [result[@"result"] integerValue];
                    weakSelf.coin.coin_balance = balance;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.topView.coin = weakSelf.coin;
                    });
                }
            } failure:^(NSString * _Nonnull errorMsg) {
                
            }];
        }else{
            CGFloat balance = [GoFunction goGetBalance:weakSelf.coin.coin_type platform:weakSelf.coin.coin_platform address:weakSelf.coin.coin_address andTreaty:weakSelf.coin.treaty];
            if (balance == -1) {
                balance = 0;
            }
            weakSelf.coin.coin_balance = balance;
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.topView.coin = weakSelf.coin;
            });
        }
        
       
    });
    dispatch_resume(_timer);
}

// 停止轮询
- (void)stopGCDBalance
{
    NSLog(@"停止查余额啦！！！");
    if (_timer)
    {
        dispatch_source_cancel(_timer);
    }
    _timer = nil;
}


#pragma mark - setter & getter

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = CMColorFromRGB(0xFFFFFF);
    }
    return _scrollView;
}

- (TransferTopView *)topView
{
    if (!_topView)
    {
        _topView = [[TransferTopView alloc] init];
    }
    return _topView;
}

- (TransferMidView *)midView
{
    if (!_midView)
    {
        _midView  = [[TransferMidView alloc] init];
    }
    return _midView;
}

- (TransferBottomView *)bottomView
{
    if (!_bottomView)
    {
        _bottomView = [[TransferBottomView alloc] init];
    }
    return _bottomView;
}

- (PWTransferNoteView *)cloudNoteView
{
    if (!_cloudNoteView)
    {
        _cloudNoteView = [[PWTransferNoteView alloc] init];
        _cloudNoteView.titleStr = [NSString stringWithFormat: @"  %@",@"上链备注(选填)".localized];
    }
    return _cloudNoteView;
}

- (UIButton *)bottomBtn
{
    if (!_bottomBtn)
    {
        _bottomBtn = [[UIButton alloc] init];
        _bottomBtn.backgroundColor = CMColorFromRGB(0x333649);
        [_bottomBtn setTitleColor:CMColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        _bottomBtn.titleLabel.font = CMTextFont17;
        _bottomBtn.layer.cornerRadius = 6.f;
        [_bottomBtn setTitle:@"确定转币".localized forState:UIControlStateNormal];
        [_bottomBtn addTarget:self action:@selector(inputPwd) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomBtn;
}

- (NSString *)decodeDesWithString:(NSString *)str
{
    NSData *encryptData = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    size_t plainTextBufferSize = [encryptData length];
    const void *vplainText = [encryptData bytes];
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    bufferPtrSize = (plainTextBufferSize + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    const void *vkey = (const void *) [DESKey UTF8String];
    const void *vinitVec = (const void *) [kInitVector UTF8String];
    ccStatus = CCCrypt(kCCDecrypt,
                       kCCAlgorithmDES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySizeDES,
                       vinitVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    if (ccStatus == kCCSuccess)
    {
        NSString *result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void*)bufferPtr length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding];
        return result;
    }
    return @"";
}

- (void)setFeeValue:(CGFloat)feeValue
{
    _feeValue = feeValue;
    
    _topView.feeValue = feeValue;
    _topView.coin = _coin;
    //bottomView中的矿工费是在setCoin中更新的，feeValue和_coins_name一定要写在coin前面
    _bottomView.feeValue = feeValue;
    _bottomView.coins_name = _coins_name;
    _bottomView.coin = _coin;
}

-(NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    return mutStr;

}


@end

