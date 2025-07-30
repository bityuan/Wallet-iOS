//
//  PWOtherMessageModel.m
//  PWallet
//
//  Created by 杨威 on 2019/11/14.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWOtherMessageModel.h"
#import "FMDB.h"

static PWOtherMessageModel *_instance = nil;

@interface PWOtherMessageModel ()

/**  */
@property (nonatomic, strong) FMDatabase *db;

@end

@implementation PWOtherMessageModel

+ (instancetype)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PWOtherMessageModel alloc] init];
        [_instance initDataBase];
    });
    return _instance;
}

-(void)initDataBase{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fileName = [path stringByAppendingPathComponent:@"message.sqlite"];
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];

    if ([db open]) {
            //4.创表
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_message_new (id integer PRIMARY KEY AUTOINCREMENT, title text NOT NULL, content text NOT NULL, create_at text NOT NULL, hash text NOT NULL, readed text NOT NULL );"];
        if (result) {
            NSLog(@"创表成功");
        }
        else {
            NSLog(@"创表失败");
        }
    }
    self.db=db;
}

-(void)addMessage:(id)userInfo{
    NSDictionary *parameter=userInfo[@"param"];
//    NSString *param=userInfo[@"param"];
//    NSData *data=[param dataUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary *parameter=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSTimeInterval interval = [parameter[@"timestamp"] doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSString *dateString = [formatter stringFromDate: date];
    
    NSDictionary *aps=userInfo[@"aps"];
    NSString *alert=aps[@"alert"];
//    NSString *alert=userInfo[@"alert"];
    NSArray * arr = [alert componentsSeparatedByString:@"\n"];
    NSString *title=arr[0];
    NSString *content=arr[1];
    NSString *hash=parameter[@"hash"];
    if([self existMessage:hash]){
        return;
    }
    
    NSString *sql = @"insert into t_message_new (title, content, create_at, hash, readed) values (?, ?, ?, ?, ?)";
    BOOL result = [self.db executeUpdate:sql,title,content,dateString,hash,@"no"];
    if (result) {
        NSLog(@"插入成功");
    }
    else {
        NSLog(@"插入失败");
    }
}

-(NSArray*)loadData {
    FMResultSet * resultSet = [_db executeQuery:@"select * from t_message_new order by id desc limit 20"];
//    FMResultSet * resultSet = [_db executeQuery:@"select * from t_message_new"];
    NSMutableArray *dataArray=[NSMutableArray array];
     //遍历结果集合
    while ([resultSet next]) {
        PWMessage *message=[[PWMessage alloc]init];
        message.create_time=[resultSet objectForColumn:@"create_at"];
        message.title=[resultSet objectForColumn:@"title"];
        message.content=[resultSet objectForColumn:@"content"];
        message.readed=[[resultSet objectForColumn:@"readed"] isEqualToString:@"yes"]?YES:NO;
        [dataArray addObject:message];
    }

    return dataArray;
}

-(BOOL)existMessage:(NSString*)hash{
    NSString *selectStr=@"select * from t_message_new where hash=?";
    FMResultSet * resultSet = [_db executeQuery:selectStr,hash];
    if([resultSet next]){
        return true;
    }else{
        return false;
    }
}

-(void)updateMessage:(PWMessage*)message{
    NSString *selectStr=@"update t_message_new set readed=? where (title=? and content=? and create_at=?)";
    BOOL update=[self.db executeUpdate:selectStr,@"yes",message.title,message.content,message.create_time];
    if(update){
        NSLog(@"更新成功");
    }else{
        NSLog(@"更新失败");
    }
}
@end
