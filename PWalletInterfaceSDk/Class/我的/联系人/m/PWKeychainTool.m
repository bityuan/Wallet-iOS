//
//  PWKeychainTool.m
//  PWallet
//
//  Created by 陈健 on 2018/5/16.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWKeychainTool.h"
#import <Security/Security.h>
#import "PWCKeyChainStore.h"

@implementation PWKeychainTool
/*
 保存或更新数据
 
 @data  要存储的String
 @identifier 存储数据的标示
 @return 是否存储成功
 */
+(BOOL) save:(NSString*)string withIdentifier:(NSString*)identifier {
    return [[PWCKeyChainStore keyChainStore] setString:string forKey:identifier];
}

/*
 读取数据
 
 @identifier 存储数据的标示
 @return 数据
 */
+(NSString *) readString:(NSString*)identifier {
    return [[PWCKeyChainStore keyChainStore] stringForKey:identifier];
}



/*
 删除数据
 @identifier 数据存储时的标示
 */
+(void) remove:(NSString*)identifier {
    [[PWCKeyChainStore keyChainStore]removeItemForKey:identifier];
}

/*
 保存或更新数据
 
 @data  要存储的Data
 @identifier 存储数据的标示
 @return 是否存储成功
 */
+(BOOL) saveData:(NSData*)data withIdentifier:(NSString*)identifier {
    return [[PWCKeyChainStore keyChainStore] setData:data forKey:identifier];
}

/*
 读取数据
 
 @identifier 存储数据的标示
 @return 数据
 */
+(NSData *) readData:(NSString*)identifier {
    return [[PWCKeyChainStore keyChainStore] dataForKey:identifier];
}



/*
 删除数据
 @identifier 数据存储时的标示
 */
+(void) removeData:(NSString*)identifier {
    [[PWCKeyChainStore keyChainStore]removeItemForKey:identifier];
}
@end
