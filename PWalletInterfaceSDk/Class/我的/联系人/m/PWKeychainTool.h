//
//  PWKeychainTool.h
//  PWallet
//
//  Created by 陈健 on 2018/5/16.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PWKeychainTool : NSObject
/*
 保存或更新数据
 
 @data  要存储的String
 @identifier 存储数据的标示
 @return 是否存储成功
 */
+(BOOL) save:(NSString*)string withIdentifier:(NSString*)identifier ;

/*
 读取数据
 
 @identifier 存储数据的标示
 @return 数据
 */
+(NSString *) readString:(NSString*)identifier ;



/*
 删除数据
 @identifier 数据存储时的标示
 */
+(void) remove:(NSString*)identifier ;


/*
 保存或更新数据
 
 @data  要存储的Data
 @identifier 存储数据的标示
 @return 是否存储成功
 */
+(BOOL) saveData:(NSData*)data withIdentifier:(NSString*)identifier ;

/*
 读取数据
 
 @identifier 存储数据的标示
 @return 数据
 */
+(NSData *) readData:(NSString*)identifier ;



/*
 删除数据
 @identifier 数据存储时的标示
 */
+(void) removeData:(NSString*)identifier ;


@end
