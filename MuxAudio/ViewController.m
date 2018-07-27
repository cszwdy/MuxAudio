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
@property(nonatomic, copy) NSString *audioID;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    __weak typeof(self) wself = self;
//
    self.audioManager = [[MuxAudioManager alloc] init];
    
//
//    NSString *path3 = [[NSBundle mainBundle] pathForResource:@"foreverLove" ofType:@"mp3"];
//    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"clap" ofType:@"mp3"];
//    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"readygo" ofType:@"mp3"];
//    [_audioManager playAudioFileAt:path1 loop:YES];
//
//    [_audioManager accessBufferWithBufferSize:44100 * 0.12 handler:^(AVAudioPCMBuffer * _Nonnull buffer) {
//        NSLog(@"out put.");
//    }];
//
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [wself.audioManager playAudioFileAt:path1 loop:YES];
//    });
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"stop all.");
//        [wself.audioManager stopAll];
//    });
//
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [wself.audioManager playAudioFileAt:path3 loop:NO];
//    });
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [wself.audioManager playAudioFileAt:path2 loop:YES];
//    });
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [wself.audioManager playAudioFileAt:path1 loop:NO];
//    });
    
//    NSURL *url = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"mixerOutput.caf"]];
//    [_audioManager accessBufferWithBufferSize:888 handler:nil];
//    [_audioManager record];
//
//    NSLog(@"record path = %@", url.path);
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"readygo" ofType:@"mp3"];
//        [wself.audioManager playAudioFileAt:path loop:NO];
//
//    });
//
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"readygo" ofType:@"mp3"];
//        [wself.audioManager playAudioFileAt:path loop:NO];
//
//    });
//
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"clap" ofType:@"mp3"];
//        [wself.audioManager playAudioFileAt:path loop:YES];
//
//    });
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"clap" ofType:@"mp3"];
//        [wself.audioManager stopAudioFileAt:path];
//
//    });
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"clap" ofType:@"mp3"];
//        [wself.audioManager playAudioFileAt:path loop:YES];
//
//        [wself.audioManager accessBufferWithBufferSize:4096 handler:^(AVAudioPCMBuffer * _Nonnull buffer) {
//            NSLog(@"get buffer length = %@", @(buffer.frameCapacity));
//        }];
//    });
    
}

- (IBAction)aClick:(id)sender {
    _audioID = [self playName:@"readygo" loop:NO];
}

- (IBAction)bClick:(id)sender {
    _audioID = [self playName:@"clap" loop:NO];
//    NSData *data = [_audioManager nextMixedPCMBuffer];
//    if (data != nil) {
//        NSLog(@"Get a data");
//    }
}

- (IBAction)cClick:(id)sender {
//    [self playName:@"clap" loop:NO];
    [_audioManager beganMixPCMBuffer];
}

- (IBAction)dClick:(id)sender {
    [_audioManager stopAll];
}

- (IBAction)stopClick:(id)sender {
    [_audioManager stopAudioFileBy:_audioID];
}

- (NSString *)playName:(NSString *)name loop:(BOOL)loop {
    return [_audioManager playAudioFileAt:[[NSBundle mainBundle] pathForResource:name ofType:@"mp3"] loop:loop];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
