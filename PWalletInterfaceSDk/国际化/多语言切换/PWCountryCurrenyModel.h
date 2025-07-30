//
//  PWCountryCurrenyModel.h
//  PWallet
//
//  Created by 郑晨 on 2019/12/9.
//  Copyright © 2019 陈健. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PWCountryCurrenyModel : NSObject

@property (nonatomic, strong) NSNumber *pj_id;
@property (nonatomic, strong) NSString *pj_name;
@property (nonatomic, strong) NSString *pj_symbol;
@property (nonatomic, assign) CGFloat   rate;
@property (nonatomic, assign) NSInteger sort;

- (instancetype)initWithAttritube:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
