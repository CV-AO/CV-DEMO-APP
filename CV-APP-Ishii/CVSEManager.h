//
//  CVSEManager.h
//  CV
//
//  Created by wanko on 2014/08/09.
//  Copyright (c) 2014年 Tetsuji Ishii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CVSEManager : NSObject{
NSMutableArray *soundArray;
}

@property(nonatomic) float soundVolume;

+ (CVSEManager *)sharedManager;
- (void)playSound:(NSString *)soundName;
+ (void)writeFile:(NSData*)data soundName:(NSString*)soundName;

@end
