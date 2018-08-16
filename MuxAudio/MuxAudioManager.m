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
@property(nonatomic, strong) NSDateFormatter *formatter;

@property(nonatomic, assign) BOOL installed;
@property(nonatomic, strong) NSMutableArray<NSData *> *mixedPCMBuffers;
@property(nonatomic, strong) dispatch_queue_t queue;

@property(nonatomic, strong) NSCache *cache;

@property(nonatomic, strong) NSMutableData *mixedData;

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
        
        _queue = dispatch_queue_create("ResourceQueue", DISPATCH_QUEUE_SERIAL);
        
        _cache = [[NSCache alloc] init];
        _cache.countLimit = 5;
        
        _mixedData = [NSMutableData data];
    }
    return self;
}


- (NSString *)playAudioFileAt:(NSString *)path loop:(BOOL)loop {
    
    NSString *date =  [_formatter stringFromDate:[NSDate date]];
    NSString *timeLocal = [[NSString alloc] initWithFormat:@"%@", date];
    NSString *audioFileName = [path.stringByDeletingPathExtension lastPathComponent];
    NSString *audioFileID = [[path.stringByDeletingPathExtension lastPathComponent] stringByAppendingString:timeLocal]; // Audio ID by audio file name.
    AVAudioPlayerNode *node = _nodesPool.firstObject;
//    AVAudioPCMBuffer *buffer = _buffers[audioFileName];
    AVAudioPCMBuffer *buffer = [_cache objectForKey:audioFileName];
    
    
    if (buffer == nil) {
        NSString *extension = [path pathExtension];
        NSURL *url = [NSURL URLWithString:path];
        AVAudioPCMBuffer *aBuffer;
        if ([extension isEqualToString:@"pcm"]) {
            NSData *pcmData = [NSData dataWithContentsOfFile:path];
            AVAudioFormat *format = [[AVAudioFormat alloc] initWithCommonFormat:(AVAudioPCMFormatFloat32) sampleRate:44100 channels:2 interleaved:NO];
            aBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format frameCapacity:(AVAudioFrameCount)[pcmData length]];
            
            memcpy(aBuffer.floatChannelData[0], [pcmData bytes], pcmData.length / 2);
            NSData *data = [NSData dataWithBytes:aBuffer.floatChannelData[0] length:pcmData.length / 2];
        } else {
            NSLog(@"New buffer");
            NSError *error;
            AVAudioFile *file = [[AVAudioFile alloc] initForReading:url error:&error];
            aBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:[file processingFormat] frameCapacity:(AVAudioFrameCount)[file length]];
            [file readIntoBuffer:aBuffer error:&error];
        }
        
        buffer = aBuffer;
        if (loop == NO) {
            NSLog(@"cached.");
//           _buffers[audioFileName] = aBuffer;
            [_cache setObject:aBuffer forKey:audioFileName];
        }
        
    }
    
    if (node == nil) {
        AVAudioPlayerNode *aNode = [[AVAudioPlayerNode alloc] init];
        [_engine attachNode:aNode];
        [_engine connect:aNode to:_mixNode format:buffer.format];
        node = aNode;
    } else {
        [_engine connect:node to:_mixNode format:buffer.format];
        [_nodesPool removeObjectAtIndex:0];
    }
    
    __weak typeof(node) wNode = node;
    __weak typeof(self) wself = self;
    
    [node scheduleBuffer:buffer atTime:nil options:( loop ? AVAudioPlayerNodeBufferLoops : AVAudioPlayerNodeBufferInterruptsAtLoop) completionHandler:^{ // did play
//        dispatch_async(dispatch_get_main_queue(), ^{
//            dispatch_async(wself.queue, ^{
                [wself.nodesPool addObject:wNode];
                [wself.playingNodes removeObjectForKey:audioFileID];
                NSLog(@"play end. pool = %@, ing = %@", @(wself.nodesPool.count), @(wself.playingNodes.count));
//            });
//        });
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


- (void)stopAudioFileByAudioID:(NSString *)audioID {
    __weak typeof(self) wself = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
        AVAudioPlayerNode *node = wself.playingNodes[audioID];
        if (node != nil) {
            [node stop];
        }
//        NSLog(@"pool = %@", @(wself.nodesPool.count));
//        NSLog(@"buffer = %@", @(wself.buffers.count));
//    });
}



- (void)stopAll {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMddhhmmss"];
    NSDate *now = [NSDate date];
    NSString *str = [formatter stringFromDate:now];

    NSURL *url = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:[NSString stringWithFormat:@"mixed_%@.pcm", str]];
    if ([_mixedData writeToURL:url atomically:YES]) {
        NSLog(@"Writed success\n\n %@", url);
    } else {
        NSLog(@"Write failly");
    }
    
    
    __weak typeof(self) wself = self;
        [wself.engine stop];
        [wself stopMixPCMBuffer];
        [wself.mixedPCMBuffers removeAllObjects];
}

- (void)cleanAll {
    __weak typeof(self) wself = self;
        [wself stopAll];
        [wself.buffers removeAllObjects];
}


- (void)beganMixPCMBuffer {
    if (_installed == YES) {return;}
    _installed = YES;
    __weak typeof(self) wself = self;
    AVAudioFrameCount bufferSize = 44100 * 0.12;
    [_mixNode installTapOnBus:0 bufferSize:bufferSize format:[_mixNode outputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        NSData *data = [NSData dataWithBytes:buffer.floatChannelData[0] length: buffer.frameLength * buffer.format.streamDescription->mBytesPerFrame / 2];
        
//        NSData *aaa = [NSData dataWithBytesNoCopy:buffer.floatChannelData[0] length:buffer.frameLength * buffer.format.streamDescription->mBytesPerFrame];
//        /*
//         struct AudioStreamBasicDescription
//         {
//         Float64             mSampleRate;
//         AudioFormatID       mFormatID;
//         AudioFormatFlags    mFormatFlags;
//         UInt32              mBytesPerPacket;
//         UInt32              mFramesPerPacket;
//         UInt32              mBytesPerFrame;
//         UInt32              mChannelsPerFrame;
//         UInt32              mBitsPerChannel;
//         UInt32              mReserved;
//         };
//         */
//        BOOL h = buffer.format.interleaved;
//        NSUInteger i = buffer.stride;
//        Float64 a = buffer.format.streamDescription->mSampleRate;
//        UInt32 b = buffer.format.streamDescription->mBytesPerPacket;
//        UInt32 c = buffer.format.streamDescription->mFramesPerPacket;
//        UInt32 d = buffer.format.streamDescription->mBytesPerFrame;
//        UInt32 e = buffer.format.streamDescription->mChannelsPerFrame;
//        UInt32 f = buffer.format.streamDescription->mBitsPerChannel;
//        UInt32 g = buffer.format.streamDescription->mReserved;
//        NSLog(@"\ninterleaved = %@,\nstride = %@,\nSampleRate = %@,\n mBytesPerPacket = %@,\n mFramesPerPacket = %@,\n mBytesPerFrame = %@,\n mChannelsPerFrame = %@,\n mBitsPerChannel = %@,\n mReserved = %@",@(h),@(i),@(a),@(b),@(c),@(d),@(e),@(f),@(g));
        
        float value = 0;
        
        
        const void *bytes = [data bytes];
        float *bufferData = buffer.floatChannelData[0];
        short* pOutShortBuf = (short*)bytes;
        
        for(int i = 0; i < bufferSize; i += 2) {
            value += fabsf(buffer.floatChannelData[0][i]);
        }
        
        value = value / (bufferSize / 2);
        short int db = (short)20*log10f((32767*value));
        
        int needGain = (60 - db);
        
//        float b = bufferData[i];
        NSLog(@"value = %f, db = %d, gain = %d, end = %f", value, db, needGain, pow(10, needGain/20.0));
        
        for(int i=0;i<bufferSize;i++)
        {
//            int32_t f = abs((int32_t)(bufferData[i] * 0.001 * pow(2, 32)));
//            NSLog(@"b = %f, f = %d, db = %f",bufferData[i], f, 20*log10(f));
            
            
            pOutShortBuf[i] = (short)(bufferData[i]*pow(10, needGain/20.0)*32767);
        }
        
        
        
//        [wself.mixedPCMBuffers addObject:data];
        [wself.mixedData appendData:data];
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
