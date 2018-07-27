//
//  MuxAudioManager.m
//  MuxAudio
//
//  Created by Emiaostein on 2018/7/20.
//  Copyright © 2018 Emiaostein. All rights reserved.
//

#import "MuxAudioManager.h"

@interface MuxAudioManager()

@property(nonatomic, strong) AVAudioEngine *engine;
@property(nonatomic, strong) AVAudioMixerNode *mixNode;
@property(nonatomic, strong) NSMutableDictionary<NSString *, AVAudioPCMBuffer *> *buffers;
@property(nonatomic, strong) NSMutableDictionary<NSString *, AVAudioPlayerNode *> *playingNodes;
@property(nonatomic, strong) NSMutableArray<AVAudioPlayerNode *> *nodesPool;
//@property(nonatomic, weak) AVAudioPlayerNode *loopNode;
@property(nonatomic, strong) NSDateFormatter *formatter;

@property(nonatomic, assign) BOOL installed;
@property(nonatomic, strong) NSMutableArray<NSData *> *mixedPCMBuffers;

@end

@implementation MuxAudioManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _engine = [[AVAudioEngine alloc] init];
        _playingNodes = [@{} mutableCopy];
        _nodesPool = [@[] mutableCopy];
        _buffers = [@{} mutableCopy];
        _mixedPCMBuffers = [@[] mutableCopy];
        _mixNode = [[AVAudioMixerNode alloc] init];
        [_engine attachNode:_mixNode];
        [_engine connect:_mixNode to:_engine.mainMixerNode format:nil];
//        [_engine.mainMixerNode setOutputVolume:0];
        _installed = NO;
        
        _formatter = [[NSDateFormatter alloc ] init];
        [_formatter setDateFormat:@"hhmmssSSS"];
    }
    return self;
}


- (NSString *)playAudioFileAt:(NSString *)path loop:(BOOL)loop {
    
    NSString *date =  [_formatter stringFromDate:[NSDate date]];
    NSString *timeLocal = [[NSString alloc] initWithFormat:@"%@", date];
    NSString *audioFileID = [[path.stringByDeletingPathExtension lastPathComponent] stringByAppendingString:timeLocal]; // Audio ID by audio file name.
    AVAudioPlayerNode *node = _nodesPool.firstObject;
    AVAudioPCMBuffer *buffer = _buffers[audioFileID];
    
    
    if (buffer == nil) {
        NSURL *url = [NSURL URLWithString:path];
        NSError *error;
        AVAudioFile *file = [[AVAudioFile alloc] initForReading:url error:&error];
        AVAudioPCMBuffer *aBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:[file processingFormat] frameCapacity:(AVAudioFrameCount)[file length]];
        [file readIntoBuffer:aBuffer error:&error];

        buffer = aBuffer;
        _buffers[audioFileID] = aBuffer;
    }
    
    if (node == nil) {
        AVAudioPlayerNode *aNode = [[AVAudioPlayerNode alloc] init];
        [_engine attachNode:aNode];
        [_engine connect:aNode to:_mixNode format:buffer.format];
        node = aNode;
    } else {
        [node stop];
        [_nodesPool removeObjectAtIndex:0];
        NSLog(@"node exist and isplaying = %@", node.isPlaying ? @"playing" : @"stop" );
    }

    __weak typeof(self) wself = self;
    __weak typeof(node) wNode = node;
    [node scheduleBuffer:buffer atTime:nil options:( loop ? AVAudioPlayerNodeBufferLoops : AVAudioPlayerNodeBufferInterruptsAtLoop) completionHandler:^{ // did play
        NSLog(@"node completed and isPlaying = %@", wNode.isPlaying ? @"YES" : @"NO");
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.nodesPool addObject:wNode];
            [wself.playingNodes removeObjectForKey:audioFileID];
        });
    }];
    
    
    if (!_engine.isRunning) {
        [_engine prepare];
        NSError *error;
        BOOL success;
        success = [_engine startAndReturnError:&error];
        NSAssert(success, @"couldn't start engine, %@", [error localizedDescription]);
        NSLog(@"Started Engine");
     }
    
    [node play];
    
    _playingNodes[audioFileID] = node;
    
    return audioFileID;
}



- (void)stopAudioFileBy:(NSString *)audioID {
    AVAudioPlayerNode *node = _playingNodes[audioID];
    if (node != nil) {
        [node stop];
    }
    
    NSLog(@"nodes = %@", @(self.nodesPool.count));
}



- (void)stopAll {
    
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [wself.engine stop];
        
        for (AVAudioPlayerNode *node in wself.playingNodes.objectEnumerator) {
            [node stop];
        }
        
        [wself.playingNodes removeAllObjects];
        
        NSLog(@"nodes = %@", @(wself.nodesPool.count));
        
        [wself stopMixPCMBuffer];
    });
}

- (void)cleanAll {
    [self stopAll];
    [_buffers removeAllObjects];
    [_nodesPool removeAllObjects];
    [_mixedPCMBuffers removeAllObjects];
}


- (void)beganMixPCMBuffer {
    if (_installed == YES) {return;}
    _installed = YES;
    __weak typeof(self) wself = self;
    AVAudioFrameCount bufferSize = 44100 * 0.12;
    [_mixNode installTapOnBus:0 bufferSize:bufferSize format:[_mixNode outputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        
        NSData *data = [NSData dataWithBytes:buffer.floatChannelData[0] length: buffer.frameLength * buffer.format.streamDescription->mBytesPerFrame / 2];
        const void *bytes = [data bytes];
        float *bufferData = buffer.floatChannelData[0];
        short* pOutShortBuf = (short*)bytes;
        for(int i=0;i<bufferSize;i++)
        {
            pOutShortBuf[i] = (short)(bufferData[i]*32767);
        }
        
        [wself.mixedPCMBuffers addObject:data];
        NSLog(@"Add mixed buffer.");
    }];
}


- (NSData *__nullable)nextMixedPCMBuffer {
    NSData *data = _mixedPCMBuffers.firstObject;
    if (data != nil) {
        [_mixedPCMBuffers removeObject:data];
    }
    return data;
}


- (void)stopMixPCMBuffer {
    _installed = NO;
    [_mixNode removeTapOnBus:0];
}

@end
