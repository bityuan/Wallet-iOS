//
//  PWContactsTool.m
//  PWallet
//  联系人数据持久化
//  Created by 陈健 on 2018/6/1.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWContactsTool.h"
#import "PWKeychainTool.h"
#import "NSString+CommonUseTool.h"
#import "PWContactsCoin.h"
#import "PWDataBaseManager.h"

NSString *const PWSaveContactsIdentifier = @"PWSaveContactsIdentifier";

@interface PWContactsTool()
@property(nonatomic,strong)NSMutableArray<PWContacts*> *contactsArray;
@end

@implementation PWContactsTool

+(instancetype)shared {
    static PWContactsTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[PWContactsTool alloc]init];
            [instance loadLocalContacts];
        }
    });
    return instance;
}

//加载本地存储的所有联系人 保存在self.contactsArray
-(void)loadLocalContacts {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:PWSaveContactsIdentifier];
    NSArray *array = (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    self.contactsArray = [NSMutableArray arrayWithArray:array];
}
//将联系人数组写入Keychain
- (void)savaContactsToUserDefaults {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.contactsArray];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:PWSaveContactsIdentifier];
}

- (NSArray<PWContacts*>*)getAllContacts {
    return [NSArray arrayWithArray:self.contactsArray];
}

- (void)saveContacts:(PWContacts*)contacts {

    if ([self.contactsArray containsObject:contacts]) {
        //相同的
        return;
    }
    [self.contactsArray addObject:contacts];
    [self savaContactsToUserDefaults];
}

- (void)deleteContacts:(PWContacts*)contacts {
    if ([self.contactsArray containsObject:contacts]) {
        [self.contactsArray removeObject:contacts];
        [self savaContactsToUserDefaults];
    }
}

- (void)updateOldContacts:(PWContacts*)oldContacts newContacts:(PWContacts*)newContacts {
    if ([self.contactsArray containsObject:oldContacts]) {
        [self.contactsArray removeObject:oldContacts];
    }
    [self.contactsArray addObject:newContacts];
    [self savaContactsToUserDefaults];
}

- (NSArray<NSDictionary<NSString*,NSArray<PWContacts*> *>*> *)getContactsGroupByFirstCharactorOfNicknamewithArray:(NSArray <PWContacts*>*)array {
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    for (PWContacts *contacts in array) {
        NSString *firtCharacter = [[contacts.nickName substringToIndex:1] capitalizedString];
        //首个字母不是英文 就当做中文处理
        if (![firtCharacter isLatter]) {
            firtCharacter = [NSString firstCharactor:contacts.nickName];
        }
        
        if ([mutDic objectForKey:firtCharacter]) {
            NSMutableArray *mutArr = [mutDic objectForKey:firtCharacter];
            [mutArr addObject:contacts];
        }
        else {
            NSMutableArray *mutArr = [NSMutableArray array];
            [mutArr addObject:contacts];
            [mutDic setObject:mutArr forKey:firtCharacter];
        }
    }
    NSMutableArray *stringArray = [NSMutableArray arrayWithArray:mutDic.allKeys];
    [stringArray sortUsingComparator: ^NSComparisonResult (NSString *str1, NSString *str2) {
        return [str1 compare:str2];
    }];
    if ([stringArray containsObject:@"#"]) {
        [stringArray removeObject:@"#"];
        [stringArray addObject:@"#"];
    }
    NSMutableArray *mutArr = [NSMutableArray array];
    for (NSString *key in stringArray) {
        [mutArr addObject:@{key:mutDic[key]}];
    }
    
    return [mutArr copy];
}

- (PWContacts*)getContactsByCoinName:(NSString*)coinName coinAddress:(NSString*)coinAddress {
    for (PWContacts *contacts in self.contactsArray) {
        for (PWContactsCoin *coin in contacts.coinArray) {
            
            NSString *realCoinAddress = [PWUtils removeSpaceAndNewline:coin.coinAddress];
            
            coinAddress = [PWUtils removeSpaceAndNewline:coinAddress];
            if ([coin.coinName isEqualToString:coinName] && [realCoinAddress isEqualToString:coinAddress]) {
                return contacts;
            }
        }
    }
    return nil;
}


@end



