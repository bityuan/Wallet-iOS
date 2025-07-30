//
//  PWCountryCurrenyModel.m
//  PWallet
//
//  Created by 郑晨 on 2019/12/9.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWCountryCurrenyModel.h"

@implementation PWCountryCurrenyModel

- (instancetype)initWithAttritube:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.pj_name = dict[@"pj_name"];
        self.pj_symbol = dict[@"pj_symbol"];
        self.pj_id = dict[@"pj_id"];
        self.rate =  [dict[@"rate"] isKindOfClass:[NSNull class]] ? 1 : [dict[@"rate"] floatValue];
        self.sort = [dict[@"sort"] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.pj_name forKey:@"pj_name"];
    [aCoder encodeObject:self.pj_symbol forKey:@"pj_symbol"];
    [aCoder encodeObject:self.pj_id forKey:@"pj_id"];
    [aCoder encodeObject:@(self.rate) forKey:@"rate"];
    [aCoder encodeObject:@(self.sort) forKey:@"sort"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self)
    {
        self.pj_name = [aDecoder decodeObjectForKey:@"pj_name"];
        self.rate = [[aDecoder decodeObjectForKey:@"rate"] floatValue];
        self.sort = [[aDecoder decodeObjectForKey:@"sort"] integerValue];
        self.pj_symbol = [aDecoder decodeObjectForKey:@"pj_symbol"];
        self.pj_id = [aDecoder decodeObjectForKey:@"pj_id"];

    }
    
    return self;
}



@end
