//
//  PWContactsTool.h
//  PWallet
//  联系人数据持久化
//  Created by 陈健 on 2018/6/1.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PWContacts.h"

typedef void(^contactMarrayBlock)(NSArray *dataMarray);
typedef void(^contactSyncBlock)(BOOL object);
@interface PWContactsTool : NSObject
/*单例对象**/
+(instancetype)shared;
/*得到所有联系人**/
- (NSArray<PWContacts*>*)getAllContacts;
/*得到所有联系人 通过联系人昵称首字母分组**/
- (NSArray<NSDictionary<NSString*,NSArray<PWContacts*> *>*> *)getContactsGroupByFirstCharactorOfNicknamewithArray:(NSArray <PWContacts*>*)array;
/*保存联系人 contacts**/
- (void)saveContacts:(PWContacts*)contacts;
/*删除联系人 contacts**/
- (void)deleteContacts:(PWContacts*)contacts;
/*跟新联系人 把oldContacts更新为newContacts**/
- (void)updateOldContacts:(PWContacts*)oldContacts newContacts:(PWContacts*)newContacts;
/*根据币名称和地址查找联系人**/
- (PWContacts*)getContactsByCoinName:(NSString*)coinName coinAddress:(NSString*)coinAddress;

@end
