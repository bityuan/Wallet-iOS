//
//  LocalizableService.m
//  StarSun
//
//  Created by lee on 2018/9/14.
//  Copyright © 2018 fuzamei. All rights reserved.
//

#import "LocalizableService.h"
#import <MJRefresh/MJRefresh.h>

static LocalizableService * shared = nil;
static NSString *PWAPPLocalizableLang = @"PWAPPLocalizableLang";
static NSString *PWAPPLocalizableMoneyType = @"PWAPPLocalizableMoneyType";
static NSString *PWAPPLocalizableIPCountry = @"PWAPPLocalizableIPCountry";
@interface LocalizableService ()
@property (nonatomic, strong) NSArray * langResource;
@property (nonatomic, strong) NSBundle * langBundle;
@property (nonatomic, assign) Language lang;
@end

@implementation LocalizableService
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LocalizableService alloc] init];
    });
    return shared;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [super allocWithZone:zone];
    });
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.langResource = @[
                              @[@"en", @"English"],
                              @[@"zh-Hans", @"简体中文"],
                              @[@"zh-Hant", @"繁体中文"],
                              @[@"ja", @"日本語"],
                              @[@"ko",@"한국어"],
                              @[@"ar",@"اللغة العربية"],
                              @[@"ru",@"Русский язык"],
                              @[@"fr",@"Français"],
                              @[@"ku",@"kurdî/کوردى"],
                              @[@"th",@"ภาษาไทย"],
                              @[@"tr",@"Türkçe, Türk dili"],
                              @[@"es",@"Español"],
                              @[@"it",@"Italiano"]
                              ];
        
        int langInt = LanguageEnglish; //默认为中文
        // 获取APP设置的语言
        id APPLang = [[NSUserDefaults standardUserDefaults]objectForKey:PWAPPLocalizableLang];
        if (!IS_BLANK(APPLang)) {
            langInt = [APPLang intValue];
        } else {
            NSString *phoneLang = [[NSUserDefaults standardUserDefaults]objectForKey:@"AppleLanguages"][0];
            //支持的语言
            if ([phoneLang hasPrefix:@"en"])
            {
                langInt = LanguageEnglish;
            }
            else if ([phoneLang hasPrefix:@"zh-Hans"])
            {
                langInt = LanguageChineseSimplified;
            }
            else if ([phoneLang hasPrefix:@"zh-Hant"])
            {
                langInt = LanguageChineseTraditional;
            }
            else if ([phoneLang hasPrefix:@"ja"])
            {
                langInt = LanguageJapanese;
            }
            else if ([phoneLang hasPrefix:@"ko"])
            {
                langInt = LanguageKorean;
            }
            else if ([phoneLang hasPrefix:@"ar"])
            {
                langInt = LanguageArabic;
            }
            else if ([phoneLang hasPrefix:@"ru"])
            {
                langInt = LanguageRussian;
            }
            else if ([phoneLang hasPrefix:@"fr"])
            {
                langInt = LanguageFrench;
            }
            else if ([phoneLang hasPrefix:@"ku"])
            {
                langInt = LanguageKurdish;
            }
            else if ([phoneLang hasPrefix:@"th"])
            {
                langInt = LanguageThai;
            }
            else if ([phoneLang hasPrefix:@"tr"])
            {
                langInt = LanguageTurkish;
            }
            else if ([phoneLang hasPrefix:@"es"])
            {
                langInt = LanguageSpanish;
            }
            else if ([phoneLang hasPrefix:@"it"])
            {
                langInt = LanguageItalian;
            }
            
            //手机系统语言
            
        }
        self.lang = langInt;
        [self setLanguageBundle];
    }
    return self;
}

+ (Language)getAPPLanguage {
    Language language = [LocalizableService shareInstance].lang;
//    if (language == LanguageEnglish) {
//        language = LanguageChineseSimplified;
//    }
    return language;
}
+ (void)setAPPLanguage:(Language)lang {
    [LocalizableService shareInstance].lang = lang;
    if (LanguageUnknown == lang) {
        [LocalizableService shareInstance].lang = LanguageChineseSimplified;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(lang) forKey:PWAPPLocalizableLang];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[LocalizableService shareInstance] setLanguageBundle];
}

- (void)setLanguageBundle {
    NSArray * langSource = [self.langResource objectAtIndex:self.lang];
    NSString * path = [[NSBundle mainBundle] pathForResource:[langSource objectAtIndex:0] ofType:@"lproj"];
    self.langBundle = [NSBundle bundleWithPath:path];
}

+ (NSString *)getAPPLanguageString {
    
    return [[[LocalizableService shareInstance].langResource objectAtIndex:[LocalizableService shareInstance].lang] objectAtIndex:1];
}
+ (NSBundle *)currentBundle {
    return [LocalizableService shareInstance].langBundle;
}
+ (NSString *)localizedString:(NSString *)key {
    return [[LocalizableService shareInstance].langBundle localizedStringForKey:key value:nil table:nil];
}

+(void)load
{
    Method mjMethod = class_getClassMethod([NSBundle class], @selector(mj_localizedStringForKey:value:));
    Method myMethod = class_getClassMethod(self, @selector(hook_mj_localizedStringForKey:value:));
    method_exchangeImplementations(mjMethod, myMethod);
}

+ (NSString *)hook_mj_localizedStringForKey:(NSString *)key value:(NSString *)value
{
    NSString *language =  [[[LocalizableService shareInstance].langResource objectAtIndex:[LocalizableService shareInstance].lang] objectAtIndex:0];
    if (![language containsString:@"zh-"]) {
        language = @"en";
    }
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mj_refreshBundle] pathForResource:language ofType:@"lproj"]];
    return [bundle localizedStringForKey:key value:nil table:nil];
}

+ (void)setAPPMoneyType:(MoneyType)type{
//    [LocalizableService shareInstance].lang = lang;
//    if (LanguageUnknown == lang) {
//        [LocalizableService shareInstance].lang = LanguageChineseSimplified;
//    }
    [[NSUserDefaults standardUserDefaults] setObject:@(type) forKey:PWAPPLocalizableMoneyType];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
+ (MoneyType)getAPPMoneyType{
    NSNumber *moneyType = [[NSUserDefaults standardUserDefaults] objectForKey:PWAPPLocalizableMoneyType];
    if (moneyType == nil) {

        return MoneyCNY;

    }else{
        return [moneyType intValue];
    }
}

+ (void)setAPPIPCountry:(IPCountry)type{
    [[NSUserDefaults standardUserDefaults] setObject:@(type) forKey:PWAPPLocalizableIPCountry];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
+ (IPCountry)getAPPIPCountry{
    NSNumber *ipCountry = [[NSUserDefaults standardUserDefaults] objectForKey:PWAPPLocalizableIPCountry];
    if (ipCountry == nil) {
        return IPCN;
    }else{
        return [ipCountry intValue];
    }
}
@end
