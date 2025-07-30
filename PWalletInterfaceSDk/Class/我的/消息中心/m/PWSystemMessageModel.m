//
//  PWSystemMessageModel.m
//  PWallet
//
//  Created by 杨威 on 2019/12/11.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWSystemMessageModel.h"
#import "FMDB.h"

static PWSystemMessageModel *_instance = nil;

@interface PWSystemMessageModel ()

/**  */
@property (nonatomic, strong) FMDatabase *db;

@end

@implementation PWSystemMessageModel

+ (instancetype)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PWSystemMessageModel alloc] init];
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
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS s_message (id integer PRIMARY KEY AUTOINCREMENT, title text NOT NULL,  create_at text NOT NULL, readed text NOT NULL );"];
        if (result) {
            NSLog(@"创表成功");
        }
        else {
            NSLog(@"创表失败");
        }
    }
    self.db=db;
}

-(void)addMessage:(PWMessage*)message{
    if([self existMessage:message]){
        return;
    }
    NSString *sql = @"insert into s_message (title, create_at, readed) values (?, ?, ?)";
    BOOL result = [self.db executeUpdate:sql,message.title,message.create_time,@"no"];
    if (result) {
        NSLog(@"插入成功");
    }
    else {
        NSLog(@"插入失败");
    }

}

-(void)updateMessage:(PWMessage*)message{
    NSString *selectStr=@"update s_message set readed=? where (title=? and create_at=?)";
    BOOL update=[self.db executeUpdate:selectStr,@"yes",message.title,message.create_time];
    if(update){
        NSLog(@"更新成功");
    }else{
        NSLog(@"更新失败");
    }
}

-(void)deleteMessage:(PWMessage*)message{
    if(![self existMessage:message]){
        return;
    }
    BOOL delete=[_db executeUpdate:@"delete from s_message where (title=? and create_at=?)",message.title,message.create_time];
    if(delete){
        NSLog(@"删除成功");
    }else{
        NSLog(@"删除失败");
    }
}

-(BOOL)existMessage:(PWMessage*)message{
    NSString *selectStr=@"select * from s_message where (title=? and create_at=?)";
    FMResultSet * resultSet = [_db executeQuery:selectStr,message.title,message.create_time];
    if([resultSet next]){
        return true;
    }else{
        return false;
    }
}

-(void)compareMessage:(NSArray*)array{
    FMResultSet * resultSet = [_db executeQuery:@"select * from s_message "];
    
    NSMutableArray *dataArray=[NSMutableArray array];
     //遍历结果集合
    while ([resultSet next]) {
        PWMessage *message=[[PWMessage alloc]init];
        message.create_time=[resultSet objectForColumn:@"create_at"];
        message.title=[resultSet objectForColumn:@"title"];
        message.readed=[[resultSet objectForColumn:@"readed"] isEqualToString:@"yes"]?YES:NO;
        [dataArray addObject:message];
    }
    NSMutableArray *addArray=[NSMutableArray array];
//    NSMutableArray *delArray=dataArray;
    if([dataArray count]==0){
        addArray=[NSMutableArray arrayWithArray:array];
    }else{
        for(int i=0;i<[array count];i++){
            PWMessage *message1=array[i];
            int j=0;
            for(j=0;j<[dataArray count];j++){
                PWMessage *message2=dataArray[j];
                if([message1.title isEqualToString:message2.title]&&[message1.create_time isEqualToString:message2.create_time]){
                    message1.readed=message2.readed;
//                    [delArray removeObject:message2];
                    break;
                }
            }
            if(j==[dataArray count]){
                message1.readed=NO;
                [addArray addObject:message1];
            }
        }
    }
    
    [_db beginTransaction];
    BOOL isRollBack = NO;
    @try {
        for (int i = 0; i<addArray.count; i++) {
            PWMessage *message=addArray[i];
            NSString *sql = @"insert into s_message (title, create_at, readed) values (?, ?, ?)";
            BOOL result = [self.db executeUpdate:sql,message.title,message.create_time,@"no"];
            if (result) {
                NSLog(@"插入成功");
            }
            else {
                NSLog(@"插入失败");
            }
        }
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [_db rollback];
    }
    @finally {
        if (!isRollBack) {
            [_db commit];
        }
    }
}
@end
