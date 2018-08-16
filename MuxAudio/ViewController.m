//
//  ViewController.m
//  MuxAudio
//
//  Created by Emiaostein on 2018/7/20.
//  Copyright © 2018 Emiaostein. All rights reserved.
//

#import "ViewController.h"
#import "MuxAudioManager.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) MuxAudioManager *audioManager;
@property (copy, nonatomic) NSString *audioID;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<NSString *> *items;
@property (strong, nonatomic) dispatch_queue_t queue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.queue = dispatch_queue_create("ccc", DISPATCH_QUEUE_SERIAL);
    self.audioManager = [[MuxAudioManager alloc] init];
    _items = @[
               @"foreverLove",
               @"Diamondboard_bgm",
               @"Breaktheice_balloonboom",
               @"Public_dimanond",
               @"PlaytheXylophone_b1",
               @"PlaytheXylophone_b2",
               @"PlaytheXylophone_b3",
               @"PlaytheXylophone_b4",
               @"PlaytheXylophone_b5",
               @"PlaytheXylophone_b6",
               @"PlaytheXylophone_b7",
               @"PlaytheXylophone_b8",
               ];
    
    [_audioManager beganMixPCMBuffer];
}

- (void)playByName:(NSString *)name loop:(BOOL)loop {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"mp3"];
    
    __weak typeof(self) wself = self;
    
    dispatch_queue_t globalDispatchQueueHight = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(self.queue, ^{
        [wself.audioManager playAudioFileAt:path loop:loop];
    });
}
- (IBAction)stop:(id)sender {
    [_audioManager stopAll];
    [self playByName:@"Diamondboard_bgm" loop:YES];
}

- (IBAction)trash:(id)sender {
    [_audioManager cleanAll];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSString *name = _items[indexPath.item];
    cell.textLabel.text = name;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *now1 = [NSDate date];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *name = _items[indexPath.item];
    [self playByName:name loop: YES];
//    if (indexPath.item == 1) {
//      [self playByName:name loop: YES];
//        [self playByName:_items[indexPath.item+1] loop: NO];
//    } else {
//       [self playByName:name loop: NO];
//    }
    
    NSDate *now2 = [NSDate date];
//    NSLog(@"Prepare to play %@ is %@s",name, @([now2 timeIntervalSinceDate:now1]));
}



@end
