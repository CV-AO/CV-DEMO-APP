//
//  CVSEManager.m
//  CV
//
//  Created by wanko on 2014/08/09.
//  Copyright (c) 2014年 Tetsuji Ishii. All rights reserved.
//

#import "AVFoundation/AVFoundation.h"
#import "CVSEManager.h"

@implementation CVSEManager

static CVSEManager *sharedData_ = nil;

+ (CVSEManager *)sharedManager{
    @synchronized(self){
        if (!sharedData_) {
            sharedData_ = [[CVSEManager alloc]init];
        }
    }
    return sharedData_;
}

- (id)init
{
    self = [super init];
    if (self) {
        soundArray = [[NSMutableArray alloc] init];
        _soundVolume = 1.0;
    }
    return self;
}

- (void)playSound:(NSString *)soundName{
    //tmpから取得
    NSString *soundPath = [NSTemporaryDirectory() stringByAppendingPathComponent:soundName];
    NSURL *urlOfSound = [NSURL fileURLWithPath:soundPath];
    
    AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:urlOfSound error:nil];
    [player setNumberOfLoops:0];
    player.volume = _soundVolume;
    player.delegate = (id)self;
    [soundArray insertObject:player atIndex:0];
    [player prepareToPlay];
    [player play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [soundArray removeObject:player];
}

+ (void)writeFile:(NSData*)data soundName:(NSString*)soundName {
    //tmpに保存
    NSString *soundPath = [NSTemporaryDirectory() stringByAppendingPathComponent:soundName];
    // ファイルハンドルを作成する
    NSFileHandle *fileHandle =
    [NSFileHandle fileHandleForWritingAtPath:soundPath];
    // ファイルハンドルの作成に失敗したか?
    if (!fileHandle) { // no
        NSLog(@"ファイルハンドルの作成に失敗");
        return;
    }
    // ファイルに書き込む
    [fileHandle writeData:data];
}

@end
