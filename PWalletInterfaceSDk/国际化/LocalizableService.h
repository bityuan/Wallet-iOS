//
//  LocalizableService.h
//  StarSun
//
//  Created by lee on 2018/9/14.
//  Copyright © 2018 fuzamei. All rights reserved.
//

/*   切换语言
 [LocalizableService setAPPLanguage:LanguageChineseSimplified];
 MainTabBarController *tbc = [[MainTabBarController alloc] init];
 tbc.selectedIndex = 2;
 dispatch_async(dispatch_get_main_queue(), ^{
 [UIApplication sharedApplication].keyWindow.rootViewController = tbc;
 });
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, Language) {
    LanguageUnknown             =   -1,
    LanguageEnglish             =   0,
    LanguageChineseSimplified   =   1,
    LanguageChineseTraditional  =   2,
    LanguageJapanese            =   3,
    LanguageKorean              =   4,
    LanguageArabic              =   5,
    LanguageRussian             =   6,
    LanguageFrench              =   7,
    LanguageKurdish             =   8,
    LanguageThai                =   9,
    LanguageTurkish             =   10,
    LanguageSpanish             =   11,
    LanguageItalian             =   12,
};
typedef NS_ENUM(NSInteger, MoneyType) {
    MoneyCNY,
    MoneyUSD,
};

typedef NS_ENUM(NSInteger, IPCountry) {
    IPJP,
    IPCN,
};

NS_ASSUME_NONNULL_BEGIN

@interface LocalizableService : NSObject
+ (instancetype)shareInstance;
/*设置APP语言**/
+ (void)setAPPLanguage:(Language)lang;
/*获取APP语言  枚举**/
+ (Language)getAPPLanguage;
/*获取APP语言  字符串**/
+ (NSString *)getAPPLanguageString;
+ (NSBundle *)currentBundle;
/*国际化字符串**/
+ (NSString *)localizedString:(NSString *)key;

+ (void)setAPPMoneyType:(MoneyType)type;

+ (MoneyType)getAPPMoneyType;

+ (void)setAPPIPCountry:(IPCountry)type;
+ (IPCountry)getAPPIPCountry;
@end

NS_ASSUME_NONNULL_END
