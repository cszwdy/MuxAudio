//
//  ViewController.m
//  MuxAudio
//
//  Created by Emiaostein on 2018/7/20.
//  Copyright © 2018 Emiaostein. All rights reserved.
//

#import "ViewController.h"
#import "MuxAudioManager.h"

@interface ViewController ()

@property(nonatomic, strong) MuxAudioManager *audioManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.audioManager = [[MuxAudioManager alloc] init];
    
    
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"clap" ofType:@"mp3"];
    [_audioManager playAudioFileAt:path1 loop:YES];
    
//    NSURL *url = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"mixerOutput.caf"]];
////    [_audioManager record];
//
//    NSLog(@"record path = %@", url.path);
    
    __weak typeof(self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"readygo" ofType:@"mp3"];
        [wself.audioManager playAudioFileAt:path loop:NO];
        
    });
    

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"readygo" ofType:@"mp3"];
        [wself.audioManager playAudioFileAt:path loop:NO];
        
    });
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"clap" ofType:@"mp3"];
        [wself.audioManager playAudioFileAt:path loop:YES];
        
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"clap" ofType:@"mp3"];
        [wself.audioManager stopAudioFileAt:path];

    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"clap" ofType:@"mp3"];
        [wself.audioManager playAudioFileAt:path loop:YES];
        
        [wself.audioManager accessBufferWithBufferSize:4096 handler:^(AVAudioPCMBuffer * _Nonnull buffer) {
            NSLog(@"get buffer length = %@", @(buffer.frameCapacity));
        }];
    });
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
