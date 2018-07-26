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
@property(nonatomic, strong) NSMutableDictionary<NSString *, AVAudioPlayerNode *> *nodes;
@property(nonatomic, weak) AVAudioPlayerNode *loopNode;

@property(nonatomic, assign) AVAudioFrameCount bufferSize;

@end

@implementation MuxAudioManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _engine = [[AVAudioEngine alloc] init];
        _nodes = [@{} mutableCopy];
        _buffers = [@{} mutableCopy];
        _mixNode = [[AVAudioMixerNode alloc] init];
        [_engine attachNode:_mixNode];
        [_engine connect:_mixNode to:_engine.mainMixerNode format:nil];
//        [_engine.mainMixerNode setOutputVolume:0];
    }
    return self;
}


- (BOOL)playAudioFileAt:(NSString *)path loop:(BOOL)loop {
    
    NSString *audioFileID = [path.stringByDeletingPathExtension lastPathComponent]; // Audio ID by audio file name.
    AVAudioPlayerNode *node = _nodes[audioFileID];
    AVAudioPCMBuffer *buffer = _buffers[audioFileID];
    
    
    NSLog(@"node isplaying = %@", @(node.isPlaying));
    
    
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
        _nodes[audioFileID] = aNode;
    } else {
        [node stop];
        NSLog(@"node exist and isplaying = %@", node.isPlaying ? @"playing" : @"stop" );
    }

    
    __weak typeof(node) wNode = node;
    [node scheduleBuffer:buffer atTime:nil options:( loop ? AVAudioPlayerNodeBufferLoops : AVAudioPlayerNodeBufferInterruptsAtLoop) completionHandler:^{ // did play
        NSLog(@"node completed and isPlaying = %@", wNode.isPlaying ? @"YES" : @"NO");
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
    
    return YES;
}



- (void)stopAudioFileAt:(NSString *)path {
    
}

- (void)stopAll {
    
    [_engine stop];
    
    for (AVAudioPlayerNode *node in _nodes.objectEnumerator) {
        [node stop];
    }
}


- (void)accessBufferWithBufferSize:(AVAudioFrameCount)size handler:(void(^)(AVAudioPCMBuffer * _Nonnull buffer))handler {
    
    [_mixNode installTapOnBus:0 bufferSize:size format:[_mixNode outputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        if (handler != nil) {
            handler(buffer);
        }
    }];
    
}



























//- (BOOL)playAudioFileAt:(NSString *)path loop:(BOOL)loop {
//
//    NSString *audioFileID = [path.stringByDeletingPathExtension lastPathComponent]; // Audio ID by audio file name.
//    AVAudioPlayerNode *playerNode = _nodes[audioFileID];
//    NSURL *url = [NSURL URLWithString:path];
//    if (url == nil) {
//        return NO;
//    }
//
//    // Player node exist.
//
//    if (playerNode != nil) {
//        NSError *error;
//        AVAudioFile *file = [[AVAudioFile alloc] initForReading:url error:&error];;
//
//        if (playerNode.isPlaying) {
//            [playerNode stop];
//        }
//
//        if (loop) {
//            [self p_playerNode:playerNode scheduleFileLoop:file];
//        } else {
//            [self p_playerNode:playerNode scheduleFile:file];
//        }
//
//        [playerNode play];
//
//        return YES;
//    }
//
//
//    // Player node not exist.
//
//    // 1. Create audio file and player node.
//    NSError *error;
//    AVAudioFile *file = [[AVAudioFile alloc] initForReading:url error:&error];
//    playerNode = [[AVAudioPlayerNode alloc] init];
//    [_engine attachNode:playerNode];
//    _nodes[audioFileID] = playerNode;
//
//
//    // 2. Stop loop audio if need.
//    if (loop == YES && _loopNode != nil && _loopNode.isPlaying) {
//        [_loopNode stop];
//        _loopNode = playerNode;
//    }
//
//    // 3. connect player node.
//    [_engine connect:playerNode to:_mixNode format:file.processingFormat];
//
//    if (loop) {
//        [self p_playerNode:playerNode scheduleFileLoop:file];
//    } else {
//        [self p_playerNode:playerNode scheduleFile:file];
//
//    }
//
//    if (!_engine.isRunning) {
//        [_engine prepare];
//        NSError *error;
//        BOOL success;
//        success = [_engine startAndReturnError:&error];
//        NSAssert(success, @"couldn't start engine, %@", [error localizedDescription]);
//        NSLog(@"Started Engine");
//    }
//
//    [playerNode play];
//
//    return YES;
//}
//
//
//- (void)stopAudioFileAt:(NSString *)path {
//    NSString *audioFileID = [path.stringByDeletingPathExtension lastPathComponent]; // Audio ID by audio file name.
//    AVAudioPlayerNode *playerNode = _nodes[audioFileID];
//    [playerNode stop];
//}
//
//
//- (void)accessBufferWithBufferSize:(AVAudioFrameCount)size handler:(void(^)(AVAudioPCMBuffer * _Nonnull buffer))handler {
//
//    if (_bufferSize != size) {
//        _bufferSize = size;
//        [_mixNode removeTapOnBus:0];
//    }
//
//    [_mixNode installTapOnBus:0 bufferSize:size format:[_mixNode outputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
//        if (handler != nil) {
//            handler(buffer);
//        }
//    }];
//}









#pragma mark - Private Method

//- (void)p_playerNode:(AVAudioPlayerNode *)playerNode scheduleFile:(AVAudioFile *)file {
//    [playerNode scheduleFile:file atTime:nil completionHandler:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"Node did completed, state = %@", @(playerNode.isPlaying));
//        });
//    }];
//}
//
//- (void)p_playerNode:(AVAudioPlayerNode *)playerNode scheduleFileLoop:(AVAudioFile *)file {
//    NSError *error;
//    AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:[file processingFormat] frameCapacity:(AVAudioFrameCount)[file length]];
//    [file readIntoBuffer:buffer error:&error];
//    [playerNode scheduleBuffer:buffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
//}




//- (void)record {
//
//    AVAudioMixerNode *mixNode = _mixNode;
//
////    NSError *error;
////    NSURL *url = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"mixerOutput.caf"]];
////
////    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
////        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
////    }
//
////    AVAudioFile *mixerOutputFile = [[AVAudioFile alloc] initForWriting:url settings:[[mixNode outputFormatForBus:0] settings] error:&error];
//
//    NSUInteger QAVBufferBytes = 3528;
//    NSUInteger QAVBufferFrames = 3528 / 2 / 2; // 882 frames, 20ms
//    NSUInteger maxBufferCount = 400 / 20; // 20 buffers
//
////    NSLog(@"%d", sizeof(int16_t));
//
//
//    [mixNode installTapOnBus:0 bufferSize:882 * 20 format:[mixNode outputFormatForBus:0] block:^(AVAudioPCMBuffer *buffer, AVAudioTime *when) {
////        NSError *error;
////        BOOL success = NO;
//
//        NSLog(@"buffer = %@", buffer);                   // 70560/70560 bytes = 17640 * 4
//        NSLog(@"format = %@", buffer.format);            // 44100, 2, Float32
//        NSLog(@"has frames = %d", buffer.frameLength);   // 17640 frame
//        NSLog(@"can frames = %d", buffer.frameCapacity); // 17640 frame = 44100 * 0.4
//
////        NSLog(@"channelCount = %@", buffer.format.streamDescription);
//        NSLog(@"interleaved = %@", @(buffer.format.isInterleaved)); // NO
//        NSLog(@"mBytesPerFrame = %@", @(buffer.format.streamDescription->mBytesPerFrame)); //           4 byte
//        NSLog(@"mChannelsPerFrame = %@", @(buffer.format.streamDescription->mChannelsPerFrame)); //     2 channels
//        NSLog(@"mBitsPerChannel = %@", @(buffer.format.streamDescription->mBitsPerChannel)); //         32 bits
//        NSLog(@"mSampleRate = %@", @(buffer.format.streamDescription->mSampleRate)); //                 44100
//        NSLog(@"%p", buffer.floatChannelData);
//        NSLog(@"%p", buffer.floatChannelData[0]);
//        NSLog(@"%p", buffer.floatChannelData[1]);
////        NSLog(@"%p", buffer.floatChannelData[2]);
////        NSLog(@"%p", buffer.floatChannelData[3]);
//
////        NSData *data = [NSData dataWithBytes:buffer.floatChannelData length:buffer..];
////        NSLog(@"data = %lu", (unsigned long)data.length);
//
//
//        // as AVAudioPCMBuffer's are delivered this will write sequentially. The buffer's frameLength signifies how much of the buffer is to be written
//        // IMPORTANT: The buffer format MUST match the file's processing format which is why outputFormatForBus: was used when creating the AVAudioFile object above
////        success = [mixerOutputFile writeFromBuffer:buffer error:&error];
////        NSAssert(success, @"error writing buffer data to file, %@", [error localizedDescription]);
//    }];
//
//
//}

@end
